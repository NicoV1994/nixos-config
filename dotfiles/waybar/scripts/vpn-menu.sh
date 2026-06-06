#!/usr/bin/env bash
set -u

active_vpn=$(nmcli -t -f NAME,TYPE connection show --active 2>/dev/null | awk -F: '$2 == "vpn" { print $1; exit }')

if [ -n "$active_vpn" ]; then
  current="Active VPN: $active_vpn"
else
  current="Active VPN: none"
fi

choice=$(
  printf '%s\n' \
    "$current" \
    "Open Proton VPN" \
    "Connect milon PROD" \
    "Connect milon DEV" \
    "Disconnect VPN" \
    "Open Network Settings" \
  | wofi --dmenu --prompt "VPN"
)

case "$choice" in
  "Open Proton VPN")
    protonvpn-app &
    ;;
  "Connect milon PROD")
    nmcli connection up "milon PROD"
    ;;
  "Connect milon DEV")
    nmcli connection up "milon DEV"
    ;;
  "Disconnect VPN")
    if [ -n "$active_vpn" ]; then
      nmcli connection down "$active_vpn"
    fi
    ;;
  "Open Network Settings")
    nm-connection-editor
    ;;
esac
