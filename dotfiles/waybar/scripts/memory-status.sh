#!/usr/bin/env bash
set -u

escape_json() {
  local value=${1//\\/\\\\}
  value=${value//"/\\"}
  value=${value//$'\n'/\\n}
  printf '%s' "$value"
}

mem_info=$(awk '
  $1 == "MemTotal:" { total = $2 }
  $1 == "MemAvailable:" { available = $2 }
  END {
    if (total > 0) {
      used = total - available
      printf "%.1f %.1f %d", used / 1048576, total / 1048576, (used * 100) / total
    }
  }
' /proc/meminfo)

if [ -z "$mem_info" ]; then
  printf '{"text":"  unavailable","tooltip":"Memory: unavailable"}\n'
  exit 0
fi

read -r used_gib total_gib usage_percent <<< "$mem_info"

top_processes=$(ps -eo comm=,pmem=,rss= --sort=-pmem 2>/dev/null | awk '

  function clean_name(name) {
    sub(/^\./, "", name)
    sub(/-wrapped$/, "", name)
    sub(/-wrappe$/, "", name)
    sub(/-wrapp$/, "", name)
    return name
  }

  NF {
    name = clean_name($1)
    pmem[name] += $2
    rss[name] += $3
  }

  END {
    for (name in rss) {
      printf "%s\t%.1f\t%.1f\n", name, pmem[name], rss[name] / 1048576
    }
  }
' | sort -k2,2nr | awk '
  {
    printf "%s%s %.1f%% (%.1f GiB)", sep, $1, $2, $3
    sep = "\n"
    count++
  }

  count == 5 { exit }
')
if [ -z "$top_processes" ]; then
  top_processes="unavailable"
fi

tooltip=$(printf 'Memory: %s/%s GiB (%s%%)\n----\n%s' "$used_gib" "$total_gib" "$usage_percent" "$top_processes")

printf '{"text":"  %sG/%sG","tooltip":"%s"}\n' "$used_gib" "$total_gib" "$(escape_json "$tooltip")"
