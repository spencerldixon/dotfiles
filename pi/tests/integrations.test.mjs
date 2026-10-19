// Local smoke tests. Requires the stowed Pi setup and installed npm packages.
import assert from "node:assert/strict";
import { mkdtemp, mkdir, readFile, writeFile, rm } from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import { pathToFileURL } from "node:url";
import test from "node:test";

const agentDir = process.env.PI_CODING_AGENT_DIR ?? path.join(os.homedir(), ".pi/agent");
const version = (await readFile(path.join(agentDir, "install/current-version"), "utf8")).trim();
const piRoot = process.env.PI_PACKAGE_ROOT ?? path.join(agentDir, "install/releases", version, "node_modules/@earendil-works/pi-coding-agent");
const { loadExtensions } = await import(pathToFileURL(path.join(piRoot, "dist/core/extensions/loader.js")));
const here = path.dirname(new URL(import.meta.url).pathname);

async function load(t, extensionPaths, cwd) {
  const result = await loadExtensions(extensionPaths, cwd);
  assert.deepEqual(result.errors, []);
  result.runtime.sendMessage = () => {};
  const ctx = {
    cwd, hasUI: false, isProjectTrusted: () => false,
    ui: { notify: () => {}, theme: { fg: (_color, text) => text } },
  };
  t.after(async () => {
    for (const extension of result.extensions) {
      for (const handler of extension.handlers.get("session_shutdown") ?? []) await handler({}, ctx);
    }
  });
  return { ...result, ctx };
}

async function fixture(t) {
  const cwd = await mkdtemp(path.join(os.tmpdir(), "pi-integration-test-"));
  t.after(() => rm(cwd, { recursive: true, force: true }));
  const configDir = path.join(cwd, "agent");
  await mkdir(configDir);
  for (const name of ["lsp.json", "code-quality.json"]) {
    await writeFile(path.join(configDir, name), await readFile(path.join(here, "../.pi/agent", name)));
  }
  const previous = process.env.PI_AGENT_DIR;
  process.env.PI_AGENT_DIR = configDir;
  t.after(() => previous === undefined ? delete process.env.PI_AGENT_DIR : process.env.PI_AGENT_DIR = previous);
  return cwd;
}

function toolEvent(file) {
  return { toolName: "write", toolCallId: "smoke", input: { path: file }, content: [{ type: "text", text: "Wrote fixture" }], isError: false };
}

const packageExtension = (pkg) => path.join(agentDir, "npm/node_modules", pkg, "extensions", pkg, "index.ts");

test("subagent and verification extensions load and expose expected capabilities", async (t) => {
  const result = await load(t, [path.join(agentDir, "extensions/subagent/index.ts"), path.join(agentDir, "extensions/verification.ts")], here);
  assert.ok(result.extensions[0].tools.has("subagent"));
  assert.ok(result.extensions[1].commands.has("verify"));
  // Check frontmatter without importing host-dependent TypeScript outside Pi's loader.
  for (const role of ["scout", "worker", "implementer", "reviewer"]) {
    const agent = await readFile(path.join(agentDir, "agents", `${role}.md`), "utf8");
    assert.match(agent, new RegExp(`name: ${role}\\n`));
    assert.doesNotMatch(agent, /^model:/m);
  }
});

test("code-quality hook reports invalid JSON without changing the file", async (t) => {
  const cwd = await fixture(t);
  const file = path.join(cwd, "bad.json");
  await writeFile(file, "{invalid}");
  const { extensions, ctx } = await load(t, [packageExtension("pi-code-quality")], cwd);
  const result = await extensions[0].handlers.get("tool_result")[0](toolEvent(file), ctx);
  const text = result.content.map((part) => part.text ?? "").join("\n");
  assert.match(text, /json-syntax/);
  assert.match(text, /SyntaxError/);
  assert.equal(await readFile(file, "utf8"), "{invalid}");
});

test("TypeScript LSP supplies definition and diagnostics", { timeout: 45000 }, async (t) => {
  const cwd = await fixture(t);
  await writeFile(path.join(cwd, "package.json"), '{"private":true}');
  await writeFile(path.join(cwd, "tsconfig.json"), '{"compilerOptions":{"strict":true,"ignoreDeprecations":"6.0"},"include":["*.ts"]}');
  const file = path.join(cwd, "example.ts");
  await writeFile(file, 'export const answer: number = 42;\nconsole.log(answer);\n');
  const { extensions, ctx } = await load(t, [packageExtension("pi-lsp")], cwd);
  const tools = extensions[0].tools;
  const definition = await tools.get("lsp_definition").definition.execute("smoke", { path: file, line: 1, character: 13 }, undefined, undefined, ctx);
  assert.match(JSON.stringify(definition.content), /example.ts/);
  await writeFile(file, 'export const answer: number = "wrong";\n');
  const result = await extensions[0].handlers.get("tool_result")[0](toolEvent(file), ctx);
  assert.match(JSON.stringify(result.content), /not assignable|2322/);
  const diagnostics = await tools.get("lsp_diagnostics").definition.execute("smoke", { path: file }, undefined, undefined, ctx);
  assert.match(JSON.stringify(diagnostics.content), /not assignable|2322/);
});
