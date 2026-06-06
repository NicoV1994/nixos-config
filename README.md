# NixOS Config - Hyprland Setup with Home Manager

This repository contains my personal NixOS system configuration using:

* **Nix flakes** for reproducible and modular builds
* **Home Manager** for user-level dotfiles and packages
* **Hyprland** for Wayland desktop experience
* Custom dotfiles for `waybar`, `nvim` (WIP), etc.

---

## First-Time Install / Bootstrap Guide

To install this config on a fresh NixOS system:

### 1. Install Minimal NixOS

Use the graphical or text-based installer to set up a minimal NixOS system. Ensure networking works and `/etc/nixos/hardware-configuration.nix` exists for that laptop.

### 2. Create a Temporary Bootstrap Config

Save this repo's `bootstrap-example.nix` as `/etc/nixos/configuration.nix`. It imports `/etc/nixos/hardware-configuration.nix`, so keep the generated hardware file from the fresh install.

```bash
sudo cp bootstrap-example.nix /etc/nixos/configuration.nix
sudo nixos-rebuild switch
```

If `/etc/nixos/hardware-configuration.nix` is missing, generate it on the target laptop first:

```bash
sudo nixos-generate-config --show-hardware-config | sudo tee /etc/nixos/hardware-configuration.nix >/dev/null
```

### 3. Clone the Real Config

After reboot:

```bash
git clone https://github.com/nico-vergeiner/nixos-config
cd nixos-config
```

### 4. Switch to Flake-Based System

```bash
sudo nixos-rebuild switch --flake ~/nixos-config#nixos
```

> This applies the full system configuration from `hosts/nixos/configuration.nix` and Home Manager config for user `nico`.

### 5. Optional: Symlink Config

```bash
sudo ln -s $PWD /etc/nixos
```

## Rebuilding the System or User Config
After reviewing changes, humans can apply them with:

```bash
sudo nixos-rebuild switch --flake ~/nixos-config#nixos
```

For non-activating validation, use the repo task runner:

```bash
just validate   # read-only check + no-link system build
just preflight  # format, check, and no-link system build
```

Agents should follow `AGENTS.md`: they may run validation commands, but must never run `sudo` or activate the system.

---

## Tasks And Backlog

See `TASKS.md` for active work, shaped task briefs, and backlog items.

See `docs/logs/` for major troubleshooting notes and reusable lessons that should not live only in chat history.

---

## Tools Used

| Tool                                  | Role                                |
| ------------------------------------- | ----------------------------------- |
| `nixpkgs`                             | Base NixOS package set              |
| `flakes`                              | Reproducible config management      |
| `home-manager`                        | User-level packages and dotfiles    |
| `Hyprland`                            | Wayland window manager              |
| `waybar`                              | Customizable Wayland status bar     |
| `bitwarden`, `firefox`, `brave`, etc. | Daily tools installed declaratively |

---

## New Laptop Notes

For a different laptop, do not reuse `hosts/nixos/hardware-configuration.nix`; it contains disk UUIDs and hardware details for the current machine. Generate a fresh hardware config on the target laptop, then add a new host directory such as `hosts/framework/` and a matching `nixosConfigurations.framework` output when the hardware is known.

Work-specific networking lives behind `nico.dev.carenext.enable`. Keep it disabled for hosts that do not need those local dev hostnames or trusted Docker interfaces.

Private keys should not be committed to this repo. Keep SSH keys in `~/.ssh` or manage them with a secret-management tool before using this repo on more machines.

## Structure Overview

```
nixos-config/
├── flake.nix                   # Main entry point
├── justfile                    # Stable command interface
├── AGENTS.md                   # Coding-agent instructions and guardrails
├── .agent/context.md           # Curated repo memory
├── bootstrap-example.nix       # Use this for minimal install
├── hosts/nixos/                # System-level config
│   ├── configuration.nix
│   └── hardware-configuration.nix
├── home/nico.nix               # User-level config
├── dotfiles/                   # Dotfiles for Hyprland, Waybar, etc.
├── docs/decisions/             # Structural decision notes
├── docs/logs/                  # Troubleshooting notes and reusable lessons
└── README.md
```
