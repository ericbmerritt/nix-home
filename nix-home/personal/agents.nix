{
  config,
  lib,
  pkgs,
  agentPackages,
  ...
}: let
  applyDefaults = lib.escapeShellArgs [
    "${pkgs.nodejs_24}/bin/node"
    "${./apply-pi-defaults.mjs}"
    "${agentPackages.pi-coding-agent}/lib/node_modules/pi-monorepo/dist/index.js"
    "${./pi-settings.json}"
    "${config.home.homeDirectory}/.pi/agent"
  ];
in {
  home.packages = [agentPackages.herdr agentPackages.pi-coding-agent];

  # Pi writes its device ID and UI preferences here; a store symlink would break that.
  home.activation = {
    checkPiSettings = lib.hm.dag.entryBefore ["writeBoundary"] ''
      ${pkgs.coreutils}/bin/env PI_OFFLINE=1 PI_TELEMETRY=0 ${applyDefaults} --check
    '';
    piDefaults = lib.hm.dag.entryAfter ["writeBoundary"] ''
      run ${pkgs.coreutils}/bin/env PI_OFFLINE=1 PI_TELEMETRY=0 ${applyDefaults}
    '';
  };
}
