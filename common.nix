{ pkgs, ... }:
let glab = (pkgs.callPackage ./glab { });
in {
  imports = [ ./services/ngrok.nix ];

  home.packages = [
    pkgs.tmux
    pkgs.jq
    pkgs.moreutils
    pkgs.nixFlakes
    pkgs.ripgrep
    pkgs.flyctl
    pkgs.nushell
    pkgs.wget
    pkgs.efm-langserver
    pkgs.nodePackages_latest.vscode-json-languageserver-bin
    pkgs.nodePackages_latest.yaml-language-server
    pkgs.nodePackages_latest.typescript-language-server
    pkgs.taplo
    pkgs.helix
    pkgs.wezterm
];
  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      theme = "bira";
    };
    sessionVariables = {
      EDITOR = "${pkgs.neovim}/bin/nvim";
      ZSH_DISABLE_COMPFIX = "true";
    };

    initExtra = ''
      . $HOME/.nvm/nvm.sh

      autoload -Uz compinit bashcompinit
      compinit
      bashcompinit
    '';
  };

  programs.command-not-found.enable = true;

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv = { enable = true; };
  };

  programs.git = {
    package = pkgs.gitAndTools.gitFull;
    enable = true;
    userName = "Eric B. Merritt";
    userEmail = "eric@merritt.tech";
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    defaultCommand =
      "${pkgs.fd}/bin/fd --type f --hidden --follow --exclude .git";
  };

  home.file = { ".tmux.conf" = { source = ./tmux.conf; }; };

}
