## Phase 1: Separate work and personal entry points

| Status         | Started    | Completed  |
| -------------- | ---------- | ---------- |
| 🔴 blocked      | 2026-10-22 |            |

Tags: nix, isolation

Make the existing laptop configuration work-only and expose the unchanged Linux bootstrap through a public-input personal root. Follow the spec's dependency contracts, preservation table, and lock-review gate.

#### Delivers

- Separate root personal and flakes/work/ flake entry points, each with its own reviewed lock, and a durable shared-module source boundary.
- An evaluated checkout baseline and separately recorded running-host baseline, with the pre-existing lock change preserved rather than overwritten.
- Portable dependency references at the approved revisions, or an explicit blocker if the current work source cannot yet be fetched remotely.
- Just recipes and a short README for input isolation, host evaluation, native builds, and the changed work-laptop entry point.

#### Done When

- just check-personal-inputs verifies that the complete personal lock/input graph contains no company sources or machine-local checkout inputs.
- just eval-hosts evaluates both current host configurations and asserts the spec's preservation table; baseline differences are reviewed.
- just build-linux succeeds on lascasas and just build-work-mac succeeds on the work laptop using the approved pins, without activating either system.
- A fresh-source-copy check evaluates the work entry point without relying on the original checkout path, missing tracked files, or a local work-source override.
- just validate passes and the lock migration has explicit user approval.

#### Depends On

- (none)

## Phase 2: Share the personal environment across the current hosts

| Status         | Started    | Completed  |
| -------------- | ---------- | ---------- |
| ⬜ not-started  |            |            |

Tags: home-manager, linux, darwin

Give lascasas the shared personal tools and preferences while the work laptop composes the same modules with its company profile. Keep desktop, platform, identity, and Nix-ownership concerns at their documented boundaries.

#### Delivers

- Shared personal Home Manager modules and explicit platform, desktop, identity, and work composition, reusing the existing editor and terminal configuration.
- A Home Manager-enabled lascasas output and a work-laptop output that consumes the personal modules without moving company dependencies into them.
- Regression assertions for personal/work separation and existing host behavior, plus documented activation and rollback steps.

#### Done When

- just check-personal-settings proves that personal outputs lack company-only identity, tools, caches/auth integration, and activation jobs; work-profile assertions pass for the work laptop.
- just eval-hosts, just build-linux, just build-work-mac, and just validate pass on their documented platforms with the selected Home Manager APIs and public package availability checked.
- Home Manager dry runs have no unresolved unmanaged-file collisions; the reviewed diff identifies all intended package, user-setting, and login-shell changes.
- After separate user approval for each host, activation preserves remote access and passes fresh SSH, user shell/editor, Nix build, and failed-unit checks. If approval is deferred, report build-ready status rather than marking activation complete.

#### Depends On

- separate-work-and-personal-entry-points

## Phase 3: Onboard the personal Mac

| Status         | Started    | Completed  |
| -------------- | ---------- | ---------- |
| ⬜ not-started  |            |            |

Tags: darwin, personal

Add the real personal Mac once Eric supplies the host facts listed in the spec. Reuse the personal modules without company input access or work-profile installation.

#### Delivers

- A personal Darwin host output using confirmed identifiers, Nix ownership, identity, and state versions.
- A native personal-Mac build/validation recipe and host-selection instructions.

#### Done When

- The host configuration uses Eric-confirmed facts and satisfies the spec's personal-host and preservation contracts.
- just check-personal-inputs, just check-personal-settings, and just build-personal-mac succeed without company access or a work-input override; the build runs on the personal Mac.
- After explicit activation approval, the personal Mac's shell/editor, Git/JJ identity, Nix builds, and rollback path are verified; just validate passes.

#### Depends On

- share-the-personal-environment-across-the-current-hosts

## Notes

The companion spec is the canonical source for dependency boundaries, preservation requirements, and approval gates. All phases start not-started. Work is in the current jj checkout by explicit user instruction; no stack, commit, lock update, or activation is implied by spec approval.
