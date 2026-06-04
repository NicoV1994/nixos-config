# Repository Guidelines

## Purpose
This is a personal NixOS desktop/laptop flake repository. It manages the system configuration, integrated Home Manager setup, and user dotfiles for a reusable Wayland desktop environment.

Keep changes small, explicit, and easy to review. Prefer plain Markdown documentation and Git history over custom tooling.

## Intended Layout
- `flake.nix` / `flake.lock`: flake entrypoint and pinned inputs.
- `hosts/<host>/`: host-specific NixOS configuration, hardware config, and machine-specific imports.
- `modules/`: reusable NixOS or Home Manager modules shared across hosts when needed.
- `home/`: user-level Home Manager configuration.
- `dotfiles/`: app configs managed declaratively, such as Hyprland, Waybar, Neovim, Ghostty, and tmux.
- `assets/`: static assets such as wallpapers.
- `docs/decisions/`: short decision notes for meaningful structural changes.
- `.agent/context.md`: curated repo memory for humans and AI coding agents.
- `bootstrap-example.nix`: minimal bootstrap config for first install.

Keep host-specific details in `hosts/<host>/`. Keep reusable logic in `modules/` only when it is actually shared or likely to be shared.

## Safe Commands
Run commands from the repository root.

- `just status`: show concise Git status.
- `just agent-context`: print agent instructions, curated context, and relevant repo files.
- `just fmt`: run `nix fmt`.
- `just check`: run `nix flake check`.
- `just build`: build the system closure without activating it.
- `just preflight`: run formatting, flake checks, and a non-sudo system build.

If `just` is not available, run the underlying command directly.

## Agent Command Policy
Agents may run these commands without asking:

- `just status`
- `just agent-context`
- `just fmt`
- `just check`
- `just build`
- `just preflight`
- `nix build .#nixosConfigurations.nixos.config.system.build.toplevel`

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
- For most Nix changes, prefer `just build` or `just preflight` before any activation.
- For system-impacting changes such as services, drivers, boot, or display manager changes, a human should run `just dry` or `sudo nixos-rebuild test --flake .#nixos` before any `switch`.
- After desktop/UI edits, verify affected apps start correctly when practical: Hyprland, Waybar, Neovim, Ghostty.

## Commit And PR Guidelines
Git history favors short, imperative messages, often Conventional Commit-style.

- Preferred: `feat(nixos): ...`, `fix: ...`, `chore: ...`.
- Keep subject lines concise and focused on one change.
- In PRs, include purpose, key files changed, validation steps run, and screenshots for visual dotfile/UI updates.
- Link related issues or tasks when applicable.
