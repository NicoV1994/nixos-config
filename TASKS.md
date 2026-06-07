# Tasks

This file tracks not-done work for this NixOS config. Tasks are written as small Shape Up style briefs so they are useful both for humans and AI agents.

## Active / Not Done

No active task is selected. Promote one item from the betting table when ready.

## Betting Table

### Privacy-Harden HP Laptop Baseline
Status: Shaped
Appetite: Medium

Problem:
The HP ProBook 430 G5 config only partially implements the privacy-hardening baseline. Remaining work includes Bluetooth off-at-boot, explicit firewall config, TPM userspace support, encrypted DNS, Tor Browser, radio/camera controls, AppArmor/Firejail, USBGuard evaluation, disk encryption planning, and Secure Boot planning.

Source Of Truth:
- See `docs/privacy-hardening-todo.md` for the full audit result, platform facts, staged checklist, and tradeoffs.

Done When:
- Quick wins from `docs/privacy-hardening-todo.md` are implemented and validated with `just check` or a more appropriate targeted command.
- Medium-effort items are either implemented one at a time or explicitly left as follow-up tasks.
- Advanced boot-chain and disk-encryption work remains split into separate tasks before implementation.

### Fix Waybar CPU Tooltip Over 100 Percent
Status: Raw
Appetite: Small

Problem:
The Waybar CPU tooltip can show Brave using more than `100%` CPU, which is confusing and may be caused by how per-process CPU usage is aggregated or reported across cores.

Done When:
- The tooltip explains CPU usage correctly.
- Browser/process CPU values no longer look impossible without context.
- The fix is validated by hovering the CPU module while Brave is active.

### Fix Waybar Battery Color Classes
Status: Raw
Appetite: Small

Problem:
The Waybar battery/power icon color does not change as expected when battery status, charge level, or power profile changes.

Done When:
- Battery warning/critical/charging/profile classes produce visible color changes.
- The generated JSON class names match the CSS selectors in `dotfiles/waybar/style.css`.
- The fix is validated by checking Waybar output and hovering/cycling the power module.

### Improve Neovim File Navigation
Status: Shaped
Appetite: Small

Problem:
I want to see nearby files and folders from the file I am editing without remembering `:Explore` commands.

Solution:
Add Neo-tree as a sidebar file explorer and bind it to `Space e`.

Look And Feel:
Minimal left sidebar, works with Nerd Font icons, reveals the current file, and does not replace Telescope.

Shortcuts:
- `Space e`: toggle file explorer
- `Space sf`: fuzzy find files with Telescope
- `Space Space`: switch buffers

Done When:
- Neo-tree opens with `Space e`.
- It reveals the current file.
- Telescope shortcuts still work.
- Neovim starts without plugin errors.

Validation:
- Open Neovim.
- Press `Space e`.
- Navigate files with `Enter`.
