# Flutter Android Dev Shell

Date: 2026-06-06
Status: Resolved

## Problem

Flutter Android development needed to work on this NixOS laptop for customer projects, especially `/home/nico/Haggla/Milon/milon-trainer-app`.

The initial Android Studio-managed SDK path made Flutter work partially, but it was not reproducible and caused NixOS-specific runtime problems with downloaded Android SDK binaries.

## Context

- This repo is a personal NixOS flake with integrated Home Manager.
- The Milon trainer app needs Flutter `3.41.9`, Android flavors, and `API_HOST` as a dart define.
- This HP ProBook pilot laptop is weak for Android emulation, so a real Pixel 10 phone became the practical target.
- Android Studio remains useful as an IDE, but terminal builds should use the Nix-managed SDK.

## Root Cause

Several issues were uncovered:

- Android Studio's mutable SDK under `/home/nico/Android/Sdk` leaked into `PATH`, so `adb` could resolve to a non-reproducible SDK even inside a shell.
- Android Studio-downloaded tools are generic Linux binaries; on NixOS they can require `nix-ld` or fail with missing libraries.
- The app needs Android SDK platforms `34`, `35`, and `36`, CMake `3.22.1`, and NDK `28.2.13676358`; if omitted from the read-only Nix SDK, Gradle tries and fails to install them at build time.
- Pixel wireless debugging showed `10.2.0.2:<port>`, but that address was unreachable from the laptop. The usable address was the phone's real Wi-Fi LAN IP, `192.168.178.54:<port>`.
- USB debugging was unstable on this laptop: kernel logs showed repeated `USB disconnect` and `device descriptor read/64, error -71`, indicating cable/port/controller negotiation rather than Flutter or ADB config.
- A pre-existing phone install could fail with `INSTALL_FAILED_UPDATE_INCOMPATIBLE` when signatures differed.

## Fix

Added a reproducible Flutter Android dev shell:

- `devshells/flutter-android.nix`
- `devShells.x86_64-linux.flutter-android`
- Template in `templates/flutter-android/`
- Documentation in `docs/flutter-android.md`

The shell uses `androidenv.composeAndroidPackages` and explicitly provides:

- Android SDK platforms `34`, `35`, and `36`
- Build tools `34.0.0`, `35.0.0`, and `36.0.0`
- Command-line tools `13.0`
- Emulator and Play Store x86_64 system images
- CMake `3.22.1`
- NDK `28.2.13676358`
- Extra license IDs required by Flutter/Android SDK tools

The shell sets Android environment variables and prepends Nix SDK tools to `PATH`, so `which adb` resolves into the Nix store.

Global Android Studio and `nix-ld` remain available for pragmatic IDE/proprietary-tool support, but the dev shell is the source of truth for terminal builds.

## Validation

Repo validation:

```bash
just fmt
nix flake check --no-warn-dirty
nix develop /home/nico/nixos-config#flutter-android --command flutter doctor -v
```

The shell reported `No issues found` from `flutter doctor -v`.

Milon app validation:

```bash
cd /home/nico/Haggla/Milon/milon-trainer-app
nix develop /home/nico/nixos-config#flutter-android
adb connect 192.168.178.54:<debug-port>
flutter run --flavor development --dart-define API_HOST="https://studio.dev.next.miloncare.com"
```

The app built, installed, and ran on the Pixel 10 over Wi-Fi debugging.

## Follow-Up

- Prefer real-phone development on this HP pilot laptop.
- Emulator workflow exists and should work better on stronger hardware.
- Wireless debugging ports can change; reconnect with the current debug port from the phone.
- If the app is still running and only Flutter detaches, use `flutter attach` rather than reinstalling.

## Useful Commands

```bash
# Enter reproducible Flutter Android shell.
nix develop /home/nico/nixos-config#flutter-android

# Verify the shell is using the Nix SDK.
which adb
flutter doctor -v

# Pair and connect a Pixel over Wi-Fi debugging.
adb pair 192.168.178.54:<pairing-port>
adb connect 192.168.178.54:<debug-port>
adb devices -l

# Run the Milon trainer app.
flutter run --flavor development --dart-define API_HOST="https://studio.dev.next.miloncare.com"

# Reattach if the app is running but the debugger detached.
flutter attach -d 192.168.178.54:<debug-port>

# Diagnose USB instability.
lsusb
journalctl -k --since '15 minutes ago'

# Fix signature mismatch for the trainer app.
adb uninstall com.milongroup.trainerapp
```
