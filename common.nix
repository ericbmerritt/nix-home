{pkgs, ...}: let
  glab = pkgs.callPackage ./glab {};
in {
  imports = [./services/ngrok.nix];

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
    pkgs.wezterm
    pkgs.nodePackages_latest.prettier
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

  programs.helix = {
    enable = true;
    languages = 
      {
        language = [
          {
            name = "markdown";
            scope = "source.md";
            injection-regex = "md|markdown";
            file-types = ["md" "markdown" "PULLREQ_EDITMSG"];
            language-server = {
              command = "${pkgs.efm-langserver}/bin/efm-langserver";
              args = [];
            };
            indent = {
              tab-width = 2;
              unit = "  ";
            };
          }
          {
            name = "json";
            scope = "source.json";
            injection-regex = "json";
            file-types = ["json" "jsonc" "arb" "jtd"];
            roots = [];
            language-server = {
              command = "${pkgs.nodePackages_latest.vscode-json-languageserver-bin}/bin/json-languageserver";
              args = ["--stdio"];
            };
            auto-format = true;
            config = {"provideFormatter" = true;};
            indent = {
              tab-width = 2;
              unit = "  ";
            };
          }
          {
            name = "typescript";
            scope = "source.ts";
            injection-regex = "(ts|typescript)";
            file-types = ["ts" "mts" "cts"];
            shebangs = [];
            roots = [];
            language-server = {
              command = "${pkgs.nodePackages_latest.typescript-language-server}/bin/typescript-language-server";
              args = ["--stdio"];
              language-id = "typescript";
            };
            indent = {
              tab-width = 2;
              unit = "  ";
            };
            auto-format = true;
            formatter = {
              command = "${pkgs.nodePackages_latest.prettier}/bin/prettier";
              args = ["--stdin-filepath" "tmp.ts" "--"];
            };
          }
          {
            name = "rust";
            config = {
              cachePriming = {enable = false;};
              diagnostics = {experimental = {enable = true;};};
            };
            language-server = {
              rust-analyzer = {
                config = {
                  check = {
                    command = "clippy";
                  };
                };
              };
            };
          }
        ];
      };
    settings = {
      theme = "penumbra+";
      editor = {
        line-number = "relative";
        mouse = true;
        auto-save = true;
        rulers = [80 120];
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
        file-picker = {
          hidden = false;
        };
        statusline = {
          left = ["mode" "spinner"];
          center = ["file-name"];
          right = ["diagnostics" "selections" "position" "file-encoding" "file-line-ending" "file-type"];
          separator = "│";
        };
        lsp = {
          display-inlay-hints = true;
        };
        whitespace = {
          render = {
            newline = "all";
          };
        };
      };
      keys = {
        insert = {
          esc = ["normal_mode" ":w"];
        };
      };
    };
  };

  home.file = {".tmux.conf" = {source = ./tmux.conf;};};
}
