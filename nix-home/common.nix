{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./helix/default.nix
    ./wezterm/default.nix
    ./zellij/default.nix
  ];

  # whitepages-nix's work module points netrc-file at ~/.config/nix/netrc, but
  # Determinate Nix owns netrc and refuses to authenticate while the option
  # names any other path (`determinate-nixd status` errors, FlakeHub logs out).
  # The dev-cache credentials get merged into Determinate's file instead, via
  # authentication.additionalNetrcSources in /etc/determinate/config.json.
  nix.settings.netrc-file = lib.mkForce "/nix/var/determinate/netrc";

  home.sessionPath = [
    "${config.home.homeDirectory}/go/bin"
    "${config.home.homeDirectory}/.local/bin"
    "${config.home.homeDirectory}/.cargo/bin"
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
  ];

  home.packages = with pkgs; [
    awscli2
    jq
    moreutils
    ripgrep
    wget
    efm-langserver
    vscode-langservers-extracted
    yaml-language-server
    typescript-language-server
    prettier
    cachix
    alejandra
    devenv
    python3
    tree
    fd
    meld
    kubectl
    kubernetes-helm
    podman
    lazyjj
    codex
    jjui
    difftastic
    pi-coding-agent
  ];

  programs = {
    starship = {
      enable = true;
      settings = {
        format = "$directory$git_branch$git_status$python$nodejs$rust$nix_shell$cmd_duration$line_break$character";

        character = {
          success_symbol = "[❯](bold green) ";
          error_symbol = "[❯](bold red) ";
        };

        directory = {
          style = "bold blue";
          truncation_length = 3;
          truncate_to_repo = true;
          format = "[ $path]($style)[$read_only]($read_only_style) ";
        };

        git_branch = {
          symbol = " ";
          style = "bold purple";
          format = "[on $symbol$branch]($style) ";
        };

        git_status = {
          style = "bold red";
          format = "[$all_status$ahead_behind]($style) ";
        };

        python = {
          symbol = " ";
          style = "bold yellow";
          format = "[$symbol$version]($style) ";
        };

        nodejs = {
          symbol = " ";
          style = "bold green";
          format = "[$symbol$version]($style) ";
        };

        rust = {
          symbol = " ";
          style = "bold orange";
          format = "[$symbol$version]($style) ";
        };

        nix_shell = {
          symbol = " ";
          style = "bold blue";
          format = "[$symbol$state]($style) ";
        };

        cmd_duration = {
          min_time = 2000;
          style = "bold yellow";
          format = "[took $duration]($style) ";
        };
      };
    };

    zsh = {
      enable = true;
      oh-my-zsh = {
        enable = true;
        theme = ""; # disabled, using starship
      };
      sessionVariables = {
        EDITOR = "${pkgs.helix}/bin/hx";
        ZSH_DISABLE_COMPFIX = "true";
      };
    };

    jujutsu = {
      enable = true;
      settings = {
        user = {
          name = "Eric Merritt";
          email = "emerritt@whitepages.com";
        };
      };
    };

    command-not-found.enable = true;

    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      withRuby = false;
      withPython3 = false;
      plugins = with pkgs.vimPlugins; [
        LazyVim
      ];
    };

    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv = {enable = true;};
    };

    git = {
      enable = true;
      settings = {
        user = {
          name = "Eric Merritt";
          email = "emerritt@whitepages.com";
        };
      };
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultCommand = "${pkgs.fd}/bin/fd --type f --hidden --follow --exclude .git";
    };

    ssh = {
      enable = true;
      # Opt out of home-manager's implicit `*` defaults (deprecated); we set
      # only what we actually want in matchBlocks."*" below.
      enableDefaultConfig = false;
      includes = [
        "${config.home.homeDirectory}/.colima/ssh_config"
      ];
      matchBlocks = {
        "*" = {
          addKeysToAgent = "yes";
        };
        "github.com" = {
          identityFile = "~/.ssh/id_ed25519";
        };
        "github.dev.pages" = {
          identityFile = "~/.ssh/id_ed25519";
        };
        "lascasas" = {
          hostname = "lascasas";
          user = "eric";
        };
      };
    };
  };
}
