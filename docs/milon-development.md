# Milon Development

This repo provides personal machine integration for Milon work. The Milon project repositories remain the source of truth for their own runtime behavior.

## Scope Split

Keep project-owned configuration in the project repos:

- Docker Compose services, networks, bridge names, and ports.
- App environment files and runtime endpoints.
- Project commands such as `npm run start:local` or Flutter flavor commands.
- Team-shared setup that should work for other developers too.

Keep machine-owned configuration in this NixOS repo:

- Local hostnames such as `carenext.test`.
- Host firewall trust for stable Docker bridges such as `br-carenext`.
- Docker, Android Studio, and other workstation packages.
- Reusable Nix dev shells for terminal workflows.
- Personal workflow notes and troubleshooting logs.

## Current Profile

The local Milon profile is enabled in `hosts/nixos/configuration.nix` through `nico.dev.milon`.

CareNext host integration is under `nico.dev.milon.carenext`. It maps the local CareNext hostnames to `127.0.0.1` and trusts the stable Docker bridge created by the CareNext DB Compose stack.

The stable bridge is named `br-carenext`. The bridge is created by `/home/nico/Haggla/Milon/milon-care-next/db/docker-compose.yml`; this repo only trusts it.

Flutter workstation integration is under `nico.dev.milon.flutter`. It installs host-level Android tooling such as Android Studio through Home Manager and enables `nix-ld` for Android Studio's downloaded SDK tools. The terminal build toolchain remains the reusable `#flutter-android` dev shell.

## CareNext Workflow

Start the CareNext stack from its project repo:

```bash
cd /home/nico/Haggla/Milon/milon-care-next
npm run start:local
```

If the Docker network was recreated or the bridge pin changed, recreate the network from the CareNext repo after reviewing the impact:

```bash
npm run db:down
docker network rm app_default_network
npm run db:up:local
```

Then verify the bridge and Traefik routing:

```bash
ip link show br-carenext
curl -i http://carenext.test/
```

## Flutter Workflow

Use the reusable Flutter Android shell from this repo, then follow the Flutter project repo's own README and environment files:

```bash
cd /home/nico/Haggla/Milon/milon-trainer-app
nix develop /home/nico/nixos-config#flutter-android
flutter doctor -v
flutter run --flavor development --dart-define-from-file=env/.env.development
```

See `docs/flutter-android.md` for Android SDK ownership, ADB, real phone, and emulator troubleshooting.
