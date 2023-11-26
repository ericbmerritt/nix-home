{pkgs, ...}: let
  ihp-new = pkgs.callPackage ./ihp-new {};
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
    pkgs.lazygit
    ihp-new
    pkgs.cachix
    pkgs.fossil
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

  programs.wezterm = {
    enable = true;
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

  programs.zellij = {
    enable = true;
    enableZshIntegration = true;
  };

  xdg.configFile."zellij/layouts/landbaron.kdl" = {
    enable = true;
    text = ''
      layout {
        pane size=1 borderless=true {
          plugin location="zellij:tab-bar"
        }
        pane split_direction="vertical" {
          pane split_direction="horizontal" {
            pane {
              cwd "workspace/landbaron"
            }
            pane {
              cwd "workspace/landbaron"
              command "lazygit"
            }
          }
          pane {
            cwd "workspace/landbaron"
          }
        }
        pane size=2 borderless=true {
          plugin location="zellij:status-bar"
        }
      }
    '';
  };

  xdg.configFile."zellij/layouts/blowingupbarriers.kdl" = {
    enable = true;
    text = ''
      layout {
        pane size=1 borderless=true {
          plugin location="zellij:tab-bar"
        }
        pane split_direction="vertical" {
          pane split_direction="horizontal" {
            pane {
              cwd "workspace/blowingupbarriers"
            }
            pane {
              cwd "workspace/blowingupbarriers"
              command "lazygit"
            }
          }
          pane {
            cwd "workspace/blowingupbarriers"
          }
        }
        pane size=2 borderless=true {
          plugin location="zellij:status-bar"
        }
      }
    '';
  };

  programs.helix = {
    enable = true;
    languages = {
      language-server = {
        vale-lsp = {
          command = "vale-ls";
          args = [];
        };
        efm = {
          command = "${pkgs.efm-langserver}/bin/efm-langserver";
          args = [];
        };
        pyright = {
          command = "pyright-langserver";
          args = ["--stdio"];
        };
        ruff-lsp = {
          command = "ruff-lsp";
          args = [];
        };
        json = {
          command = "${pkgs.nodePackages_latest.vscode-json-languageserver-bin}/bin/json-languageserver";
          args = ["--stdio"];
          config = {"provideFormatter" = true;};
        };
        typescript = {
          command = "${pkgs.nodePackages_latest.typescript-language-server}/bin/typescript-language-server";
          args = ["--stdio"];
          language-id = "typescript";
        };
        rust = {
          command = "rust-analyzer";
          config = {
            cachePriming = {enable = false;};
            diagnostics = {experimental = {enable = true;};};
          };
          rust-analyzer = {
            config = {
              check = {
                command = "clippy";
              };
            };
          };
        };
      };
      language = [
        {
          name = "python";
          formatter = {
            command = "black";
            args = ["--quiet" "-"];
          };
          auto-format = true;
          roots = ["requirements.txt"];
          scope = "source.python";
          injection-regex = "python";
          file-types = ["py" "pyi" "py3" "pyw" "ptl" ".pythonstartup" ".pythonrc" "SConstruct"];
          shebangs = ["python"];
          comment-token = "#";
          indent = {
            tab-width = 4;
            unit = "    ";
          };
          language-servers = ["pyright" "ruff-lsp" "vale-lsp"];
        }
        {
          name = "markdown";
          scope = "source.md";
          injection-regex = "md|markdown";
          file-types = ["md" "markdown" "PULLREQ_EDITMSG"];
          language-servers = ["efm"];
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
          language-servers = ["json"];
          auto-format = true;
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
          language-servers = ["typescript"];
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
          auto-format = true;
          language-servers = ["rust"];
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
