# Repository Guidelines

## Purpose
This is a finished personal NixOS laptop/desktop flake for a daily workstation. It manages the system configuration, integrated Home Manager setup, and user dotfiles for a reusable Wayland desktop environment.

The repo priorities are:

- Developer environment first.
- Privacy-conscious OS setup second.
- Fun and entertainment support third.

Keep changes small, explicit, and easy to review. Prefer plain Markdown documentation and Git history over custom tooling. The setup should stay rapidly editable, robust, reproducible, accessible to agents, understandable to humans, and free of unnecessary bloat.

## Operating Priorities
- Preserve development workflows and reproducibility before convenience tweaks.
- Isolate privacy tradeoffs. Proprietary, tracking-heavy, or entertainment-specific features should be scoped to the apps/profiles that need them.
- Keep entertainment support practical, but do not let it pollute work or privacy defaults.
- Treat the current configuration as a working baseline. Prefer incremental improvements over broad redesigns unless the user explicitly requests a restructure.
- Avoid adding helper scripts, modules, services, package sets, or docs processes unless they clearly reduce complexity or improve reproducibility.

## Intended Layout
- `flake.nix` / `flake.lock`: flake entrypoint and pinned inputs.
- `hosts/<host>/`: host-specific NixOS configuration, hardware config, and machine-specific imports.
- `modules/`: reusable NixOS or Home Manager modules shared across hosts when needed.
- `home/`: user-level Home Manager configuration.
- `dotfiles/`: app configs managed declaratively, such as Hyprland, Waybar, Neovim, Ghostty, and tmux.
- `assets/`: static assets such as wallpapers.
- `docs/decisions/`: short decision notes for meaningful structural changes.
- `docs/logs/`: concise troubleshooting and learning notes for significant issues.
- `.agent/context.md`: curated repo memory for humans and AI coding agents.
- `bootstrap-example.nix`: minimal bootstrap config for first install.

Keep host-specific details in `hosts/<host>/`. Keep reusable logic in `modules/` only when it is actually shared or likely to be shared.

## Learning Logs
- Use `docs/logs/` for significant debugging sessions, recurring issues, or non-obvious workflows that future humans/agents should not rediscover from chat history.
- Before working in an area with a related log, read the relevant file in `docs/logs/`.
- Add or update a log when the fix involved multiple failed hypotheses, external hardware/services, or NixOS-specific behavior that is likely to recur.
- Also add a log when enabling a feature has known potential for strange, annoying, hardware-dependent side effects that future humans/agents may need to debug, even if the initial change works.
- Do not log every small package addition, typo fix, or obvious config edit. Prefer Git history for normal change tracking.
- Keep logs concise and factual: problem, context, root cause, fix, validation, follow-up, and useful commands.

## Task Workflow
- Check `TASKS.md` for active work and betting-table items before starting broad, ambiguous, or backlog-style work.
- When a user asks to work on a known backlog item, use the matching `TASKS.md` brief and any linked source-of-truth docs before editing.
- Keep detailed backlog notes in focused docs linked from `TASKS.md`, rather than expanding `.agent/context.md` into a long manual.
- For privacy or security changes, check `docs/privacy-hardening-todo.md` and preserve documented developer workflow tradeoffs unless the user explicitly asks to change them.

## Safe Commands
Run commands from the repository root.

Read-only safe commands:

- `just status`: show concise Git status.
- `just agent-context`: print agent instructions, curated context, and relevant repo files.
- `just doctor`: print a fast repo/system readiness report without formatting, builds, activation, or sudo.
- `just check`: run `nix flake check`.
- `just build`: build the system closure without activating it or creating a `result` symlink.
- `just validate`: run read-only validation without formatting.

Editing-agent safe commands after file changes:

- `just fmt`: run `nix fmt`.
- `just preflight`: run formatting, flake checks, and a non-sudo system build.

If `just` is not available, run the underlying command directly.

## Agent Command Policy
Agents may run these commands without asking:

- `just status`
- `just agent-context`
- `just doctor`
- `just check`
- `just build`
- `just validate`

Editing agents may also run these after they have made file changes:

- `just fmt`
- `just preflight`
- `nix build --no-link .#nixosConfigurations.nixos.config.system.build.toplevel`

Read-only agents should not run formatting commands because they can modify files.

Agents must never run `sudo`. Sudo commands are human-only, even when they are validation commands. Agents may suggest the exact sudo command for the human to run after review, but must not execute it.

Human-only commands that agents must not run:

- `just dry`
- `just switch`
- `just boot`
- `sudo nixos-rebuild dry-build --flake .#nixos`
- `sudo nixos-rebuild test --flake .#nixos`
- `nixos-rebuild switch`
- `nixos-rebuild boot`

Agents may only run these after explicit user approval:

- `just update`
- `nix flake update`
- commands that delete files, generations, or caches
- commands that push to remotes

## Guardrails
- Do not update `flake.lock` unless explicitly requested.
- Do not run `nix flake update` unless explicitly requested.
- Do not run `nixos-rebuild switch` unless explicitly requested.
- Do not run `nixos-rebuild boot` unless explicitly requested.
- Do not run destructive cleanup commands unless explicitly requested.
- Do not change unrelated NixOS configuration while working on documentation or tooling.
- Prefer small, reviewable changes over broad refactors.
- Prefer Nix-native solutions over shell-script workarounds.
- Keep host-specific details out of shared modules.
- Add a decision note under `docs/decisions/` for meaningful structural changes.

## Home Manager Integration
- Home Manager is integrated through the NixOS module in `flake.nix` (`home-manager.nixosModules.home-manager` and `home-manager.users.nico`).
- Default apply workflow is `nixos-rebuild` for both system and user configuration, but activation commands require explicit user approval.
- Do not assume standalone `home-manager switch` is available unless a separate `homeConfigurations` output is added.

## Coding Style
- Use idiomatic Nix formatting: 2-space indentation, aligned attribute sets where readable, trailing commas in multi-line sets.
- Prefer small, composable option blocks over large monolithic sections.
- Name commits and modules descriptively by domain, for example `hyprland`, `waybar`, or `audio`.
- Keep dotfile names conventional (`config`, `init.lua`, `style.css`) unless upstream tooling expects otherwise.

## Validation
- Minimum safe check for most changes: `just check` or `nix flake check`.
- Use `just doctor` for a fast read-only readiness snapshot when deciding whether the repo and running system are aligned before deeper work.
- Use targeted validation when it is sufficient: shell syntax/output checks for script edits, formatter checks for formatting-sensitive changes, and app restarts for desktop dotfiles.
- Do not run `just check` for obviously safe cosmetic-only edits such as CSS color changes unless there is a concrete risk that Nix evaluation or file wiring changed.
- For read-only review, use `just validate`.
- For most Nix changes, prefer `just build` or `just preflight` before any activation.
- For system-impacting changes such as services, drivers, boot, or display manager changes, a human should run `just dry` or `sudo nixos-rebuild test --flake .#nixos` before any `switch`.
- After desktop/UI edits, verify affected apps start correctly when practical: Hyprland, Waybar, Neovim, Ghostty.

## Commit And PR Guidelines
Git history favors short, imperative messages, often Conventional Commit-style.

- Preferred: `feat(nixos): ...`, `fix: ...`, `chore: ...`.
- Keep subject lines concise and focused on one change.
- In PRs, include purpose, key files changed, validation steps run, and screenshots for visual dotfile/UI updates.
- Link related issues or tasks when applicable.
