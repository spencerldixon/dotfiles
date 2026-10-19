import assert from "node:assert/strict";
import { execFile } from "node:child_process";
import { mkdtemp, mkdir, writeFile, rm, realpath } from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import { promisify } from "node:util";
import test from "node:test";
import verification, { parseChecks } from "../.pi/agent/extensions/verification.ts";

const exec = promisify(execFile);
const boundary = { outcome: "completed", context: { canContinue: true } };

async function fixture(t, { trusted = true, configured = true } = {}) {
  const root = await realpath(await mkdtemp(path.join(os.tmpdir(), "pi-verification-test-")));
  t.after(() => rm(root, { recursive: true, force: true }));
  const git = (...args) => exec("git", args, { cwd: root });
  await git("init", "-q");
  await git("-c", "user.name=Test", "-c", "user.email=test@example.invalid", "commit", "--allow-empty", "-qm", "Initial");
  await mkdir(path.join(root, ".pi"));
  if (configured) await writeFile(path.join(root, ".pi/verification.json"), JSON.stringify({
    version: 1, checks: [{ name: "unit", bin: "check-fixture", args: ["argument with spaces"], timeoutMs: 1234 }],
  }));
  const handlers = new Map();
  const commands = new Map();
  const messages = [];
  const checks = [];
  const notifications = [];
  const api = {
    on: (name, handler) => handlers.set(name, handler),
    registerCommand: (name, command) => commands.set(name, command),
    sendMessage: (message) => messages.push(message),
    exec: async (bin, args, options) => {
      if (bin === "check-fixture") {
        checks.push({ bin, args, options });
        return { code: 0, stdout: "all good", stderr: "" };
      }
      try {
        const result = await exec(bin, args, options);
        return { ...result, code: 0 };
      } catch (error) {
        return { code: error.code, stdout: error.stdout ?? "", stderr: error.stderr ?? "" };
      }
    },
  };
  const ctx = { cwd: root, hasUI: true, isProjectTrusted: () => trusted, ui: { notify: (...args) => notifications.push(args) } };
  verification(api);
  return { root, handlers, commands, messages, checks, notifications, ctx, api, git };
}

test("validates checks and enforces execution bounds", () => {
  assert.equal(parseChecks({ version: 1, checks: [{ name: "test", bin: "npm", args: ["test"] }] })[0].timeoutMs, 30000);
  for (const config of [null, {}, { version: 1, checks: Array(5).fill({}) },
    { version: 1, checks: [{ name: "bad", bin: "npm", args: "test" }] },
    { version: 1, checks: [{ name: "bad", bin: "npm", args: [], timeoutMs: 60001 }] }]) {
    assert.throws(() => parseChecks(config));
  }
});

test("no config means no automatic execution", async (t) => {
  const f = await fixture(t, { configured: false });
  await f.handlers.get("before_agent_start")({}, f.ctx);
  await writeFile(path.join(f.root, "changed.txt"), "new");
  assert.equal(await f.handlers.get("agent_before_settle")(boundary, f.ctx), undefined);
  assert.equal(f.checks.length, 0);
});

test("untrusted project never runs configured commands", async (t) => {
  const f = await fixture(t, { trusted: false });
  await f.handlers.get("before_agent_start")({}, f.ctx);
  await writeFile(path.join(f.root, "changed.txt"), "new");
  assert.equal(await f.handlers.get("agent_before_settle")(boundary, f.ctx), undefined);
  await f.commands.get("verify").handler("", f.ctx);
  assert.equal(f.checks.length, 0);
  assert.match(f.messages[0].content, /No verification was performed/);
});

test("detects edits to already dirty files, runs once per revision, and reports results", async (t) => {
  const f = await fixture(t);
  const file = path.join(f.root, "dirty.txt");
  await writeFile(file, "baseline");
  await f.handlers.get("before_agent_start")({}, f.ctx);
  assert.equal(await f.handlers.get("agent_before_settle")(boundary, f.ctx), undefined);
  await writeFile(file, "modified by shell or subagent");
  const result = await f.handlers.get("agent_before_settle")(boundary, f.ctx);
  assert.equal(f.checks.length, 1);
  assert.deepEqual(f.checks[0].args, ["argument with spaces"]);
  assert.equal(f.checks[0].options.timeout, 1234);
  assert.equal(f.checks[0].options.cwd, f.root);
  assert.equal(result.continue, true);
  assert.match(result.entries[0].content, /PASS unit/);
  assert.equal(await f.handlers.get("agent_before_settle")(boundary, f.ctx), undefined);
});

test("bounds repair loops and marks later changes unverified", async (t) => {
  const f = await fixture(t);
  await f.handlers.get("before_agent_start")({}, f.ctx);
  for (let i = 1; i <= 3; i++) {
    await writeFile(path.join(f.root, "changed.txt"), String(i));
    const result = await f.handlers.get("agent_before_settle")(boundary, f.ctx);
    if (i === 3) assert.match(result.entries[0].content, /Latest changes are unverified/);
  }
  assert.equal(f.checks.length, 2);
  assert.equal(await f.handlers.get("agent_before_settle")(boundary, f.ctx), undefined);
});

test("aborted runs do not execute checks", async (t) => {
  const f = await fixture(t);
  await f.handlers.get("before_agent_start")({}, f.ctx);
  await writeFile(path.join(f.root, "changed.txt"), "new");
  assert.equal(await f.handlers.get("agent_before_settle")({ ...boundary, outcome: "aborted" }, f.ctx), undefined);
  assert.equal(f.checks.length, 0);
});

test("manual verify reports nonzero exits and runner failures", async (t) => {
  const f = await fixture(t);
  f.api.exec = async (bin, args, options) => {
    if (bin === "git") return { code: 0, stdout: f.root, stderr: "" };
    return { code: 2, stdout: "", stderr: "failing test" };
  };
  await f.commands.get("verify").handler("", f.ctx);
  assert.match(f.messages[0].content, /FAIL unit/);
  assert.match(f.messages[0].content, /failing test/);
  f.api.exec = async (bin) => {
    if (bin === "git") return { code: 0, stdout: f.root, stderr: "" };
    throw new Error("timed out");
  };
  await f.commands.get("verify").handler("", f.ctx);
  assert.match(f.messages[1].content, /FAIL unit: Error: timed out/);
});

test("staged-only changes and deletions are detected", async (t) => {
  const f = await fixture(t);
  const file = path.join(f.root, "tracked.txt");
  await writeFile(file, "original");
  await f.git("add", "tracked.txt");
  await f.git("-c", "user.name=Test", "-c", "user.email=test@example.invalid", "commit", "-qm", "Track fixture");
  await f.handlers.get("before_agent_start")({}, f.ctx);
  await writeFile(file, "staged");
  await f.git("add", "tracked.txt");
  assert.match((await f.handlers.get("agent_before_settle")(boundary, f.ctx)).entries[0].content, /PASS/);
  await rm(file);
  assert.match((await f.handlers.get("agent_before_settle")(boundary, f.ctx)).entries[0].content, /PASS/);
  assert.equal(f.checks.length, 2);
});
