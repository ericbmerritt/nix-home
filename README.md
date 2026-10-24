# Personal and work Nix configurations

One repository, separate dependency graphs: the root flake is personal; `flakes/work/` supplies private inputs and wiring for the Whitepages laptop. Machine-specific configuration lives uniformly under `hosts/`.

## Entry points

| Machine | Host module | Flake | Output |
|---|---|---|---|
| Lascasas | `hosts/lascasas/` | `.` | `nixosConfigurations.lascasas` |
| Whitepages laptop | `hosts/wp-K942Q6VXR7/` | `./flakes/work` | `darwinConfigurations.wp-K942Q6VXR7` |
| Personal Mac | Not configured yet | Personal root | Requires its real hostname, user, Nix ownership, and existing state versions |

**Do not use the work entry point on personal machines.** Moving the laptop entry point changes the old root-based rebuild command.

Lascasas keeps its verified NixOS base and adds the selected personal tools described below. Both current hosts import the portable `nix-home/common.nix` through Home Manager. Platform, desktop, and work settings are selected separately. The older `r630.nix` and `mac-osx.nix` wrappers are not active host configurations.

## Develop and validate

Prerequisites: Nix with flakes enabled and jj. Use jj directly; there is no managed stack requirement. Publish changes through a named bookmark so each machine builds the same GitHub revision.

```bash
nix develop
just validate
```

These checks use only the personal graph. The developer shell supplies the formatters, linters, Python, Node.js, and task runner; jj remains the host prerequisite so the shell does not silently select a different jj version for this checkout.

Work-laptop checks require company SSH access:

```bash
just eval-hosts
just build-work-mac
```

`checks/work-laptop-baseline.json` records evaluated pins, package names/versions, host/user settings, managed filenames, and activation job names before the entry-point split. Work checks reject unexplained changes to that baseline. This is configuration evidence, not proof that every tool's runtime behavior is unchanged. The separate running-generation record is in `checks/host-baselines.json`.

## Publish and build from GitHub

On the Mac, describe the current jj change and publish the WIP bookmark:

```bash
jj bookmark set shared-personal-flake -r @
jj git push --remote origin --bookmark shared-personal-flake
```

On lascasas, clone that bookmark into a normal checkout using its personal GitHub SSH key, unlocked in the SSH agent. If jj is not installed yet, first enter `nix-shell -p jujutsu`.

```bash
jj git clone --colocate --branch shared-personal-flake git@github.com:ericbmerritt/nix-home.git ~/nix-home
cd ~/nix-home
nix develop -c just build-linux
```

For later updates, start from a clean checkout:

```bash
jj git fetch --remote origin
jj new shared-personal-flake@origin
nix develop -c just build-linux
```

`build-linux` is a native build recipe: run it from the checkout on lascasas, not from the Mac. It does not transfer source files over SSH or require sudo.

No build recipe changes `/etc/nixos`, activates a generation, changes boot defaults, or reboots either host. Deployment remains an explicit, separately approved step after reviewing the evaluated diff and Home Manager dry run where applicable.

## Shared personal environment

| Configuration | Owner |
|---|---|
| Public CLI packages, Git/JJ enablement, Helix, Neovim, Zellij, Starship, Zsh, direnv, fzf, and public SSH preferences | `nix-home/common.nix`, imported by both hosts |
| WezTerm and Meld | Explicit `nix-home/desktop.nix`, not selected on lascasas |
| Homebrew paths, Colima SSH include, and cmux updater action | Explicit `nix-home/darwin.nix`, not selected on Linux |
| Git/JJ identity | Each host's home configuration: personal email on lascasas, work email on the laptop |
| Enterprise SSH and Determinate netrc integration | Work-laptop host only |

Lascasas keeps Bash as its login shell. Home Manager configures its Bash startup to load the user environment and shell integrations; Zsh is also configured and available. No password, SSH host key, private key, or provider credential is managed here.

Before activation, `nix develop -c just smoke-personal-linux` checks the staged Git/JJ identity, shell syntax, and portable executables. `check-home-linux` still checks unmanaged-file collisions rather than overwriting them.

## Personal coding agents on lascasas

