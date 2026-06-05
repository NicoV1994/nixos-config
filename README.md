# ❄️ NixOS Config — Hyprland Setup with Home Manager

This repository contains my personal NixOS system configuration using:

* **Nix flakes** for reproducible and modular builds
* **Home Manager** for user-level dotfiles and packages
* **Hyprland** for Wayland desktop experience
* Custom dotfiles for `waybar`, `nvim` (WIP), etc.

---

## First-Time Install / Bootstrap Guide

To install this config on a fresh NixOS system:

### 1. Install Minimal NixOS

Use the graphical or text-based installer to set up a minimal NixOS system. Ensure networking works.

### 2. Create a Temporary Bootstrap Config

Save this repo’s `bootstrap-example.nix` and a matching `hardware-configuration.nix` into `/etc/nixos/`, then run:

```bash
sudo cp bootstrap-example.nix /etc/nixos/configuration.nix
sudo cp hardware-configuration.nix /etc/nixos/
sudo nixos-rebuild switch
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

## 💠 Structure Overview

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
└── README.md
```
