# Personal and work Nix configurations

One repository, separate dependency graphs: the root flake is personal; `flakes/work/` supplies private inputs and wiring for the Whitepages laptop. Machine-specific configuration lives uniformly under `hosts/`.

## Entry points

| Machine | Host module | Flake | Output |
|---|---|---|---|
| Lascasas | `hosts/lascasas/` | `.` | `nixosConfigurations.lascasas` |
| Whitepages laptop | `hosts/wp-K942Q6VXR7/` | `./flakes/work` | `darwinConfigurations.wp-K942Q6VXR7` |
| Personal Mac | Not configured yet | Personal root | Requires its real hostname, user, Nix ownership, and existing state versions |

**Do not use the work entry point on personal machines.** Moving the laptop entry point changes the old root-based rebuild command.

At this checkpoint, lascasas retains its minimal, verified NixOS bootstrap. Home Manager and the shared personal development environment are the next phase. `nix-home/common.nix` is still a legacy mixed module imported only by the work laptop; the older `r630.nix` and `mac-osx.nix` wrappers are not active host configurations.

## Develop and validate

Prerequisites: Nix with flakes enabled and jj. Use jj directly; there is no managed stack requirement. Publish changes through a named bookmark so each machine builds the same GitHub revision.

```bash
nix develop
just validate
```

These checks use only the personal graph. The developer shell supplies the formatters, linters, Python, and task runner; jj remains the host prerequisite so the shell does not silently select a different jj version for this checkout.

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

On lascasas, clone that bookmark into a normal checkout. If jj is not installed yet, first enter `nix-shell -p jujutsu`. The HTTPS clone requires personal GitHub authentication if the repository is private.

```bash
jj git clone --colocate --branch shared-personal-flake https://github.com/ericbmerritt/nix-home.git ~/nix-home
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

## SSH agent on lascasas

`programs.ssh.startAgent` enables NixOS's user `ssh-agent` service at login, with its socket at `$XDG_RUNTIME_DIR/ssh-agent`. After activating the configuration, use a fresh Linux login session and unlock the key there:

```bash
ssh-add ~/.ssh/id_ed25519
```

Do not start a second agent with `eval "$(ssh-agent -s)"`. An existing shell may still point at that old manual agent; reconnect, or explicitly set `SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent"` before `ssh-add`. Non-login automation may also need that environment variable explicitly.

The private key and passphrase remain outside the flake and Nix store. Unlock the key again whenever the agent restarts; enabling the service does not decrypt it automatically.

## Pins and ownership

- Root `flake.lock` contains only public inputs. Its nixpkgs revision matches the installed lascasas bootstrap; it does not follow Whitepages pins.
- `flakes/work/flake.lock` retains the laptop's coordinated upstream pins. Its published monorepo revision deliberately preserves the native Stack integration instead of following floating `main`.
- The work entry point consumes the repository root through `path:../..` and selects `hosts/wp-K942Q6VXR7/`; it does not define the laptop's settings inline. Validate portability from a GitHub-fetched revision, without absolute checkout paths or local input overrides.
- `overlays/zellij-attention.nix` is platform-neutral. The existing direnv test workaround is applied only by the work wrapper.
- `hosts/lascasas/` owns the SSD UUIDs, UEFI/PERC boot support, networking, user, key-only SSH, and power-meter blacklist. Password state and SSH host keys are not stored here.

Switching the Linux configuration from channels to a flake can change the displayed version suffix without changing the underlying nixpkgs revision. Do not change state versions to match the new display string.

The implementation plan and approval gates are in `specs/shared-personal-flake.md` and its companion ladder.
