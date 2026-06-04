#!/usr/bin/env bash
set -u

escape_json() {
  local value=${1//\\/\\\\}
  value=${value//"/\\"}
  value=${value//$'\n'/\\n}
  printf '%s' "$value"
}

volume_info=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null || true)

if [ -z "$volume_info" ]; then
  printf '{"text":"","tooltip":"Microphone: unavailable","class":"muted"}\n'
  exit 0
fi

volume=$(printf '%s\n' "$volume_info" | grep -oE '[0-9]+\.[0-9]+' | head -n1)
volume_percent=$(awk -v volume="${volume:-0}" 'BEGIN { printf "%d", (volume * 100) + 0.5 }')

if printf '%s\n' "$volume_info" | grep -q '\[MUTED\]'; then
  tooltip="Microphone: muted\nInput gain: ${volume_percent}%"
  printf '{"text":"","tooltip":"%s","class":"muted"}\n' "$(escape_json "$tooltip")"
  exit 0
fi

signal_percent=$(
  timeout 0.3s pw-record --target @DEFAULT_AUDIO_SOURCE@ --format s16 --rate 16000 --channels 1 - 2>/dev/null \
    | od -An -td2 -v \
    | awk '
        {
          for (i = 1; i <= NF; i++) {
            sum += $i * $i
            count++
          }
        }
        END {
          if (count == 0) {
            print 0
            exit
          }

          raw = (sqrt(sum / count) / 32767) * 100

          # Ignore low-level headset hiss, then scale speech into a useful range.
          if (raw < 1.5) {
            percent = 0
          } else {
            percent = int((raw - 1.5) * 8)
          }

          if (percent > 100) percent = 100
          printf "%d", percent
        }
      '
)

signal_percent=${signal_percent:-0}

if [ "$signal_percent" -ge 35 ]; then
  meter="▁▃▅▇"
  text=" ${meter}"
  class="active loud"
elif [ "$signal_percent" -ge 15 ]; then
  meter="▁▃▅"
  text=" ${meter}"
  class="active signal"
elif [ "$signal_percent" -ge 4 ]; then
  meter="▁▃"
  text=" ${meter}"
  class="active signal"
else
  meter="▁"
  text=""
  class="active quiet"
fi

tooltip="Microphone: on\nInput gain: ${volume_percent}%\nSignal: ${meter} ${signal_percent}%"
printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' "$text" "$(escape_json "$tooltip")" "$class"
