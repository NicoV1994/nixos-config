# Flutter Android Development

This setup exposes a reusable Flutter Android shell for customer projects without committing Nix files into those projects.

## Daily Workflow

From any Flutter project, enter the reusable shell first:

```bash
nix develop /home/nico/nixos-config#flutter-android
flutter doctor -v
which adb
flutter pub get
flutter devices
flutter run
```

`which adb` should resolve to a Nix store path from the dev shell, for example:

```text
/nix/store/...-androidsdk/libexec/android-sdk/platform-tools/adb
```

It should not resolve to Android Studio's mutable SDK path:

```text
/home/nico/Android/Sdk/platform-tools/adb
```

## SDK Ownership

The shell uses a Nix-managed Android SDK instead of `/home/nico/Android/Sdk`.
It keeps Android user state, including AVD definitions, under `/home/nico/.config/.android`.
It includes Android SDK platforms 34, 35, and 36, CMake `3.22.1`, and NDK `28.2.13676358`, which current Flutter/Android Gradle builds request.

Android Studio remains useful as an IDE, but terminal builds should use the Nix shell as the source of truth.

To create a project-local starter flake later:

```bash
nix flake init -t /home/nico/nixos-config#flutter-android
```

## Real Phone Workflow

Prefer a real Android phone on this HP pilot laptop because the emulator is slow/flaky on this hardware.

For Wi-Fi debugging:

```bash
nix develop /home/nico/nixos-config#flutter-android
adb pair <phone-lan-ip>:<pairing-port>
adb connect <phone-lan-ip>:<debug-port>
adb devices -l
flutter devices
```

The pairing port is shown only after tapping `Pair device with pairing code` on the phone.
The debug/connect port is shown on the main Wireless debugging screen and is usually different.

Pixel devices may show an address like `10.2.0.2:<port>` on the Wireless debugging screen. If the laptop is on `192.168.178.0/24`, that address is not reachable. Use the phone's real Wi-Fi IP from Wi-Fi network details instead, for example:

```bash
adb pair 192.168.178.54:<pairing-port>
adb connect 192.168.178.54:<debug-port>
```

Check reachability when pairing fails:

```bash
ip route
adb devices -l
adb mdns services
```

If `adb connect` works but `flutter run` later says the device is not found, the wireless debugging port probably changed or the phone disabled wireless debugging. Re-open the phone's Wireless debugging screen, read the current debug port, and reconnect:

```bash
adb connect <phone-lan-ip>:<current-debug-port>
```

If the app is already running and only the Flutter debugger detached, reconnect without reinstalling:

```bash
flutter attach -d <phone-lan-ip>:<current-debug-port>
```

## Milon Trainer App

For the Milon trainer app, use the Android flavor explicitly and provide `API_HOST`:

```bash
cd /home/nico/Haggla/Milon/milon-trainer-app
nix develop /home/nico/nixos-config#flutter-android
adb connect 192.168.178.54:<current-debug-port>
flutter run --flavor development --dart-define API_HOST="https://studio.dev.next.miloncare.com"
```

If the app keeps running but the terminal reports `Lost connection to device`, first check whether ADB still sees the phone:

```bash
adb devices -l
flutter attach -d 192.168.178.54:<current-debug-port>
```

Build without installing:

```bash
flutter build apk --debug --flavor development
```

If install fails with a signature mismatch:

```text
INSTALL_FAILED_UPDATE_INCOMPATIBLE: Existing package com.milongroup.trainerapp signatures do not match newer version
```

remove the old differently signed app and retry:

```bash
adb uninstall com.milongroup.trainerapp
flutter run --flavor development --dart-define API_HOST="https://studio.dev.next.miloncare.com"
```

## USB Debugging Troubleshooting

If USB debugging does not show a device, first verify whether Linux sees the phone at all:

```bash
lsusb
journalctl -k --since '15 minutes ago'
adb devices -l
```

If `journalctl -k` repeatedly shows the phone connecting and immediately disconnecting, for example:

```text
Product: Pixel 10
Manufacturer: Google
USB disconnect
device descriptor read/64, error -71
```

then this is USB cable/port/controller negotiation, not a Flutter or Android SDK problem. Try another cable, another laptop port, reversing the USB-C plug, a USB-A to USB-C cable, or a simple USB 2.0 hub. Rebooting can reset the `xhci_hcd` controller, but it is not the first fix.

If USB is stable but ADB says `unauthorized`, unlock the phone and accept the debugging prompt. If no prompt appears, revoke USB debugging authorizations on the phone, reconnect, and accept the new prompt.

## Emulator Workflow

For Android emulators under Wayland, the shell sets `QT_QPA_PLATFORM=xcb` because the Android emulator does not ship a Wayland Qt platform plugin.

The emulator works in principle through the Nix-managed SDK. On this HP ProBook pilot laptop, GUI emulation was slow and unstable; prefer a real phone here. On better hardware, this workflow may be fine.

Create a lighter local emulator with:

```bash
nix develop /home/nico/nixos-config#flutter-android
avdmanager create avd -n medium_api_34_nix -k "system-images;android-34;google_apis_playstore;x86_64" -d medium_phone
```

Start that emulator headless with logs:

```bash
nix develop /home/nico/nixos-config#flutter-android
emulator -avd medium_api_34_nix -no-window -no-audio -no-snapshot -no-boot-anim -verbose
```

Run the Milon app on an emulator:

```bash
nix develop /home/nico/nixos-config#flutter-android
flutter run -d emulator-5554 --flavor development --dart-define API_HOST="https://studio.dev.next.miloncare.com"
```
