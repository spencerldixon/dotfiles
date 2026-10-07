import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";
import { homedir } from "node:os";

type Window = { used_percent?: number; limit_window_seconds?: number; reset_at?: number; reset_after_seconds?: number };
const percent = (value: unknown): number | undefined =>
  typeof value === "number" && Number.isFinite(value) ? Math.max(0, Math.min(100, value)) : undefined;
const clean = (value: string) => value.replace(/[\x00-\x1f\x7f]/g, " ");

/** Personal footer. All meters show USED capacity, not remaining capacity. */
export default function (pi: ExtensionAPI) {
  let cleanup: (() => void) | undefined;
  let refresh: (() => Promise<void>) | undefined;

  function install(ctx: ExtensionContext) {
    cleanup?.();
    if (ctx.mode !== "tui") return;

    ctx.ui.setFooter((tui, theme, footerData) => {
      let current: number | undefined;
      let weekly: number | undefined;
      let currentLabel = "Current";
      let currentResetAt: number | undefined;
      let state = "loading";
      let disposed = false;
      let pending = false;
      let controller: AbortController | undefined;
      const unsubscribe = footerData.onBranchChange(() => tui.requestRender());

      async function update() {
        if (disposed || pending) return;
        if (ctx.model?.provider !== "openai-codex") {
          current = weekly = undefined;
          currentResetAt = undefined;
          state = "unavailable";
          tui.requestRender();
          return;
        }
        pending = true;
        controller = new AbortController();
        const timeout = setTimeout(() => controller?.abort(), 10000);
        try {
          // Use Pi's auth resolver so expired OAuth credentials are refreshed by Pi.
          const token = await ctx.modelRegistry.getApiKeyForProvider("openai-codex");
          if (disposed) return;
          if (!token) throw new Error("No Codex credentials");
          const payload = JSON.parse(Buffer.from(token.split(".")[1], "base64url").toString());
          const accountId = payload["https://api.openai.com/auth"]?.chatgpt_account_id;
          if (!accountId) throw new Error("Missing account ID");
          const response = await fetch("https://chatgpt.com/backend-api/wham/usage", {
            headers: { Authorization: `Bearer ${token}`, "ChatGPT-Account-Id": accountId },
            signal: controller.signal,
          });
          if (!response.ok) throw new Error("Usage unavailable");
          const data = await response.json() as {
            rate_limit?: { primary_window?: Window; secondary_window?: Window };
          };
          if (disposed) return;
          current = percent(data.rate_limit?.primary_window?.used_percent);
          weekly = percent(data.rate_limit?.secondary_window?.used_percent);
          const window = data.rate_limit?.primary_window;
          const resetAt = window?.reset_at;
          const resetAfter = window?.reset_after_seconds;
          currentResetAt = typeof resetAt === "number" && Number.isFinite(resetAt) && resetAt > 0
            ? resetAt * 1000
            : typeof resetAfter === "number" && Number.isFinite(resetAfter) && resetAfter >= 0
              ? Date.now() + resetAfter * 1000
              : undefined;
          const seconds = window?.limit_window_seconds;
          currentLabel = seconds && seconds % 3600 === 0 ? `Current (${seconds / 3600}h)` : "Current";
          state = current === undefined && weekly === undefined ? "unavailable" : "ready";
        } catch {
          // Never log credentials or provider response bodies. Mark old readings as stale.
          if (!disposed) state = current !== undefined || weekly !== undefined ? "stale" : "unavailable";
        } finally {
          clearTimeout(timeout);
          pending = false;
          if (!disposed) tui.requestRender();
        }
      }

      refresh = update;
      const timer = setInterval(() => { void update(); }, 60000);
      timer.unref();
      void update();
      const dispose = () => {
        if (disposed) return;
        disposed = true;
        clearInterval(timer);
        controller?.abort();
        unsubscribe();
        if (refresh === update) refresh = undefined;
      };
      cleanup = dispose;

      function meter(label: string, value: number | undefined, cells: number) {
        const color = value === undefined ? "dim" : value >= 90 ? "error" : value >= 70 ? "warning" : "success";
        const filled = value === undefined ? 0 : Math.round(value / 100 * cells);
        const bar = value === undefined
          ? theme.fg("dim", "░".repeat(cells))
          : theme.fg(color, "█".repeat(filled)) + theme.fg("dim", "░".repeat(cells - filled));
        return `${theme.fg("muted", label)} [${bar}] ${theme.fg(color, value === undefined ? "n/a" : `${Math.round(value)}%`)}`;
      }

      return {
        dispose,
        invalidate() {},
        render(width: number) {
          const model = ctx.model?.id ?? "no-model";
          const effort = pi.getThinkingLevel();
          const branch = footerData.getGitBranch();
          const home = homedir();
          const cwd = ctx.cwd === home ? "~" : ctx.cwd.startsWith(`${home}/`) ? `~${ctx.cwd.slice(home.length)}` : ctx.cwd;
          const location = clean(`${cwd}${branch ? ` (${branch})` : ""}`);
          const identity = theme.fg("accent", clean(`${model} · effort ${effort}`));
          const lines: string[] = [];
          if (visibleWidth(location) + visibleWidth(identity) + 2 <= width) {
            lines.push(theme.fg("dim", location) + " ".repeat(width - visibleWidth(location) - visibleWidth(identity)) + identity);
          } else {
            lines.push(identity);
            lines.push(theme.fg("dim", location));
          }
          const codex = ctx.model?.provider === "openai-codex";
          const cells = width >= 90 ? 10 : 6;
          const meters = [
            meter("Context", percent(ctx.getContextUsage()?.percent), cells),
            meter(currentLabel, codex ? current : undefined, cells),
            meter("Weekly", codex ? weekly : undefined, cells),
          ];
          const centered = (line: string) =>
            " ".repeat(Math.max(0, Math.floor((width - visibleWidth(line)) / 2))) + line;
          let row = "";
          for (const item of meters) {
            if (row && visibleWidth(row) + visibleWidth(item) + 3 > width) {
              lines.push(centered(row));
              row = item;
            } else row += `${row ? "   " : ""}${item}`;
          }
          if (row) lines.push(centered(row));
          if (codex && currentResetAt !== undefined) {
            const minutes = Math.max(0, Math.ceil((currentResetAt - Date.now()) / 60000));
            const countdown = minutes >= 60 ? `${Math.floor(minutes / 60)}h ${minutes % 60}m` : `${minutes}m`;
            const resetTime = new Date(currentResetAt).toLocaleTimeString(undefined, {
              hour: "numeric", minute: "2-digit", timeZoneName: "short",
            });
            const text = minutes > 0
              ? `Current resets at ${resetTime} · in ${countdown}`
              : "Current reset due · awaiting usage refresh";
            lines.push(centered(theme.fg("dim", text)));
          }
          if (codex && state !== "ready") lines.push(centered(theme.fg("dim", `Usage: ${state}`)));
          const statuses = [...footerData.getExtensionStatuses().values()].map(clean);
          if (statuses.length) lines.push(statuses.join("  "));
          return lines.map(line => truncateToWidth(line, Math.max(0, width)));
        },
      };
    });
  }

  pi.on("session_start", (_event, ctx) => install(ctx));
  pi.on("model_select", (_event, ctx) => install(ctx));
  pi.on("session_shutdown", () => { cleanup?.(); cleanup = undefined; });
  pi.registerCommand("usage-refresh", {
    description: "Refresh the footer's Codex subscription usage meters",
    handler: async () => { await refresh?.(); },
  });
}
