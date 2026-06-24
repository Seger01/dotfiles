#!/bin/bash

# wofi-wallpaper-selector.sh - Interactive wallpaper selector using wofi
# Shows wallpapers for the current theme and reapplies theme with selected wallpaper

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURRENT_THEME_DIR="$SCRIPT_DIR/current-theme"
BACKGROUNDS_DIR="$SCRIPT_DIR/backgrounds"
THEME_SCRIPT="$SCRIPT_DIR/theme.py"

# Read current theme
if [[ ! -f "$CURRENT_THEME_DIR/current-theme.txt" ]]; then
    echo "Error: No current theme found. Please apply a theme first." >&2
    exit 1
fi

CURRENT_THEME=$(cat "$CURRENT_THEME_DIR/current-theme.txt")

# Find wallpaper directory for current theme using theme.py (supports wildcards)
WALLPAPER_DIR=$(python3 "$THEME_SCRIPT" find-wallpaper-dir "$CURRENT_THEME")
if [[ -z "$WALLPAPER_DIR" || ! -d "$WALLPAPER_DIR" ]]; then
    echo "Error: No wallpaper directory found for theme: $CURRENT_THEME" >&2
    exit 1
fi

if [[ -z "$WALLPAPER_DIR" || ! -d "$WALLPAPER_DIR" ]]; then
    echo "Error: No wallpaper directory found for theme: $CURRENT_THEME" >&2
    exit 1
fi

# Get list of wallpapers with full paths
wallpapers=()
while IFS= read -r -d '' file; do
    wallpapers+=("$file")
done < <(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -print0 2>/dev/null | sort -z)

if [[ ${#wallpapers[@]} -eq 0 ]]; then
    echo "Error: No wallpapers found in $WALLPAPER_DIR" >&2
    exit 1
fi

# Show wofi menu with image previews
selected=$(printf 'img:%s\n' "${wallpapers[@]}" | wofi -c ~/.config/wofi/style-wallpaper-conf -s ~/.config/wofi/style-wallpaper.css --show dmenu --prompt "Select wallpaper for $CURRENT_THEME" -n)

if [[ -z "$selected" ]]; then
    echo "No wallpaper selected"
    exit 0
fi

# Remove img: prefix and extract just the filename
selected_path="${selected#img:}"
selected_filename=$(basename "$selected_path")

# Reapply theme with selected wallpaper
echo "Applying theme $CURRENT_THEME with wallpaper: $selected_filename"
exec "$THEME_SCRIPT" apply "$CURRENT_THEME" "$selected_filename"
