# Agent Context

This repo manages my reusable NixOS laptop/desktop setup.

Current focus: Hyprland, Waybar, Ghostty, tmux, Neovim, VSCode, DBeaver, screen locking, i3-like shortcuts, and AI-agent-friendly maintenance.

Design preferences: reusable modules, thin host configs, simple rebuild workflow, no overengineering.

## Flutter Android Development

- Use the reusable Nix dev shell for Flutter/Android work: `nix develop /home/nico/nixos-config#flutter-android`.
- The shell owns the Android SDK via `androidenv.composeAndroidPackages`; terminal builds should not rely on Android Studio's mutable `/home/nico/Android/Sdk`.
- Inside the shell, `which adb` must resolve to a Nix store Android SDK path, not `/home/nico/Android/Sdk/platform-tools/adb`.
- For `/home/nico/Haggla/Milon/milon-trainer-app`, use the `development` flavor and provide `API_HOST`, for example: `flutter run --flavor development --dart-define API_HOST="https://studio.dev.next.miloncare.com"`.
- Pixel wireless debugging may show `10.2.0.2:<port>` even when that address is unreachable from the laptop. Use the phone's real Wi-Fi LAN IP from Wi-Fi settings, e.g. `192.168.178.54:<port>`.
- Wireless debugging has two ports: one temporary pairing port from "Pair device with pairing code" and one connect/debug port from the main Wireless debugging screen.
- USB debugging on this HP pilot laptop was flaky with Pixel 10: kernel logs showed repeated `USB disconnect` and `device descriptor read/64, error -71`. Treat that as cable/port/USB-controller negotiation, not Flutter/Nix setup.
- If Android install fails with `INSTALL_FAILED_UPDATE_INCOMPATIBLE`, uninstall the existing differently signed package: `adb uninstall com.milongroup.trainerapp`.
- Emulator works in principle through the Nix SDK, but this pilot laptop is weak for GUI emulation. Prefer a real phone here; on better hardware the emulator workflow may be fine.
