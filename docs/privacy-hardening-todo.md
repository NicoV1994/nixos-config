# Privacy Hardening Todo

This tracks the remaining work from the HP ProBook 430 G5 privacy-hardening audit. It is intentionally a backlog, not a record of completed changes.

## Current Platform Facts

- Model: HP ProBook 430 G5.
- CPU: Intel Core i5-8250U.
- TPM2: present.
- Boot: UEFI with systemd-boot.
- Secure Boot: disabled.
- Disk layout: plain `ext4` root and plain swap; no LUKS layer observed.
- Radios: Wi-Fi and Bluetooth were unblocked during the audit.
- Thunderbolt: no obvious PCI Thunderbolt controller observed; `boltctl` was not installed.
- Firmware: `fwupd` sees system firmware, Intel ME, SSD, TPM, and Secure Boot db/dbx entries.
- Pending firmware update at audit time: Secure Boot dbx update to `20250902`.

## Already Covered

- `services.fwupd.enable = true`.
- `hardware.enableRedistributableFirmware = true`.
- Intel CPU microcode is enabled through generated hardware config.
- UEFI boot with `systemd-boot`.
- NetworkManager with OpenVPN plugin.
- Proton VPN package, autostart, and Waybar VPN menu.
- Power profiles via `power-profiles-daemon`, `upower`, and Waybar status/toggle scripts.
- Microphone visibility in Waybar and a Hyprland mic mute keybind.
- Browser split: Brave for work, LibreWolf for privacy, Firefox for streaming.
- Firefox installs uBlock Origin declaratively.

## Quick Wins

- Make `networking.firewall.enable = true` explicit, while preserving current trusted Docker development interfaces.
- Set `hardware.bluetooth.powerOnBoot = false` so Bluetooth is available but not enabled at boot.
- Enable TPM userspace support with `security.tpm2.enable` and consider `security.tpm2.pkcs11.enable` if needed.
- Enable encrypted DNS with `services.resolved`, DNSSEC, DNS-over-TLS, and selected resolvers.
- Add `tor-browser` for anonymity-sensitive browsing sessions.
- Add radio visibility/toggle support to Waybar using `rfkill`.
- Add `rfkill` and other small diagnostics packages if scripts depend on them.

## Medium Effort

- Enable `security.apparmor.enable` and validate after reboot.
- Add selective `programs.firejail` wrappers only for high-risk desktop apps that tolerate wrapping.
- Add camera visibility/toggle support if desired. The built-in HP HD Camera is a USB UVC camera; unloading `uvcvideo` is effective but coarse.
- Evaluate USBGuard, then generate and review a policy before enabling a blocking policy.
- Decide whether LibreWolf should be managed declaratively beyond package installation.
- Decide whether Firefox streaming profile should also disable telemetry, or whether privacy hardening should stay isolated to LibreWolf.

## Advanced Projects

- Plan full-disk encryption. This likely requires reinstall or careful migration because the current root and swap are not encrypted.
- Plan Secure Boot through Lanzaboote as a separate boot-chain task. The machine supports UEFI/systemd-boot and TPM2, but Secure Boot is currently disabled.
- Consider TPM-backed unlock only after full-disk encryption exists and a recovery path is tested.
- Add Intel IOMMU kernel parameters only after deciding the tradeoff and validating boot behavior.
- Treat coreboot/Libreboot as future hardware research unless this exact HP model is confirmed supported.

## Tradeoffs To Preserve

- Docker is a developer workflow requirement here, but membership in the `docker` group is a local-root-equivalent security tradeoff.
- Trusted Docker bridge interfaces are intentionally scoped for local CareNext/Milon development. Do not remove them as part of generic privacy hardening without checking that workflow.
- USBGuard and AppArmor can break devices or applications; introduce one layer at a time.
- Secure Boot, TPM unlock, and disk encryption improve physical-access resistance but need a tested rollback and recovery path.
- `powertop` auto-tuning can cause hardware quirks; see `docs/logs/2026-06-07-laptop-power-management.md`.
