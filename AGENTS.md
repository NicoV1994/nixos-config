# Repository Guidelines

## Project Structure & Module Organization
This repository is a flake-based NixOS configuration.

- `flake.nix` / `flake.lock`: entrypoint and pinned inputs.
- `hosts/nixos/`: system-level NixOS modules (`configuration.nix`, `hardware-configuration.nix`).
- `home/nico.nix`: Home Manager user configuration.
- `dotfiles/`: app configs managed declaratively (for example `hyprland/`, `waybar/`, `nvim/`, `ghostty/`).
- `assets/`: static assets such as wallpapers.
- `bootstrap-example.nix`: minimal bootstrap config for first install.

Keep changes scoped: system services in `hosts/`, user apps and shell/editor preferences in `home/` and `dotfiles/`.

## Build, Test, and Development Commands
- `sudo nixos-rebuild switch --flake /home/nico/nixos-config#nixos`: canonical apply command for this repo (system + integrated Home Manager).
- `nix flake check /home/nico/nixos-config`: run flake evaluations/checks before committing.
- `nix build /home/nico/nixos-config#nixosConfigurations.nixos.config.system.build.toplevel`: fast pre-activation build validation.
- `sudo nixos-rebuild test --flake /home/nico/nixos-config#nixos`: test activation without making it the boot default.
- `nix flake update`: refresh input lock versions in `flake.lock`.

Run commands from the repository root.

## Home Manager Integration
- Home Manager is integrated through the NixOS module in `flake.nix` (`home-manager.nixosModules.home-manager` and `home-manager.users.nico`).
- Default workflow is `nixos-rebuild` for applying both system and user configuration.
- Do not assume standalone `home-manager switch` is available in this repo unless a separate `homeConfigurations` output is added.

## Coding Style & Naming Conventions
- Use idiomatic Nix formatting: 2-space indentation, aligned attribute sets where readable, trailing commas in multi-line sets.
- Prefer small, composable option blocks over large monolithic sections.
- Name commits and modules descriptively by domain (for example audio, hyprland, waybar).
- Keep dotfile names conventional (`config`, `init.lua`, `style.css`) unless upstream tooling expects otherwise.

## Testing Guidelines
- Minimum check for every change: `nix flake check` must pass.
- For most changes, run `nix build /home/nico/nixos-config#nixosConfigurations.nixos.config.system.build.toplevel` before any sudo activation.
- For system-impacting changes (services, drivers, boot, display manager), run `sudo nixos-rebuild test --flake /home/nico/nixos-config#nixos` before `switch`.
- After desktop/UI edits, verify affected apps start correctly (Hyprland, Waybar, Neovim, Ghostty).

## Commit & Pull Request Guidelines
Git history favors short, imperative messages, often Conventional Commit-style:

- Preferred: `feat(nixos): ...`, `fix: ...`, `chore: ...`.
- Keep subject lines concise and focused on one change.
- In PRs, include: purpose, key files changed, validation steps run, and screenshots for visual dotfile/UI updates (Waybar/Hyprland styling).
- Link related issues/tasks when applicable.
