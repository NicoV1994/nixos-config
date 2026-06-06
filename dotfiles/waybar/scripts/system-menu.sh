#!/usr/bin/env bash
set -u

choice=$(
  printf '%s\n' \
    "  Bluetooth Settings" \
    "  File Manager" \
    "  Lock" \
    "󰍃  Logout" \
    "⏻  Shutdown" \
    "󰜉  Reboot" \
  | wofi --dmenu --prompt "System"
)

case "$choice" in
  "  Bluetooth Settings")
    blueman-manager &
    ;;
  "  File Manager")
    thunar &
    ;;
  "  Lock")
    gtklock &
    ;;
  "󰍃  Logout")
    uwsm stop
    ;;
  "⏻  Shutdown")
    systemctl poweroff
    ;;
  "󰜉  Reboot")
    systemctl reboot
    ;;
esac
