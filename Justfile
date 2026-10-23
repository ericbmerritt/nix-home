# List available recipes
default:
    @just --list

# Check for trailing whitespace
check-for-trailing-whitespace:
    ! rg '\s+$'

# Check formatting on all nix code
check-format-nix:
    rg --files -g '*.nix' -g '!.*' | xargs alejandra -c

# Lint all nix code
lint-nix:
    rg --files -g '*.nix' -g '!.*' | xargs -L 1 statix check --

# Format all nix code
format-nix:
    rg --files -g '*.nix' -g '!.*' | xargs alejandra

# Remove trailing whitespace
remove-trailing-whitespace:
    files=$(rg -l "\s+$"); \
    if [ -n "$files" ]; then \
        echo "$files" | xargs sed --in-place "s/[[:space:]]\+$//"; \
    fi


# Check if all code has been formatted
check-format: check-for-trailing-whitespace check-format-nix check-format-python check-format-javascript

# Format all code
format: remove-trailing-whitespace format-nix format-python format-javascript

# Lint all code
lint: lint-nix lint-python check-types-python check-javascript

# Run all validation commands
validate: check-format lint test eval-personal

# Build the work laptop without activating it or changing result symlinks.
build-work-mac:
    nix build --no-link --no-write-lock-file './flakes/work#darwinConfigurations.wp-K942Q6VXR7.system'

check-format-python:
    ruff format --check tests

format-python:
    ruff format tests

lint-python:
    ruff check tests

check-types-python:
    mypy --strict tests

test:
    python3 -m unittest discover -s tests
    node --test --experimental-test-coverage --test-coverage-include='**/apply-pi-defaults.mjs' --test-coverage-lines=90 --test-coverage-branches=90 --test-coverage-functions=90 tests/pi-defaults.test.mjs

check-format-javascript:
    prettier --check nix-home/personal/*.mjs nix-home/personal/*.json tests/*.mjs

format-javascript:
    prettier --write nix-home/personal/*.mjs nix-home/personal/*.json tests/*.mjs

check-javascript:
    node --check nix-home/personal/apply-pi-defaults.mjs
    node --check tests/pi-defaults.test.mjs

check-personal-inputs:
    python3 -m unittest discover -s tests -p test_personal_inputs.py

eval-personal:
    nix flake check --no-build --no-write-lock-file .

eval-work:
    nix flake check --no-build --no-write-lock-file ./flakes/work

eval-hosts: eval-personal eval-work

check-personal-settings: eval-personal

# Check the public agent executables on Linux without model credentials.
smoke-agents:
    @test "$(uname -s)" = Linux || { echo "Run smoke-agents on lascasas." >&2; exit 1; }
    nix run --no-write-lock-file .#herdr -- --version
    nix run --no-write-lock-file .#pi-coding-agent -- --version
    nix run --no-write-lock-file .#herdr -- --help >/dev/null
    nix run --no-write-lock-file .#pi-coding-agent -- --help >/dev/null

# Validate the staged portable profile, including JJ identity, before activation.
smoke-personal-linux:
    #!/usr/bin/env bash
    set -euo pipefail
    test "$(uname -s)" = Linux || { echo "Run smoke-personal-linux on lascasas." >&2; exit 1; }
    generation=$(nix eval --raw --no-write-lock-file '.#nixosConfigurations.lascasas.config.home-manager.users.eric.home.activationPackage')
    profile=$(nix eval --raw --no-write-lock-file '.#nixosConfigurations.lascasas.config.home-manager.users.eric.home.path')
    export PATH="$profile/bin:$PATH"
    jj --version
    test "$(jj --config-file "$generation/home-files/.config/jj/config.toml" config get user.name)" = 'Eric Merritt'
    test "$(jj --config-file "$generation/home-files/.config/jj/config.toml" config get user.email)" = 'eric@merritt.tech'
    test "$(git config --file "$generation/home-files/.config/git/config" --get user.email)" = 'eric@merritt.tech'
    zsh -n "$generation/home-files/.zshrc"
    bash -n "$generation/home-files/.bashrc"
    XDG_CONFIG_HOME="$generation/home-files/.config" hx --health
    nvim --version
    zellij --version
    codex --version
    direnv version
    fzf --version

# Read-only settings preflight and Home Manager collision/dry-run checks.
check-home-linux:
    @test "$(uname -s)" = Linux || { echo "Run check-home-linux on lascasas." >&2; exit 1; }
    node nix-home/personal/apply-pi-defaults.mjs "$PI_SETTINGS_SDK" nix-home/personal/pi-settings.json "$HOME/.pi/agent" --check
    nix build --no-link --no-write-lock-file '.#nixosConfigurations.lascasas.config.home-manager.users.eric.home.activationPackage'
    generation=$(nix eval --raw --no-write-lock-file '.#nixosConfigurations.lascasas.config.home-manager.users.eric.home.activationPackage'); DRY_RUN=1 VERBOSE=1 "$generation/activate" --driver-version 1

# Run from the GitHub-backed checkout on lascasas, without activation.
build-linux:
    @test "$(uname -s)" = Linux || { echo "Run build-linux from the repository checkout on lascasas." >&2; exit 1; }
    nix build --no-link --no-write-lock-file '.#nixosConfigurations.lascasas.config.system.build.toplevel'
