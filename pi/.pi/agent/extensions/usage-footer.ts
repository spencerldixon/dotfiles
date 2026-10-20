import { readStoredCredential, type ExtensionAPI, type ExtensionContext } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";
import { homedir } from "node:os";

type Window = { used_percent?: number; limit_window_seconds?: number; reset_at?: number; reset_after_seconds?: number };
const percent = (value: unknown): number | undefined =>
  typeof value === "number" && Number.isFinite(value) ? Math.max(0, Math.min(100, value)) : undefined;
const clean = (value: string) => value.replace(/[\x00-\x1f\x7f]/g, " ");
const resetTimestamp = (window: Window | undefined): number | undefined => {
  const resetAt = window?.reset_at;
  const resetAfter = window?.reset_after_seconds;
  return typeof resetAt === "number" && Number.isFinite(resetAt) && resetAt > 0
    ? resetAt * 1000
    : typeof resetAfter === "number" && Number.isFinite(resetAfter) && resetAfter >= 0
      ? Date.now() + resetAfter * 1000
      : undefined;
};

/** Personal footer. All meters show USED capacity, not remaining capacity. */
export default function (pi: ExtensionAPI) {
  let cleanup: (() => void) | undefined;
  let refresh: (() => Promise<void>) | undefined;

  function install(ctx: ExtensionContext) {
    cleanup?.();
    if (ctx.mode !== "tui") return;

    ctx.ui.setFooter((tui, theme, footerData) => {
      const provider = ctx.model?.provider;
      const supported = provider === "openai-codex" || provider === "github-copilot"
        || ((provider === "openai" || provider === "anthropic")
          && !!ctx.model && ctx.modelRegistry.isUsingOAuth(ctx.model));
      type UsageMeter = { label: string; value?: number; resetAt?: number };
      let usage: UsageMeter[] = [];
      const dateTimestamp = (value: unknown) => {
        const parsed = typeof value === "string" ? Date.parse(value) : NaN;
        return Number.isFinite(parsed) ? parsed : undefined;
      };
      let state = "loading";
      let disposed = false;
      let pending = false;
      let controller: AbortController | undefined;
      let git: { branch: string; dirty: boolean; conflicted: boolean; ahead: number; behind: number } | undefined;
      let gitPending = false;
      async function updateGit() {
        if (disposed || gitPending) return;
        gitPending = true;
        try {
          const result = await pi.exec("git", ["--no-optional-locks", "status", "--porcelain=v2", "--branch",
            "--untracked-files=normal", "--ignore-submodules"], { cwd: ctx.cwd, timeout: 5000 });
          if (disposed) return;
          git = undefined;
          if (result.code === 0) {
            let branch = "", oid = "", dirty = false, conflicted = false, ahead = 0, behind = 0;
            for (const line of result.stdout.split("\n")) {
              if (line.startsWith("# branch.head ")) branch = line.slice(14);
              else if (line.startsWith("# branch.oid ")) oid = line.slice(13);
              else if (line.startsWith("# branch.ab ")) {
                const match = line.match(/^# branch\.ab \+(\d+) -(\d+)$/);
                if (match) { ahead = Number(match[1]); behind = Number(match[2]); }
              } else if (line && !line.startsWith("# ")) {
                dirty = true;
                if (line.startsWith("u ")) conflicted = true;
              }
            }
            if (branch === "(detached)") branch = `@${oid.slice(0, 7)}`;
            if (branch) git = { branch, dirty, conflicted, ahead, behind };
          }
        } catch {
          if (!disposed) git = undefined;
        } finally {
          gitPending = false;
          if (!disposed) tui.requestRender();
        }
      }
      const unsubscribe = footerData.onBranchChange(() => { void updateGit(); });
      const gitTimer = setInterval(() => { void updateGit(); }, 5000);
      gitTimer.unref();
      void updateGit();

      async function update() {
        if (disposed || pending) return;
        if (!supported) {
          usage = [];
          state = "unavailable";
          tui.requestRender();
          return;
        }
        pending = true;
        controller = new AbortController();
        const timeout = setTimeout(() => controller?.abort(), 10000);
        try {
          const request = async (url: string, headers: Record<string, string>) => {
            const response = await fetch(url, { headers, signal: controller!.signal, redirect: "error" });
            if (!response.ok) throw new Error("Usage unavailable");
            return response.json();
          };
          let next: UsageMeter[];
          if (provider === "github-copilot") {
            // Pi's resolved access token is for inference. This endpoint needs the
            // original GitHub token, stored in the OAuth refresh field by Pi.
            const credential = readStoredCredential("github-copilot");
            if (credential?.type === "oauth" && credential.enterpriseUrl) throw new Error("Unsupported GitHub host");
            const token = credential?.type === "oauth" ? credential.refresh
              : process.env.COPILOT_GITHUB_TOKEN;
            if (!token) throw new Error("No GitHub credentials");
            const data = await request("https://api.github.com/copilot_internal/user", {
              Authorization: `Bearer ${token}`, Accept: "application/json",
              "User-Agent": "pi-usage-footer", "X-GitHub-Api-Version": "2022-11-28",
            });
            const resetAt = dateTimestamp(data.quota_reset_date_utc ?? data.quota_reset_date);
            next = [];
            for (const [key, label] of [["premium_interactions", "Premium"], ["chat", "Chat"], ["completions", "Completions"]]) {
              const quota = data.quota_snapshots?.[key];
              // Unlimited quotas have no meter or reset worth showing.
              if (!quota || quota.unlimited === true) continue;
              const remainingPercent = percent(quota.percent_remaining);
              const remaining = quota.remaining ?? quota.quota_remaining;
              const value = remainingPercent !== undefined ? 100 - remainingPercent
                : typeof quota.entitlement === "number" && quota.entitlement > 0 && typeof remaining === "number"
                  ? percent(100 * (1 - remaining / quota.entitlement)) : undefined;
              next.push({ label, value, resetAt });
            }
          } else {
            // Pi refreshes expired OAuth credentials before returning the token.
            const token = await ctx.modelRegistry.getApiKeyForProvider(provider!);
            if (disposed) return;
            if (!token) throw new Error("No credentials");
            if (provider === "anthropic") {
              const data = await request("https://api.anthropic.com/api/oauth/usage", {
                Authorization: `Bearer ${token}`, "anthropic-beta": "oauth-2025-04-20",
              });
              next = [];
              for (const [key, label] of [["five_hour", "Current (5h)"], ["seven_day", "Weekly"],
                ["seven_day_sonnet", "Sonnet weekly"], ["seven_day_opus", "Opus weekly"]]) {
                const window = data[key];
                if (window) next.push({ label, value: percent(window.utilization), resetAt: dateTimestamp(window.resets_at) });
              }
            } else {
              const payload = JSON.parse(Buffer.from(token.split(".")[1], "base64url").toString());
              const accountId = payload["https://api.openai.com/auth"]?.chatgpt_account_id;
              if (!accountId) throw new Error("Missing account ID");
              const data = await request("https://chatgpt.com/backend-api/wham/usage", {
                Authorization: `Bearer ${token}`, "ChatGPT-Account-Id": accountId,
              });
              const window: Window | undefined = data.rate_limit?.primary_window;
              const weekly: Window | undefined = data.rate_limit?.secondary_window;
              const seconds = window?.limit_window_seconds;
              next = [
                { label: seconds && seconds % 3600 === 0 ? `Current (${seconds / 3600}h)` : "Current",
                  value: percent(window?.used_percent), resetAt: resetTimestamp(window) },
                { label: "Weekly", value: percent(weekly?.used_percent), resetAt: resetTimestamp(weekly) },
              ];
            }
          }
          if (disposed) return;
          usage = next;
          // An empty list means every quota is unlimited, so there is nothing to report.
          state = usage.length === 0 || usage.some(item => item.value !== undefined) ? "ready" : "unavailable";
        } catch {
          // Never log credentials or provider response bodies. Mark old readings as stale.
          if (!disposed) state = usage.some(item => item.value !== undefined) ? "stale" : "unavailable";
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
        clearInterval(gitTimer);
        controller?.abort();
        unsubscribe();
        if (refresh === update) refresh = undefined;
      };
      cleanup = dispose;

      function usageText(label: string, value: number | undefined) {
        const color = value === undefined ? "dim" : value >= 90 ? "error" : value >= 70 ? "warning" : "success";
        return theme.fg("muted", label) + " "
          + theme.fg(color, value === undefined ? "n/a" : `${Math.round(value)}%`);
      }

      return {
        dispose,
        invalidate() {},
        render(width: number) {
          const model = ctx.model ? `${ctx.model.provider}/${ctx.model.id}` : "no-model";
          const effort = pi.getThinkingLevel();
          const branch = git?.branch ?? footerData.getGitBranch();
          const home = homedir();
          const cwd = ctx.cwd === home ? "~" : ctx.cwd.startsWith(`${home}/`) ? `~${ctx.cwd.slice(home.length)}` : ctx.cwd;
          const modelColor = /claude.*opus/i.test(model) ? "thinkingHigh"
            : /claude.*sonnet/i.test(model) ? "warning"
            : /claude.*haiku/i.test(model) ? "success"
            : /gpt/i.test(model) ? "accent" : "thinkingMedium";
          const effortColors = {
            off: "dim", minimal: "thinkingMinimal", low: "thinkingLow", medium: "thinkingMedium",
            high: "thinkingHigh", xhigh: "thinkingXhigh", max: "thinkingMax",
          } as const;
          const identity = theme.fg(modelColor, clean(model)) + "  "
            + theme.fg(effortColors[effort] ?? "accent", effort);
          const pathText = (budget: number) =>
            theme.fg("muted", truncateToWidth(clean(cwd), Math.max(0, budget)));
          // Always show Context, Current and Weekly. Use n/a when a provider has no reading.
          const current = usage.find(item => item.label.startsWith("Current"));
          const weekly = usage.find(item => item.label === "Weekly");
          const meters: UsageMeter[] = [
            { label: "Context", value: percent(ctx.getContextUsage()?.percent) },
            current ?? { label: "Current" },
            weekly ?? { label: "Weekly" },
            ...usage.filter(item => item !== current && item !== weekly),
          ];
          const resetText = (resetAt: number) => {
            const minutes = Math.max(0, Math.ceil((resetAt - Date.now()) / 60000));
            const days = Math.floor(minutes / 1440);
            const hours = Math.floor(minutes % 1440 / 60);
            return minutes === 0 ? "reset due"
              : `↻ ${days > 0 ? `${days}d ${hours}h` : hours > 0 ? `${hours}h ${minutes % 60}m` : `${minutes}m`}`;
          };
          const statuses = [...footerData.getExtensionStatuses().values()].map(clean);
          const notices = [
            ...(supported && state !== "ready" ? [`Usage: ${state}`] : []),
            ...statuses,
          ];
          const usageRowFor = (resets: boolean) => [
            ...meters.map(item => usageText(item.label, item.value)
              + (resets && item.resetAt !== undefined ? ` ${theme.fg("dim", resetText(item.resetAt))}` : "")),
            ...notices,
          ].join("   ");
          const gitStatus = !git ? theme.fg("dim", "?")
            : git.conflicted ? theme.fg("error", "!")
            : git.dirty ? theme.fg("warning", "±") : theme.fg("success", "✓");
          const branchText = branch ? " " + theme.fg("text", clean(branch)) + " " + gitStatus
            + (git?.ahead ? theme.fg("accent", ` ↑${git.ahead}`) : "")
            + (git?.behind ? theme.fg("accent", ` ↓${git.behind}`) : "") : "";
          const columns = Math.max(0, width);
          const rightText = [branchText.trimStart(), identity].filter(Boolean).join("  ");
          // Reserve equal space beside usage so its center is the terminal's center.
          const sideWidth = Math.max(Math.min(visibleWidth(clean(cwd)), 12), visibleWidth(rightText));
          const centerBudget = Math.max(Math.floor(columns / 3), columns - 2 * (sideWidth + 2));
          const fullUsage = usageRowFor(true);
          const usageRow = truncateToWidth(
            visibleWidth(fullUsage) <= centerBudget ? fullUsage : usageRowFor(false), centerBudget);
          const centerStart = Math.max(0, Math.floor((columns - visibleWidth(usageRow)) / 2));
          const centerEnd = centerStart + visibleWidth(usageRow);
          const left = pathText(Math.max(0, centerStart - 2));
          const right = truncateToWidth(rightText, Math.max(0, columns - centerEnd - 2));
          return [left + " ".repeat(Math.max(0, centerStart - visibleWidth(left)))
            + usageRow + " ".repeat(Math.max(0, columns - centerEnd - visibleWidth(right))) + right];
        },
      };
    });
  }

  pi.on("session_start", (_event, ctx) => install(ctx));
  pi.on("model_select", (_event, ctx) => install(ctx));
  pi.on("session_shutdown", () => { cleanup?.(); cleanup = undefined; });
  pi.registerCommand("usage-refresh", {
    description: "Refresh the active provider's subscription usage meters",
    handler: async () => { await refresh?.(); },
  });
}
