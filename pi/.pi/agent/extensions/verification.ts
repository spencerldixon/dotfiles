import { createHash } from "node:crypto";
import { lstat, readFile, readlink } from "node:fs/promises";
import path from "node:path";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

type Check = { name: string; bin: string; args: string[]; timeoutMs: number };
type Config = { root: string; checks: Check[] };

export function parseChecks(value: unknown): Check[] {
  const config = value as { version?: unknown; checks?: unknown };
  if (!config || config.version !== 1 || !Array.isArray(config.checks) || config.checks.length > 4) {
    throw new Error("verification.json requires version: 1 and at most four checks");
  }
  return config.checks.map((check: unknown) => {
    const c = check as Check;
    if (!c || typeof c.name !== "string" || typeof c.bin !== "string" || !c.bin.trim() ||
      !Array.isArray(c.args) || !c.args.every((arg) => typeof arg === "string") ||
      (c.timeoutMs !== undefined && (!Number.isInteger(c.timeoutMs) || c.timeoutMs < 1 || c.timeoutMs > 60000))) {
      throw new Error("Each verification check needs name, bin, args, and an optional timeoutMs of 1-60000");
    }
    return { name: c.name, bin: c.bin, args: c.args, timeoutMs: c.timeoutMs ?? 30000 };
  });
}

async function loadConfig(pi: ExtensionAPI, ctx: ExtensionContext): Promise<Config | undefined> {
  // Project commands execute code. Never read or run them without Pi project trust.
  if (!ctx.isProjectTrusted()) return;
  const git = await pi.exec("git", ["rev-parse", "--show-toplevel"], { cwd: ctx.cwd, timeout: 5000 });
  if (git.code !== 0) return;
  const root = git.stdout.trim();
  try {
    const raw = await readFile(path.join(root, ".pi", "verification.json"), "utf8");
    return { root, checks: parseChecks(JSON.parse(raw)) };
  } catch (error) {
    if ((error as NodeJS.ErrnoException).code === "ENOENT") return;
    throw error;
  }
}

async function fingerprint(pi: ExtensionAPI, root: string): Promise<string> {
  const git = async (args: string[]) => {
    const result = await pi.exec("git", args, { cwd: root, timeout: 5000 });
    if (result.code !== 0) throw new Error(`git ${args.join(" ")} failed: ${result.stderr}`);
    return result.stdout;
  };
  const [head, working, staged] = await Promise.all([
    git(["rev-parse", "HEAD"]),
    git(["ls-files", "--modified", "--others", "--exclude-standard", "-z"]),
    git(["diff", "--cached", "--name-only", "-z"]),
  ]);
  const files = [...new Set((working + staged).split("\0").filter(Boolean))].sort();
  const hash = createHash("sha256").update(head);
  for (const file of files) {
    hash.update(JSON.stringify(file));
    const absolute = path.join(root, file);
    try {
      const stat = await lstat(absolute);
      hash.update(String(stat.mode));
      if (stat.isSymbolicLink()) hash.update(await readlink(absolute));
      else if (stat.isFile() && stat.size <= 1024 * 1024) hash.update(await readFile(absolute));
      else hash.update(`${stat.size}:${stat.mtimeMs}:${stat.ctimeMs}`);
    } catch (error) {
      if ((error as NodeJS.ErrnoException).code !== "ENOENT") throw error;
      hash.update("deleted");
    }
  }
  return hash.digest("hex");
}

async function runChecks(pi: ExtensionAPI, ctx: ExtensionContext, config: Config): Promise<string> {
  const lines = ["Verification results (configured checks only):"];
  for (const check of config.checks) {
    if (ctx.signal?.aborted) throw new Error("Verification aborted");
    try {
      const result = await pi.exec(check.bin, check.args, {
        cwd: config.root, timeout: check.timeoutMs, signal: ctx.signal,
      });
      lines.push(`\n${result.code === 0 ? "PASS" : "FAIL"} ${check.name}: ${JSON.stringify([check.bin, ...check.args])} (exit ${result.code})`);
      const output = (result.stdout + result.stderr).trim();
      if (output) lines.push(output.length > 4000 ? `[output truncated]\n${output.slice(-4000)}` : output);
    } catch (error) {
      if (ctx.signal?.aborted) throw error;
      lines.push(`\nFAIL ${check.name}: ${String(error)}`);
    }
  }
  return lines.join("\n");
}

export default function verification(pi: ExtensionAPI) {
  let config: Config | undefined;
  let lastChecked = "";
  let attempts = 0;
  let limitReported = false;
  const reportError = (ctx: ExtensionContext, error: unknown) => {
    if (ctx.hasUI) ctx.ui.notify(`Verification unavailable: ${String(error)}`, "warning");
  };

  pi.on("before_agent_start", async (_event, ctx) => {
    config = undefined;
    attempts = 0;
    limitReported = false;
    try {
      config = await loadConfig(pi, ctx);
      if (config?.checks.length) lastChecked = await fingerprint(pi, config.root);
    } catch (error) {
      config = undefined;
      reportError(ctx, error);
    }
  });

  pi.on("agent_before_settle", async (event, ctx) => {
    if (!config?.checks.length || event.outcome !== "completed" || !ctx.isProjectTrusted()) return;
    try {
      const current = await fingerprint(pi, config.root);
      if (current === lastChecked) return;
      let content: string;
      if (attempts >= 2) {
        if (limitReported) return;
        limitReported = true;
        content = "Verification limit reached: files changed after two automatic check passes. Latest changes are unverified. Run /verify before claiming checks pass.";
      } else {
        lastChecked = current;
        attempts++;
        content = await runChecks(pi, ctx, config);
      }
      return {
        entries: [{ type: "custom_message" as const, customType: "verification", content, display: true }],
        continue: event.context.canContinue,
      };
    } catch (error) {
      // Avoid a retry loop on a broken runner; still tell the model it did not pass.
      config = undefined;
      return {
        entries: [{ type: "custom_message" as const, customType: "verification", content: `Verification did not complete: ${String(error)}`, display: true }],
        continue: event.context.canContinue && !ctx.signal?.aborted,
      };
    }
  });

  pi.registerCommand("verify", {
    description: "Run trusted project checks from .pi/verification.json",
    handler: async (_args, ctx) => {
      try {
        const current = await loadConfig(pi, ctx);
        const content = current?.checks.length
          ? await runChecks(pi, ctx, current)
          : "No checks configured, or project is untrusted. Configure .pi/verification.json in the Git root. No verification was performed.";
        pi.sendMessage({ customType: "verification", content, display: true });
      } catch (error) {
        pi.sendMessage({ customType: "verification", content: `Verification did not complete: ${String(error)}`, display: true });
      }
    },
  });
}