The root exports `herdr` and `pi-coding-agent` packages. `hosts/lascasas/home.nix` selects the reusable personal module in `nix-home/personal/agents.nix`, which owns those packages through Home Manager. Home Manager uses the base system's package set and installs its user profile through `/etc/profiles/per-user/eric`; only the agent executables use `agent-nixpkgs`. No work profile, company agent policies, provider credentials, or Mac Pi configuration is copied.

`nix-home/personal/pi-settings.json` is the source of truth for Pi's startup provider and model. Activation uses Pi's pinned SDK to merge only those two settings into the user's writable `~/.pi/agent/settings.json`. Pi's device ID and other preferences are preserved; `auth.json` and sessions are not managed. Changes made in Pi's UI remain writable, but the next activation reapplies the declarative defaults. Existing or resumed sessions can retain their own model selection.

The settings preflight refuses malformed JSON or a symlink instead of replacing it. Home Manager's ordinary file-collision checks remain enabled; this configuration does not force replacements or overwrite backups.

Before activation, check the packaged CLIs from the Linux checkout:

```bash
nix develop -c just smoke-agents check-home-linux
```

After activation, use a fresh login so the per-user packages are on `PATH`. Start `pi` and use `/login` with a personal provider account. Credentials stay in the user's private Pi configuration, outside Nix.

Once Pi has created `~/.pi/agent`, install Herdr's bundled public integration:

```bash
herdr integration install pi
herdr integration status
```

Restart Pi after installing the integration. Launch `herdr` in the project directory, then run `pi` in a pane. Neither application is configured to start automatically at boot.

## SSH agent on lascasas

`programs.ssh.startAgent` enables NixOS's user `ssh-agent` service at login, with its socket at `$XDG_RUNTIME_DIR/ssh-agent`. After activating the configuration, use a fresh Linux login session and unlock the key there:

```bash
ssh-add ~/.ssh/id_ed25519
```

Lascasas's SSH client sets `IdentityAgent /run/user/%i/ssh-agent` (`%i` is the local UID). SSH and Git using OpenSSH therefore use the managed Linux agent even if a persistent Herdr/Pi session has a stale `SSH_AUTH_SOCK`. This intentionally prefers the local agent over a forwarded or Herdr-proxied agent; the setting is host-only and does not change either Mac's SSH configuration.

Do not start a second agent with `eval "$(ssh-agent -s)"`. Switching agents does not update the environment of existing shells, Herdr servers, or Pi processes. `ssh-add` and other direct agent clients do not read SSH's `IdentityAgent` setting: reconnect, or explicitly run `export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent"` in the affected shell before using them. This override does not recreate Herdr's proxy or rewrite running processes' environments.

The private key and passphrase remain outside the flake and Nix store. Unlock the key again whenever the agent restarts; enabling the service does not decrypt it automatically.

## Pins and ownership

- Root `flake.lock` contains only public inputs. Its base nixpkgs revision matches the lascasas bootstrap; it does not follow Whitepages pins. `agent-nixpkgs` is an independent public pin used only for the selected coding-agent packages. Public Home Manager is pinned from `release-26.05` and follows the unchanged base nixpkgs input; its fresh Linux state version is `26.05`.
- `flakes/work/flake.lock` retains the laptop's coordinated upstream pins. Its published monorepo revision deliberately preserves the native Stack integration instead of following floating `main`.
- The work entry point consumes the repository root through `path:../..` and selects `hosts/wp-K942Q6VXR7/`; it does not define the laptop's settings inline. Validate portability from a GitHub-fetched revision, without absolute checkout paths or local input overrides.
- `overlays/zellij-attention.nix` is platform-neutral. The existing direnv test workaround is applied only by the work wrapper.
- `hosts/lascasas/` owns the SSD UUIDs, UEFI/PERC boot support, networking, user, key-only SSH, and power-meter blacklist. Password state and SSH host keys are not stored here.

Switching the Linux configuration from channels to a flake can change the displayed version suffix without changing the underlying nixpkgs revision. Do not change state versions to match the new display string.

The implementation plan and approval gates are in `specs/shared-personal-flake.md` and its companion ladder.
