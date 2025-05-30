# ❄️ NixOS Config — Hyprland Setup with Home Manager

This repository contains my personal NixOS system configuration using:

* **Nix flakes** for reproducible and modular builds
* **Home Manager**or user-level dotfiles and packages
* **Hyprland** for Wayland desktop experience
* Custom dotfiles for `wezterm`, `waybar`, `nvim` (WIP), etc.

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
sudo nixos-rebuild switch --flake /home/nico/nixos-config#nixos
```

> This applies the full system configuration from `hosts/nixos/configuration.nix` and Home Manager config for user `nico`.

### 5. Optional: Symlink Config

```bash
sudo ln -s $PWD /etc/nixos
```

## Rebuilding the System or User Config
Use this command:

```bash
sudo nixos-rebuild switch --flake ~/nixos-config#nixos
```

---

## Tools Used

| Tool                                  | Role                                |
| ------------------------------------- | ----------------------------------- |
| `nixpkgs`                             | Base NixOS package set              |
| `flakes`                              | Reproducible config management      |
| `home-manager`                        | User-level packages and dotfiles    |
| `Hyprland`                            | Wayland window manager              |
| `wezterm`                             | GPU-accelerated terminal            |
| `waybar`                              | Customizable Wayland status bar     |
| `bitwarden`, `firefox`, `brave`, etc. | Daily tools installed declaratively |

---

## 💠 Structure Overview

```
nixos-config/
├── flake.nix                   # Main entry point
├── bootstrap-example.nix       # Use this for minimal install
├── hosts/nixos/                # System-level config
│   ├── configuration.nix
│   └── hardware-configuration.nix
├── home/nico.nix               # User-level config
├── dotfiles/                   # Dotfiles for Hyprland, Waybar, etc.
└── README.md
```
