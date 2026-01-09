{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.programs.gsd;
  gsdShare = "${cfg.package}/share/gsd";
in {
  options.programs.gsd = {
    enable = mkEnableOption "Get Shit Done - context engineering for Claude Code";

    package = mkOption {
      type = types.package;
      default = pkgs.gsd;
      description = "The gsd package to use";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [cfg.package];

    home.file = {
      # Agents
      ".claude/agents/gsd-codebase-mapper.md".source = "${gsdShare}/agents/gsd-codebase-mapper.md";
      ".claude/agents/gsd-debugger.md".source = "${gsdShare}/agents/gsd-debugger.md";
      ".claude/agents/gsd-executor.md".source = "${gsdShare}/agents/gsd-executor.md";
      ".claude/agents/gsd-integration-checker.md".source = "${gsdShare}/agents/gsd-integration-checker.md";
      ".claude/agents/gsd-phase-researcher.md".source = "${gsdShare}/agents/gsd-phase-researcher.md";
      ".claude/agents/gsd-plan-checker.md".source = "${gsdShare}/agents/gsd-plan-checker.md";
      ".claude/agents/gsd-planner.md".source = "${gsdShare}/agents/gsd-planner.md";
      ".claude/agents/gsd-project-researcher.md".source = "${gsdShare}/agents/gsd-project-researcher.md";
      ".claude/agents/gsd-research-synthesizer.md".source = "${gsdShare}/agents/gsd-research-synthesizer.md";
      ".claude/agents/gsd-roadmapper.md".source = "${gsdShare}/agents/gsd-roadmapper.md";
      ".claude/agents/gsd-verifier.md".source = "${gsdShare}/agents/gsd-verifier.md";

      # Commands
      ".claude/commands/gsd".source = "${gsdShare}/commands/gsd";

      # Templates and workflows
      ".claude/get-shit-done".source = "${gsdShare}/get-shit-done";

      # Version marker
      ".claude/get-shit-done/VERSION".text = cfg.package.version;
    };
  };
}
