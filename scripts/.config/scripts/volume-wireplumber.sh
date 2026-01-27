#!/usr/bin/env bash
set -euo pipefail

# Get volume + mute state from wpctl
status="$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || true)"

# Fallback if wpctl fails
if [[ -z "${status}" ]]; then
  printf '%s\n' '{"text":"","tooltip":"Audio: unavailable","class":"volume-unavailable"}'
  exit 0
fi

# Parse volume (float 0.00..1.00)
vol_float="$(awk '{print $2}' <<<"$status")"

# Detect mute (some versions append "[MUTED]" instead of "Muted: yes")
muted="no"
if grep -qiE '\[muted\]|muted:\s*yes' <<<"$status"; then
  muted="yes"
fi

# Convert to percent (rounded)
vol_pct="$(awk -v v="$vol_float" 'BEGIN{printf("%d\n", (v*100)+0.5)}')"

# Hide module only when volume is 0%, regardless of mute state
if [[ "$vol_pct" -le 0 ]]; then
  printf '%s\n' '{"text":"","tooltip":"0%","class":"volume-hidden"}'
  exit 0
fi

# If muted, always show mute icon (regardless of volume)
if [[ "$muted" == "yes" ]]; then
  icon=""   # Choose your mute icon (example: "" = nf-mdi-volume_mute, or pick another)
  printf '{"text":"%s","tooltip":"Muted (%s%%)","class":"volume-muted"}\n' "$icon" "$vol_pct"
  exit 0
fi

# Pick icon for non-muted state: low / medium / high
icon=""
if [[ "$vol_pct" -ge 67 ]]; then
  icon=""
elif [[ "$vol_pct" -ge 34 ]]; then
  icon=""
else
  icon=""
fi

# Output JSON for Waybar custom module.
printf '{"text":"%s","tooltip":"%s%%","class":"volume"}\n' "$icon" "$vol_pct"
