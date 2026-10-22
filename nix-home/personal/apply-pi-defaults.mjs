import { lstatSync, readFileSync } from "node:fs";
import { join } from "node:path";
import { pathToFileURL } from "node:url";

const [sdkPath, defaultsPath, agentDir, mode] = process.argv.slice(2);
const defaults = JSON.parse(readFileSync(defaultsPath, "utf8"));
if (
  !defaults ||
  typeof defaults.defaultProvider !== "string" ||
  !defaults.defaultProvider.trim() ||
  typeof defaults.defaultModel !== "string" ||
  !defaults.defaultModel.trim()
) {
  throw new Error("Pi defaults must specify a non-empty provider and model.");
}

const settingsPath = join(agentDir, "settings.json");
const status = lstatSync(settingsPath, { throwIfNoEntry: false });
if (status) {
  if (!status.isFile()) {
    throw new Error(
      "Pi settings must be a regular file; refusing to replace it.",
    );
  }
  try {
    const current = JSON.parse(readFileSync(settingsPath, "utf8"));
    if (!current || typeof current !== "object" || Array.isArray(current)) {
      throw new Error();
    }
  } catch {
    throw new Error(
      "Pi settings are not a JSON object; leaving them unchanged.",
    );
  }
}

if (mode !== "--check") {
  const { SettingsManager } = await import(pathToFileURL(sdkPath).href);
  const settings = SettingsManager.create(process.cwd(), agentDir, {
    projectTrusted: false,
  });
  if (settings.drainErrors().length) {
    throw new Error("Could not safely load Pi settings.");
  }
  if (
    settings.getDefaultProvider() !== defaults.defaultProvider ||
    settings.getDefaultModel() !== defaults.defaultModel
  ) {
    settings.setDefaultModelAndProvider(
      defaults.defaultProvider,
      defaults.defaultModel,
    );
    await settings.flush();
    if (settings.drainErrors().length) {
      throw new Error("Could not persist Pi defaults.");
    }
  }
}
