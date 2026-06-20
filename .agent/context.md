# Agent Context

This repo manages my finished reusable NixOS laptop/desktop setup for a daily workstation.

Priorities: developer environment first, privacy-conscious OS setup second, fun and entertainment support third.

Current baseline: Hyprland, Waybar, Ghostty, tmux, Neovim, VSCode, DBeaver, screen locking, i3-like shortcuts, integrated Home Manager, and AI-agent-friendly maintenance.

Browser split: Brave is the work/development browser, LibreWolf is the privacy-focused browser, and Firefox is the entertainment/streaming browser with DRM isolated there plus uBlock Origin.

Design preferences: rapidly editable, robust, reproducible, low-bloat, reusable modules only when useful, thin host configs, simple rebuild workflow, no overengineering.

Major troubleshooting writeups live in `docs/logs/`. Read related logs before re-debugging a recurring issue, and add a concise log only for significant, non-obvious fixes.
Also document changes with known potential for strange hardware-dependent side effects, such as power-management auto-tuning, so future debugging has a starting point.

## Current Backlog

- Check `TASKS.md` for active work, shaped task briefs, and betting-table items before starting broad or ambiguous tasks.
- Privacy-hardening follow-up work is tracked in `docs/privacy-hardening-todo.md`; preserve documented developer workflow tradeoffs when changing security/privacy settings.

## Maintenance

- Generation cleanup is human-only because it uses `sudo` and removes rollback points.
- Default cleanup policy: keep the latest 5 system generations with `just clean-generations` after confirming the current generation works.
- Agents may document or suggest cleanup commands but must not run `sudo nix-env --delete-generations`, `sudo nix store gc`, or `just clean-generations`.
- Prefer targeted validation over broad checks when safe. For example, use shell syntax/output checks for script edits and skip `just check` for purely cosmetic CSS color changes unless Nix wiring or evaluation could be affected.

## Flutter Android Development

- Milon development is documented in `docs/milon-development.md`: project repos own runtime config, this NixOS repo owns local host/firewall/toolchain integration.
- The local Milon host profile lives under `nico.dev.milon`; CareNext networking is under `nico.dev.milon.carenext` and trusts the stable `br-carenext` Docker bridge.
- Milon Flutter workstation integration is under `nico.dev.milon.flutter`; it controls host-level Android tooling such as Android Studio and `nix-ld`, while `#flutter-android` remains the reusable terminal dev shell.
- Use the reusable Nix dev shell for Flutter/Android work: `nix develop /home/nico/nixos-config#flutter-android`.
- The shell owns the Android SDK via `androidenv.composeAndroidPackages`; terminal builds should not rely on Android Studio's mutable `/home/nico/Android/Sdk`.
- Inside the shell, `which adb` must resolve to a Nix store Android SDK path, not `/home/nico/Android/Sdk/platform-tools/adb`.
- For `/home/nico/Haggla/Milon/milon-trainer-app`, use the `development` flavor and provide `API_HOST`, for example: `flutter run --flavor development --dart-define API_HOST="https://studio.dev.next.miloncare.com"`.
- Pixel wireless debugging may show `10.2.0.2:<port>` even when that address is unreachable from the laptop. Use the phone's real Wi-Fi LAN IP from Wi-Fi settings, e.g. `192.168.178.54:<port>`.
- Wireless debugging has two ports: one temporary pairing port from "Pair device with pairing code" and one connect/debug port from the main Wireless debugging screen.
- USB debugging on this HP pilot laptop was flaky with Pixel 10: kernel logs showed repeated `USB disconnect` and `device descriptor read/64, error -71`. Treat that as cable/port/USB-controller negotiation, not Flutter/Nix setup.
- If Android install fails with `INSTALL_FAILED_UPDATE_INCOMPATIBLE`, uninstall the existing differently signed package: `adb uninstall com.milongroup.trainerapp`.
- Emulator works in principle through the Nix SDK, but this pilot laptop is weak for GUI emulation. Prefer a real phone here; on better hardware the emulator workflow may be fine.
