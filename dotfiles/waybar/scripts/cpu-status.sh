#!/usr/bin/env bash
set -u

escape_json() {
  local value=${1//\\/\\\\}
  value=${value//"/\\"}
  value=${value//$'\n'/\\n}
  printf '%s' "$value"
}

state_dir=${XDG_RUNTIME_DIR:-/tmp}
state_file="$state_dir/waybar-cpu-stat"

read -r _ user nice system idle iowait irq softirq steal _ < /proc/stat
idle_all=$((idle + iowait))
non_idle=$((user + nice + system + irq + softirq + steal))
total=$((idle_all + non_idle))

usage=0
if [ -r "$state_file" ]; then
  read -r prev_total prev_idle < "$state_file" || true
  total_delta=$((total - ${prev_total:-0}))
  idle_delta=$((idle_all - ${prev_idle:-0}))

  if [ "$total_delta" -gt 0 ]; then
    usage=$(((100 * (total_delta - idle_delta) + total_delta / 2) / total_delta))
  fi
fi

printf '%s %s\n' "$total" "$idle_all" > "$state_file"

if [ "$usage" -lt 0 ]; then
  usage=0
elif [ "$usage" -gt 100 ]; then
  usage=100
fi

icons=(▁ ▂ ▃ ▄ ▅ ▆ ▇ █)
icon_index=$((usage * (${#icons[@]} - 1) / 100))
bars="${icons[$icon_index]}${icons[$icon_index]}${icons[$icon_index]}${icons[$icon_index]}"

top_processes=$(ps -eo comm=,pcpu= --sort=-pcpu 2>/dev/null | awk '
  function clean_name(name) {
    sub(/^\./, "", name)
    sub(/-wrapped$/, "", name)
    sub(/-wrappe$/, "", name)
    sub(/-wrapp$/, "", name)
    return name
  }

  $1 !~ /^(ps|awk|bash)$/ {
    name = clean_name($1)
    cpu[name] += $2
  }

  END {
    for (name in cpu) {
      printf "%s\t%.1f\n", name, cpu[name]
    }
  }
' | sort -k2,2nr | awk '
  {
    printf "%s%s %.1f%%", sep, $1, $2
    sep = "\n"
    count++
  }

  count == 5 { exit }
')
if [ -z "$top_processes" ]; then
  top_processes="unavailable"
fi

tooltip=$(printf 'CPU: %d%%\n----\n%s' "$usage" "$top_processes")

printf '{"text":"  %s %2d%%","tooltip":"%s"}\n' "$bars" "$usage" "$(escape_json "$tooltip")"
