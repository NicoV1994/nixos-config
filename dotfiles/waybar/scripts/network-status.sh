#!/usr/bin/env bash
set -u

escape_json() {
  local value=${1//\\/\\\\}
  value=${value//"/\\"}
  value=${value//$'\n'/\\n}
  printf '%s' "$value"
}

active_connections=$(nmcli -t -f NAME,TYPE connection show --active 2>/dev/null || true)

vpn_name=$(printf '%s\n' "$active_connections" | awk -F: '$2 == "vpn" { print $1; exit }')
wifi_name=$(printf '%s\n' "$active_connections" | awk -F: '$2 == "wifi" { print $1; exit }')
ethernet_name=$(printf '%s\n' "$active_connections" | awk -F: '$2 == "ethernet" { print $1; exit }')

if [ -n "$wifi_name" ]; then
  base_icon="󰤢"
  network_label="$wifi_name"
elif [ -n "$ethernet_name" ]; then
  base_icon="󰈀"
  network_label="$ethernet_name"
else
  base_icon="󰤠"
  network_label="Disconnected"
fi

if [ -n "$vpn_name" ]; then
  text="$base_icon 󰌾"
  class="vpn"
  tooltip="Network: ${network_label}\nVPN: ${vpn_name}"
elif [ "$network_label" = "Disconnected" ]; then
  text="$base_icon"
  class="disconnected"
  tooltip="Network: disconnected\nVPN: off"
else
  text="$base_icon"
  class="connected"
  tooltip="Network: ${network_label}\nVPN: off"
fi

printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' "$text" "$(escape_json "$tooltip")" "$class"
