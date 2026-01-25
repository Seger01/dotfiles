#!/usr/bin/env bash
set -euo pipefail

# Single wallpaper for all monitors:
WALLPAPER="{{image}}"

# Wait until swww daemon is up (max ~3s)
for i in {1..50}; do
    if swww query >/dev/null 2>&1; then
        break
    fi
    sleep 0.1
done

# If still not responding, bail
if ! swww query >/dev/null 2>&1; then
    echo "swww daemon not responding, aborting wallpaper set" >&2
    exit 1
fi

# For each active Hyprland output, set the wallpaper
hyprctl -j monitors | jq -r '.[].name' | while read -r MON; do
    swww img "$WALLPAPER" -o "$MON"
done
