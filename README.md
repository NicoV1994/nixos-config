# NixOS Developer Workstation

This repository contains my finished personal NixOS laptop/desktop setup. It is built to be a practical daily workstation that is easy to inspect, edit, validate, and reproduce.

Priorities:

- Developer environment first.
- Privacy-conscious OS setup second.
- Fun and entertainment support third.

The goal is not to create a large framework. The goal is a robust, low-bloat, declarative system that humans and coding agents can work with quickly.

## Operating Principles

- Keep changes small, explicit, and easy to review.
- Prefer declarative Nix and Home Manager configuration over mutable setup steps.
- Prefer simple repository structure over abstractions that are not yet useful.
- Keep host-specific details in `hosts/<host>/` and reusable logic in `modules/` only when it is actually shared.
- Use plain Markdown docs, Git history, and short troubleshooting logs instead of custom documentation tooling.
- Validate before activation. Agents may build and check, but humans activate the system.
- Isolate privacy tradeoffs. Proprietary or convenience features should not silently become global defaults.

## Current Shape

- `flake.nix` pins inputs and defines the `nixos` system.
- Home Manager is integrated through the NixOS module and manages user packages, dotfiles, and desktop app configuration.
- Hyprland provides the Wayland desktop environment.
- Dotfiles for Waybar, Ghostty, Neovim, tmux, and related tools are managed from this repo.
- `justfile` provides the stable command interface for validation, builds, and human activation workflows.
- `docs/logs/` stores concise notes for non-obvious debugging sessions and recurring NixOS behavior.

## Browser Model

Browsers are intentionally separated by purpose:

- `Brave`: primary work/development browser.
- `LibreWolf`: privacy-focused browser.
- `Firefox`: entertainment and streaming browser, with DRM enabled for services such as Prime Video and uBlock Origin for ad blocking.

This keeps Widevine/DRM isolated to the browser that needs it instead of enabling it across the whole browsing setup.

## First-Time Install / Bootstrap Guide

To install this config on a fresh NixOS system:

### 1. Install Minimal NixOS

Use the graphical or text-based installer to set up a minimal NixOS system. Ensure networking works and `/etc/nixos/hardware-configuration.nix` exists for that laptop.

### 2. Create A Temporary Bootstrap Config

Save this repo's `bootstrap-example.nix` as `/etc/nixos/configuration.nix`. It imports `/etc/nixos/hardware-configuration.nix`, so keep the generated hardware file from the fresh install.

```bash
sudo cp bootstrap-example.nix /etc/nixos/configuration.nix
sudo nixos-rebuild switch
```

If `/etc/nixos/hardware-configuration.nix` is missing, generate it on the target laptop first:

```bash
sudo nixos-generate-config --show-hardware-config | sudo tee /etc/nixos/hardware-configuration.nix >/dev/null
```

### 3. Clone The Real Config

After reboot:

```bash
git clone https://github.com/nico-vergeiner/nixos-config
cd nixos-config
```

### 4. Switch To The Flake-Based System

```bash
sudo nixos-rebuild switch --flake ~/nixos-config#nixos
```

This applies the full system configuration from `hosts/nixos/configuration.nix` and the integrated Home Manager config for user `nico`.

### 5. Optional: Symlink Config

```bash
sudo ln -s $PWD /etc/nixos
```

## Rebuilding And Validation

For non-activating validation, use the repo task runner:

```bash
just validate   # read-only check plus no-link system build
just build      # no-link system build
just preflight  # format, check, and no-link system build
```

After reviewing changes, humans can apply them with:

```bash
just switch
```

Agents should follow `AGENTS.md`: they may run validation commands, but must never run `sudo` or activate the system.

## New Laptop Notes

For a different laptop, do not reuse `hosts/nixos/hardware-configuration.nix`; it contains disk UUIDs and hardware details for the current machine. Generate a fresh hardware config on the target laptop, then add a new host directory such as `hosts/framework/` and a matching `nixosConfigurations.framework` output when the hardware is known.

Work-specific networking lives behind `nico.dev.carenext.enable`. Keep it disabled for hosts that do not need those local dev hostnames or trusted Docker interfaces.

Private keys should not be committed to this repo. Keep SSH keys in `~/.ssh` or manage them with a secret-management tool before using this repo on more machines.

## Structure Overview

```text
nixos-config/
├── flake.nix                   # Main entry point
├── justfile                    # Stable command interface
├── AGENTS.md                   # Coding-agent instructions and guardrails
├── .agent/context.md           # Curated repo memory
├── bootstrap-example.nix       # Minimal first-install config
├── hosts/nixos/                # System-level config
│   ├── configuration.nix
│   └── hardware-configuration.nix
├── home/nico.nix               # User-level Home Manager config
├── dotfiles/                   # Dotfiles for Hyprland, Waybar, Ghostty, etc.
├── docs/decisions/             # Structural decision notes
├── docs/logs/                  # Troubleshooting notes and reusable lessons
└── README.md
```

## Tasks And Logs

See `TASKS.md` for active work, shaped task briefs, and backlog items when that file exists.

See `docs/logs/` for major troubleshooting notes and reusable lessons that should not live only in chat history.
