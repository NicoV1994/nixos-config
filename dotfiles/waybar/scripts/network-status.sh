#!/usr/bin/env bash
set -u

escape_json() {
  local value=${1//\\/\\\\}
  value=${value//"/\\"}
  value=${value//$'\n'/\\n}
  printf '%s' "$value"
}

format_rate() {
  awk -v bytes_per_second="${1:-0}" 'BEGIN {
    if (bytes_per_second >= 1048576) {
      printf "%.1f MiB/s", bytes_per_second / 1048576
    } else if (bytes_per_second >= 1024) {
      printf "%.0f KiB/s", bytes_per_second / 1024
    } else {
      printf "%.0f B/s", bytes_per_second
    }
  }'
}

connection_speed() {
  local device=$1
  local rx_file="/sys/class/net/$device/statistics/rx_bytes"
  local tx_file="/sys/class/net/$device/statistics/tx_bytes"
  local state_file="${XDG_RUNTIME_DIR:-/tmp}/waybar-network-stat"

  if [ -z "$device" ] || [ ! -r "$rx_file" ] || [ ! -r "$tx_file" ]; then
    printf 'unavailable'
    return
  fi

  local now rx tx prev_device prev_now prev_rx prev_tx elapsed rx_rate tx_rate
  now=$(date +%s)
  read -r rx < "$rx_file"
  read -r tx < "$tx_file"

  if [ -r "$state_file" ]; then
    read -r prev_device prev_now prev_rx prev_tx < "$state_file" || true
  fi

  printf '%s %s %s %s\n' "$device" "$now" "$rx" "$tx" > "$state_file"

  if [ "${prev_device:-}" != "$device" ] || [ -z "${prev_now:-}" ]; then
    printf 'measuring'
    return
  fi

  elapsed=$((now - prev_now))
  if [ "$elapsed" -le 0 ]; then
    printf 'measuring'
    return
  fi

  rx_rate=$(((rx - prev_rx) / elapsed))
  tx_rate=$(((tx - prev_tx) / elapsed))

  if [ "$rx_rate" -lt 0 ] || [ "$tx_rate" -lt 0 ]; then
    printf 'measuring'
    return
  fi

  printf '↓ %s ↑ %s' "$(format_rate "$rx_rate")" "$(format_rate "$tx_rate")"
}

active_connections=$(nmcli -t -f NAME,TYPE connection show --active 2>/dev/null || true)
devices=$(nmcli -t -f DEVICE,TYPE,STATE,CONNECTION device status 2>/dev/null || true)

vpn_name=$(printf '%s\n' "$active_connections" | awk -F: '$2 == "vpn" { print $1; exit }')
vpn_label=$vpn_name
if printf '%s\n' "$vpn_name" | grep -qi 'proton'; then
  vpn_label="Proton VPN"
fi
wifi_device=$(printf '%s\n' "$devices" | awk -F: '$2 == "wifi" && $3 == "connected" { print $1; exit }')
wifi_name=$(printf '%s\n' "$devices" | awk -F: '$2 == "wifi" && $3 == "connected" { print $4; exit }')
ethernet_device=$(printf '%s\n' "$devices" | awk -F: '$2 == "ethernet" && $3 == "connected" { print $1; exit }')
ethernet_name=$(printf '%s\n' "$devices" | awk -F: '$2 == "ethernet" && $3 == "connected" { print $4; exit }')

if [ -n "$wifi_name" ]; then
  base_icon="󰈁"
  network_kind="Wi-Fi"
  network_device=$wifi_device
  network_label=$(printf 'SSID: %s\nDevice: %s' "$wifi_name" "$wifi_device")
elif [ -n "$ethernet_name" ]; then
  base_icon="󰈁"
  network_kind="Ethernet"
  network_device=$ethernet_device
  network_label=$(printf 'Connection: %s\nDevice: %s' "$ethernet_name" "$ethernet_device")
else
  base_icon="󰖪"
  network_kind="Disconnected"
  network_device=""
  network_label="No active Wi-Fi or Ethernet connection"
fi

speed_label=$(connection_speed "$network_device")

if [ -n "$vpn_name" ]; then
  text="󰌾"
  class="vpn"
  tooltip=$(printf 'Network: %s\n%s\nSpeed: %s\nVPN: %s' "$network_kind" "$network_label" "$speed_label" "$vpn_label")
elif [ "$network_kind" = "Disconnected" ]; then
  text="$base_icon"
  class="disconnected"
  tooltip=$(printf 'Network: disconnected\n%s\nVPN: off' "$network_label")
else
  text="$base_icon"
  class="connected"
  tooltip=$(printf 'Network: %s\n%s\nSpeed: %s\nVPN: off' "$network_kind" "$network_label" "$speed_label")
fi

printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' "$text" "$(escape_json "$tooltip")" "$class"
