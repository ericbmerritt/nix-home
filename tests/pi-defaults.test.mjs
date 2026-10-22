import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import {
  existsSync,
  mkdirSync,
  mkdtempSync,
  readFileSync,
  readlinkSync,
  rmSync,
  symlinkSync,
  writeFileSync,
} from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { test } from "node:test";
import { fileURLToPath } from "node:url";

const helper = fileURLToPath(
  new URL("../nix-home/personal/apply-pi-defaults.mjs", import.meta.url),
);
const defaultsPath = fileURLToPath(
  new URL("../nix-home/personal/pi-settings.json", import.meta.url),
);
const defaults = JSON.parse(readFileSync(defaultsPath, "utf8"));
const sdk = process.env.PI_SETTINGS_SDK;
assert.ok(sdk, "Run these integration tests in nix develop.");

/** @param {import('node:test').TestContext} t */
function fixture(t) {
  const root = mkdtempSync(join(tmpdir(), "pi-defaults-test-"));
  const agentDir = join(root, "agent");
  mkdirSync(agentDir);
  t.after(() => rmSync(root, { recursive: true }));
  return {
    root,
    agentDir,
    settings: join(agentDir, "settings.json"),
    run(options = {}) {
      return spawnSync(
        process.execPath,
        [
          helper,
          options.sdk ?? sdk,
          options.defaults ?? defaultsPath,
          options.agentDir ?? agentDir,
          ...(options.check ? ["--check"] : []),
        ],
        {
          cwd: root,
          encoding: "utf8",
          env: {
            ...process.env,
            HOME: root,
            PI_OFFLINE: "1",
            PI_TELEMETRY: "0",
          },
        },
      );
    },
  };
}

test("merges the declarative defaults while preserving device identity and runtime state", (t) => {
  const f = fixture(t);
  const original = {
    deviceId: "00000000-0000-4000-8000-000000000001",
    lastChangelogVersion: "1.3.0",
    theme: "dark",
    enabledModels: ["openai/*"],
    customPreferences: { nested: true },
    defaultProvider: "other",
    defaultModel: "old-model",
  };
  writeFileSync(f.settings, JSON.stringify(original));
  const auth = join(f.agentDir, "auth.json");
  const sessionDir = join(f.agentDir, "sessions");
  mkdirSync(sessionDir);
  const session = join(sessionDir, "fixture.jsonl");
  writeFileSync(auth, "not credentials or valid auth JSON");
  writeFileSync(session, "session fixture must not change");
  const result = f.run();
  assert.equal(result.status, 0, result.stderr);
  assert.deepEqual(JSON.parse(readFileSync(f.settings, "utf8")), {
    ...original,
    ...defaults,
  });
  assert.equal(
    readFileSync(auth, "utf8"),
    "not credentials or valid auth JSON",
  );
  assert.equal(
    readFileSync(session, "utf8"),
    "session fixture must not change",
  );
});

test("creates settings for a fresh agent directory without creating credentials", (t) => {
  const f = fixture(t);
  const agentDir = join(f.root, "fresh", "agent");
  const result = f.run({ agentDir });
  assert.equal(result.status, 0, result.stderr);
  assert.deepEqual(
    JSON.parse(readFileSync(join(agentDir, "settings.json"), "utf8")),
    defaults,
  );
  assert.equal(existsSync(join(agentDir, "auth.json")), false);
});

test("updates the model when the provider is already correct", (t) => {
  const f = fixture(t);
  writeFileSync(
    f.settings,
    JSON.stringify({ ...defaults, defaultModel: "old-model" }),
  );
  const result = f.run();
  assert.equal(result.status, 0, result.stderr);
  assert.deepEqual(JSON.parse(readFileSync(f.settings, "utf8")), defaults);
});

test("does not rewrite settings when the defaults already match", (t) => {
  const f = fixture(t);
  const original = JSON.stringify({ ...defaults, deviceId: "fixture-device" });
  writeFileSync(f.settings, original);
  assert.equal(f.run().status, 0);
  assert.equal(f.run().status, 0);
  assert.equal(readFileSync(f.settings, "utf8"), original);
});

test("preflight leaves settings untouched without loading the SDK", (t) => {
  const f = fixture(t);
  const original = JSON.stringify({ defaultModel: "keep-until-activation" });
  writeFileSync(f.settings, original);
  const result = f.run({ check: true, sdk: join(f.root, "missing-sdk.mjs") });
  assert.equal(result.status, 0, result.stderr);
  assert.equal(readFileSync(f.settings, "utf8"), original);
  const absent = join(f.root, "missing", "agent");
  assert.equal(f.run({ check: true, agentDir: absent }).status, 0);
  assert.equal(existsSync(absent), false);
});

for (const content of ["{broken-json", "null", "42", "[]"]) {
  test(`rejects invalid settings without replacement: ${content}`, (t) => {
    const f = fixture(t);
    writeFileSync(f.settings, content);
    for (const check of [false, true]) {
      const result = f.run({ check });
      assert.notEqual(result.status, 0);
      assert.match(result.stderr, /not a JSON object/);
      assert.equal(readFileSync(f.settings, "utf8"), content);
    }
  });
}

for (const dangling of [false, true]) {
  test(`refuses a settings symlink, including dangling=${dangling}`, (t) => {
    const f = fixture(t);
    const target = join(f.root, "unmanaged.json");
    if (!dangling) writeFileSync(target, "{}");
    symlinkSync(target, f.settings);
    const result = f.run();
    assert.notEqual(result.status, 0);
    assert.match(result.stderr, /regular file/);
    assert.equal(readlinkSync(f.settings), target);
    if (!dangling) assert.equal(readFileSync(target, "utf8"), "{}");
  });
}

for (const invalid of [
  null,
  {},
  { defaultProvider: "", defaultModel: "model" },
  { defaultProvider: "openai", defaultModel: 5 },
  { defaultProvider: "openai", defaultModel: " " },
]) {
  test(`rejects invalid declarative defaults: ${JSON.stringify(invalid)}`, (t) => {
    const f = fixture(t);
    const path = join(f.root, "defaults.json");
    writeFileSync(path, JSON.stringify(invalid));
    const result = f.run({ defaults: path });
    assert.notEqual(result.status, 0);
    assert.match(result.stderr, /non-empty provider and model/);
    assert.equal(existsSync(f.settings), false);
  });
}

test("surfaces SDK load failures without touching preferences", (t) => {
  const f = fixture(t);
  const fakeSdk = join(f.root, "failed-sdk.mjs");
  writeFileSync(
    fakeSdk,
    `export const SettingsManager = {
    create() { return { drainErrors() { return ["fixture failure"]; } }; }
  };`,
  );
  const result = f.run({ sdk: fakeSdk });
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /safely load/);
  assert.equal(existsSync(f.settings), false);
});

test("surfaces queued SDK save failures instead of reporting success", (t) => {
  const f = fixture(t);
  const fakeSdk = join(f.root, "failed-save-sdk.mjs");
  writeFileSync(
    fakeSdk,
    `export const SettingsManager = {
    create() {
      let checks = 0;
      return {
        drainErrors() { return checks++ === 0 ? [] : ["fixture failure"]; },
        getDefaultProvider() { return "other"; },
        setDefaultModelAndProvider() {},
        async flush() {}
      };
    }
  };`,
  );
  const result = f.run({ sdk: fakeSdk });
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /persist Pi defaults/);
  assert.equal(existsSync(f.settings), false);
});
