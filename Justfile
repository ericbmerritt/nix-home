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
check-format: check-for-trailing-whitespace check-format-nix check-format-python

# Format all code
format: remove-trailing-whitespace format-nix format-python

# Lint all code
lint: lint-nix lint-python check-types-python

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

check-personal-inputs:
    python3 -m unittest discover -s tests -p test_personal_inputs.py

eval-personal:
    nix flake check --no-build --no-write-lock-file .

eval-work:
    nix flake check --no-build --no-write-lock-file ./flakes/work

eval-hosts: eval-personal eval-work

# Run from the GitHub-backed checkout on lascasas, without activation.
build-linux:
    @test "$(uname -s)" = Linux || { echo "Run build-linux from the repository checkout on lascasas." >&2; exit 1; }
    nix build --no-link --no-write-lock-file '.#nixosConfigurations.lascasas.config.system.build.toplevel'
