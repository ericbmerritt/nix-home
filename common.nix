{pkgs, ...}: let
  git-branchless = import ./git-branchless/default.nix {inherit pkgs;};
  git-absorb = import ./git-absorb/default.nix {inherit pkgs;};
in {
  imports = [
    ./services/ngrok.nix
    ./secrets/default.nix
    ./helix/default.nix
    ./emacs/default.nix
  ];

  home.packages = with pkgs; [
    tmux
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
    nushell
    alejandra
    devenv
    direnv
    python3
    fzf
    tree
    fd
    meld
    jujutsu
    git-branchless
    git-absorb
  ];

  home.file.".config/nushell/env.nu".text = ''
      mkdir ~/.cache/carapace
      carapace _carapace nushell | save --force ~/.cache/carapace/init.nu
      open ~/.config/secrets/secrets.nu | from toml | load-env
      do --env {
        let ssh_agent_file = (
            $nu.temp-path | path join $"ssh-agent-($env.USER).nuon"
        )

        if ($ssh_agent_file | path exists) {
            let ssh_agent_env = open ($ssh_agent_file)
            if ($"/proc/($ssh_agent_env.SSH_AGENT_PID)" | path exists) {
                load-env $ssh_agent_env
                return
            } else {
                rm $ssh_agent_file
            }
        }

        let ssh_agent_env = ^ssh-agent -c
          | lines
          | first 2
          | parse "setenv {name} {value};"
          | transpose --header-row
          | into record
        load-env $ssh_agent_env
        $ssh_agent_env | save --force $ssh_agent_file
    }
  '';
  programs.nushell = {
    enable = true;
    # for editing directly to config.nu
    extraConfig = ''
       let carapace_completer = {|spans|
          carapace $spans.0 nushell $spans | from json
       }
       $env.config = {
         show_banner: false,
         completions: {
         case_sensitive: false # case-sensitive completions
           quick: true    # set to false to prevent auto-selecting completions
           partial: true    # set to false to prevent partial filling of the prompt
           algorithm: "fuzzy"    # prefix or fuzzy
           external: {
              # set to false to prevent nushell looking into $env.PATH to find more suggestions
              enable: true
              # set to lower can improve completion performance at the cost of omitting some options
              max_results: 100
              completer: $carapace_completer # check 'carapace_completer'
           }
         }
         hooks: {
           pre_prompt: [{ ||
             if (which direnv | is-empty) {
                return
             }

             direnv export json | from json | default {} | load-env
           }]
         }
      }
    '';
    shellAliases = {
      vi = "hx";
      vim = "hx";
      nano = "hx";
    };
  };
  programs.carapace = {
    enable = true;
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      command_timeout = 3000;
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
    };
  };

  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      theme = "bira";
    };
    sessionVariables = {
      EDITOR = "${pkgs.helix}/bin/hx";
      ZSH_DISABLE_COMPFIX = "true";
    };
  };

  programs.command-not-found.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    plugins = with pkgs.vimPlugins; [
      LazyVim
    ];
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv = {enable = true;};
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
    defaultCommand = "${pkgs.fd}/bin/fd --type f --hidden --follow --exclude .git";
  };

  programs.wezterm = {
    enable = false;
    extraConfig = ''

      local wezterm = require 'wezterm'
      local config = {}

      if wezterm.config_builder then
        config = wezterm.config_builder()
      end

      config.enable_tab_bar = false

      return config
    '';
  };
}
