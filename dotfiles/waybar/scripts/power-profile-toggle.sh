#!/usr/bin/env bash
set -u

if ! command -v powerprofilesctl >/dev/null 2>&1; then
  exit 0
fi

current=$(powerprofilesctl get 2>/dev/null || true)
available=$(powerprofilesctl list 2>/dev/null | awk '
  /^\* [a-z-]+:/ { sub(":", "", $2); print $2 }
  /^  [a-z-]+:/ { sub(":", "", $1); print $1 }
')

ordered=""

for preferred in power-saver balanced performance; do
  if printf '%s\n' "$available" | grep -qx "$preferred"; then
    ordered=$(printf '%s\n%s' "$ordered" "$preferred" | awk 'NF')
  fi
done

if [ -z "$ordered" ]; then
  exit 0
fi

next=$(printf '%s\n' "$ordered" | awk -v current="$current" '
  $0 == current {
    found = 1
    next
  }

  found && NF {
    print
    exit
  }
')

if [ -z "$next" ]; then
  next=$(printf '%s\n' "$ordered" | awk 'NF { print; exit }')
fi

if [ -n "$next" ] && [ "$next" != "$current" ]; then
  powerprofilesctl set "$next"
fi
