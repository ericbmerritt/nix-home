{config}: let
  home = config.home-manager.users.eric;
  identity = {
    name = "Eric Merritt";
    email = "eric@merritt.tech";
  };
  packageNames = map (package: package.pname or package.name) home.home.packages;
in [
  {
    assertion = home.programs.jujutsu.enable && home.programs.git.enable && home.programs.jujutsu.settings.user == identity && home.programs.git.settings.user == identity;
    message = "The personal profile must provide Git and JJ with Eric's personal identity.";
  }
  {
    assertion = home.programs.helix.enable && home.programs.zellij.enable && home.programs.neovim.enable && home.programs.starship.enable && home.programs.zsh.enable && home.programs.direnv.enable && home.programs.fzf.enable && home.programs.ssh.enable && home.programs.command-not-found.enable;
    message = "Lascasas must consume the portable common programs, not just the agent module.";
  }
  {
    assertion = home.home.sessionPath == ["/home/eric/go/bin" "/home/eric/.local/bin" "/home/eric/.cargo/bin"] && !home.programs.wezterm.enable && !builtins.elem "meld" packageNames && !builtins.elem "cmux" packageNames && !(home.home.activation ? disableCmuxSparkle);
    message = "The headless personal profile must not inherit desktop apps or Darwin paths and activation.";
  }
  {
    assertion = home.programs.ssh.includes == [] && !(home.programs.ssh.settings ? "github.dev.pages") && home.programs.ssh.settings."github.com".data.IdentityFile == "~/.ssh/id_ed25519" && home.programs.ssh.settings."*".data.AddKeysToAgent == "yes" && (home.nix.settings.netrc-file or null) == null;
    message = "Personal SSH must keep the public GitHub settings without company, Colima, or Determinate configuration.";
  }
  {
    assertion = config.programs.zsh.enable && home.programs.bash.enable && config.users.users.eric.shell.shellPath == "/bin/bash" && config.users.users.eric.shell == config.users.defaultUserShell;
    message = "Zsh must be available without changing the existing default login shell.";
  }
]
