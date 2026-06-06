# Laptop Power Management

## Problem

Improve battery life on the HP NixOS laptop without stacking conflicting power-management daemons.

## Context

The baseline uses `power-profiles-daemon` and `upower`. TLP and `auto-cpufreq` are intentionally disabled to avoid overlapping policy decisions.

## Decision

Enable `powerManagement.powertop.enable` for additional auto-tuning while keeping `power-profiles-daemon` as the main profile switcher.

## Risk

Powertop auto-tuning can occasionally cause device-specific quirks, especially around USB devices, audio devices, wake behavior, or peripherals entering aggressive power-save modes.

## Debugging

If new hardware, USB, audio, wake, or peripheral issues appear after enabling this baseline, temporarily disable `powerManagement.powertop.enable` first and rebuild/test before changing the power profile daemon setup.

Useful commands:

```bash
powerprofilesctl list
powerprofilesctl get
upower -d
powertop
```
