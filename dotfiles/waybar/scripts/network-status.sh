#!/usr/bin/env bash
set -u

escape_json() {
  local value=${1//\\/\\\\}
  value=${value//"/\\"}
  value=${value//$'\n'/\\n}
  printf '%s' "$value"
}

active_connections=$(nmcli -t -f NAME,TYPE connection show --active 2>/dev/null || true)
devices=$(nmcli -t -f DEVICE,TYPE,STATE,CONNECTION device status 2>/dev/null || true)

vpn_name=$(printf '%s\n' "$active_connections" | awk -F: '$2 == "vpn" { print $1; exit }')
wifi_device=$(printf '%s\n' "$devices" | awk -F: '$2 == "wifi" && $3 == "connected" { print $1; exit }')
wifi_name=$(printf '%s\n' "$devices" | awk -F: '$2 == "wifi" && $3 == "connected" { print $4; exit }')
ethernet_device=$(printf '%s\n' "$devices" | awk -F: '$2 == "ethernet" && $3 == "connected" { print $1; exit }')
ethernet_name=$(printf '%s\n' "$devices" | awk -F: '$2 == "ethernet" && $3 == "connected" { print $4; exit }')

if [ -n "$wifi_name" ]; then
  base_icon="󰤨"
  network_kind="Wi-Fi"
  network_label="SSID: $wifi_name\nDevice: $wifi_device"
elif [ -n "$ethernet_name" ]; then
  base_icon="󰈀"
  network_kind="Ethernet"
  network_label="Connection: $ethernet_name\nDevice: $ethernet_device"
else
  base_icon="󰤭"
  network_kind="Disconnected"
  network_label="No active Wi-Fi or Ethernet connection"
fi

if [ -n "$vpn_name" ]; then
  text="$base_icon 󰌾"
  class="vpn"
  tooltip="Network: ${network_kind}\n${network_label}\nVPN: ${vpn_name}"
elif [ "$network_kind" = "Disconnected" ]; then
  text="$base_icon"
  class="disconnected"
  tooltip="Network: disconnected\n${network_label}\nVPN: off"
else
  text="$base_icon"
  class="connected"
  tooltip="Network: ${network_kind}\n${network_label}\nVPN: off"
fi

printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' "$text" "$(escape_json "$tooltip")" "$class"
