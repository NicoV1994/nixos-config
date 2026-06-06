#!/usr/bin/env bash
set -u

escape_json() {
  local value=${1//\\/\\\\}
  value=${value//"/\\"}
  value=${value//$'\n'/\\n}
  printf '%s' "$value"
}

battery_dir=""
for candidate in /sys/class/power_supply/BAT*; do
  if [ -d "$candidate" ]; then
    battery_dir=$candidate
    break
  fi
done

battery_icon="󰂑"
battery_label="--%"
battery_status="unavailable"
battery_class="unavailable"
remaining_time="unavailable"
remaining_minutes=""
energy_rate="unavailable"

if [ -n "$battery_dir" ] && [ -r "$battery_dir/capacity" ]; then
  read -r capacity < "$battery_dir/capacity"
  battery_label="${capacity}%"

  if [ -r "$battery_dir/status" ]; then
    read -r battery_status < "$battery_dir/status"
  else
    battery_status="unknown"
  fi

  case "$battery_status" in
    Charging)
      battery_icon="󰂄"
      battery_class="charging"
      ;;
    Full|"Not charging")
      battery_icon="󰚥"
      battery_class="plugged"
      ;;
    *)
      battery_class="healthy"
      if [ "$capacity" -le 5 ]; then
        battery_icon="󰂎"
      elif [ "$capacity" -le 10 ]; then
        battery_icon="󰁺"
      elif [ "$capacity" -le 20 ]; then
        battery_icon="󰁻"
      elif [ "$capacity" -le 30 ]; then
        battery_icon="󰁼"
      elif [ "$capacity" -le 40 ]; then
        battery_icon="󰁽"
      elif [ "$capacity" -le 50 ]; then
        battery_icon="󰁾"
      elif [ "$capacity" -le 60 ]; then
        battery_icon="󰁿"
      elif [ "$capacity" -le 70 ]; then
        battery_icon="󰂀"
      elif [ "$capacity" -le 80 ]; then
        battery_icon="󰂁"
      elif [ "$capacity" -le 90 ]; then
        battery_icon="󰂂"
      else
        battery_icon="󰁹"
      fi

      if [ "$capacity" -le 10 ]; then
        battery_class="critical"
      elif [ "$capacity" -le 40 ]; then
        battery_class="warning"
      fi
      ;;
  esac
fi

if command -v upower >/dev/null 2>&1; then
  battery_device=$(upower -e 2>/dev/null | grep '/battery_' | head -n1 || true)
  if [ -n "$battery_device" ]; then
    upower_info=$(upower -i "$battery_device" 2>/dev/null || true)
    remaining_time=$(printf '%s\n' "$upower_info" | awk -F: '/time to empty|time to full/ { sub(/^[[:space:]]+/, "", $2); print $2; exit }')
    energy_rate=$(printf '%s\n' "$upower_info" | awk -F: '/energy-rate/ { sub(/^[[:space:]]+/, "", $2); print $2; exit }')
  fi
fi

if [ -z "$remaining_time" ]; then
  remaining_time="unavailable"
else
  remaining_minutes=$(printf '%s\n' "$remaining_time" | awk '
    {
      value = $1
      gsub(",", ".", value)

      if ($2 ~ /^hour/) {
        printf "%d", value * 60
      } else if ($2 ~ /^minute/) {
        printf "%d", value
      }
    }
  ')
fi

if [ -z "$energy_rate" ]; then
  energy_rate="unavailable"
fi

case "$battery_status" in
  Charging|Full|"Not charging")
    ;;
  *)
    if [ -n "$remaining_minutes" ]; then
      if [ "$remaining_minutes" -le 10 ]; then
        battery_class="critical"
      elif [ "$remaining_minutes" -le 40 ]; then
        battery_class="warning"
      else
        battery_class="healthy"
      fi
    fi
    ;;
esac

profile="unavailable"
profiles="unavailable"
if command -v powerprofilesctl >/dev/null 2>&1; then
  profile=$(powerprofilesctl get 2>/dev/null || true)
  profiles=$(powerprofilesctl list 2>/dev/null | awk '
    /^\* [a-z-]+:/ { sub(":", "", $2); print $2 }
    /^  [a-z-]+:/ { sub(":", "", $1); print $1 }
  ')
fi

case "$profile" in
  power-saver)
    profile_icon="󰌪"
    profile_class="power-saver"
    ;;
  balanced)
    profile_icon="󰾅"
    profile_class="balanced"
    ;;
  performance)
    profile_icon="󰓅"
    profile_class="performance"
    ;;
  *)
    profile_icon="󰌪"
    profile_class="unavailable"
    ;;
esac

if [ -z "$profiles" ]; then
  profiles="unavailable"
fi

tooltip=$(printf 'Battery: %s %s\nRemaining: %s\nPower draw: %s\nPower profile: %s\nAvailable:\n%s' "$battery_status" "$battery_label" "$remaining_time" "$energy_rate" "${profile:-unknown}" "$profiles")
class="$profile_class $battery_class"

printf '{"text":"%s %s %s","tooltip":"%s","class":"%s"}\n' "$profile_icon" "$battery_icon" "$battery_label" "$(escape_json "$tooltip")" "$class"
