{pkgs, ...}: {
  programs.helix = {
    enable = true;
    languages = {
      language-server = {
        vale-lsp = {
          command = "vale-ls";
          config = {};
          args = [];
        };
        rst-lsp = {
          command = "esbonio";
          config = {};
          args = [];
        };
        efm = {
          command = "${pkgs.efm-langserver}/bin/efm-langserver";
          args = [];
        };
        pyright = {
          command = "pyright-langserver";
          config = {};
          args = ["--stdio"];
        };
        ruff-lsp = {
          command = "ruff-lsp";
          args = [];
          config = {
            settings = {
              args = "--preview";
              run = "onSave";
            };
          };
        };
        json = {
          command = "${pkgs.nodePackages_latest.vscode-langservers-extracted}/bin/json-languageserver";
          args = ["--stdio"];
          config = {"provideFormatter" = true;};
        };
        html = {
          command = "${pkgs.nodePackages_latest.vscode-langservers-extracted}/bin/html-languageserver";
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
        yaml = {
          command = "yaml-language-server";
          args = ["--stdio"];
          config = {
            yaml = {
              validate = true;
              schemaStore = {enable = true;};
              schemas = {Taskfile = "/*-task.yaml";};
              format = {enable = true;};
            };
          };
        };
      };
      grammar = [
        {
          name = "htmldjango";
          source = {
            git = "https://github.com/interdependence/tree-sitter-htmldjango";
            rev = "8873e3df89f9ea1d33f6235e516b600009288557";
          };
        }
      ];

      language = [
        {
          name = "htmldjango";
          auto-format = true;
          roots = [];
          scope = "source.htmldjango";
          injection-regex = "python";
          file-types = ["djt"];
          indent = {
            tab-width = 4;
            unit = "    ";
          };

          formatter = {
            command = "${pkgs.djlint}/bin/djlint";
            args = ["-" "--reformat" "--quiet"];
          };
          language-servers = [];
        }
        {
          name = "python";
          auto-format = true;
          roots = ["pyproject.toml" "requirements.txt" "setup.py"];
          scope = "source.python";
          injection-regex = "python";
          file-types = ["py" "pyi" "py3" "pyw" "ptl" ".pythonstartup" ".pythonrc" "SConstruct"];
          shebangs = ["python"];
          comment-token = "#";
          indent = {
            tab-width = 4;
            unit = "    ";
          };
          formatter = {
            command = "ruff";
            args = ["format" "-"];
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
          name = "rst";
          scope = "source.rst";
          injection-regex = "rst";
          file-types = ["rst"];
          language-servers = ["vale-lsp" "rst-lsp"];
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
          name = "html";
          scope = "source.html";
          injection-regex = "html";
          file-types = ["html"];
          roots = [];
          language-servers = ["html"];
          auto-format = true;
          indent = {
            tab-width = 2;
            unit = "  ";
          };
        }
        {
          name = "yaml";
          file-types = ["yaml" "yml"];
          language-servers = ["yaml"];
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
          language-servers = ["typescript" "gpt"];
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
          language-servers = ["rust" "gpt"];
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
}
