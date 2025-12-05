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
check-format: check-for-trailing-whitespace check-format-nix

# Format all code
format: remove-trailing-whitespace format-nix

# Lint all code
lint: lint-nix

# Run all validation commands
validate: check-format lint
