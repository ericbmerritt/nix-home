{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./secrets/default.nix
    ./helix/default.nix
    ./zellij/default.nix
  ];

  home.packages = with pkgs; [
    jq
    moreutils
    ripgrep
    wget
    efm-langserver
    nodePackages_latest.vscode-langservers-extracted
    nodePackages_latest.yaml-language-server
    nodePackages_latest.typescript-language-server
    nodePackages_latest.prettier
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
  ];

  programs = {
    starship = {
      enable = true;
      settings = {
        format = "$directory\${custom.jj}$git_branch$git_status$python$nodejs$rust$nix_shell$cmd_duration$line_break$character";

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

        custom.jj = {
          command = "jj log -r @ -n1 --ignore-working-copy --no-graph --color always -T 'separate(\" \", change_id.shortest(8), bookmarks)'";
          when = "jj root";
          format = "[on  $output]($style) ";
          style = "bold purple";
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
        PATH = "$PATH:${config.home.homeDirectory}/go/bin:${config.home.homeDirectory}/.local/bin:${config.home.homeDirectory}/.cargo/bin";
      };
    };

    command-not-found.enable = true;

    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
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
          name = "Eric B. Merritt";
          email = "eric@merritt.tech";
        };
      };
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultCommand = "${pkgs.fd}/bin/fd --type f --hidden --follow --exclude .git";
    };

    jujutsu = {
      enable = true;
      settings = {
        user = {
          name = "Eric B. Merritt";
          email = "eric@merritt.tech";
        };
        aliases = {
          n = ["edit" "@+"];
          p = ["edit" "@-"];
          top = ["edit" "latest(descendants(@) & mutable())"];
          bottom = ["edit" "roots(ancestors(@) & mutable())"];
          stack = ["log" "-r" "ancestors(@) & descendants(@) & open()"];
        };
        ui = {
          merge-editor = ["${pkgs.meld}/bin/meld" "$left" "$base" "$right" "-o" "$output"];
          diff-formatter = ["${pkgs.difftastic}/bin/difft" "--color=always" "$left" "$right"];
        };
      };
    };

    ssh = {
      enable = true;
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
