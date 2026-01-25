#!/bin/bash

# wofi-theme-selector.sh - Interactive theme selector using wofi
# Shows configured themes and applies selected theme

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_SCRIPT="$SCRIPT_DIR/theme.sh"
CONFIGURED_THEMES_FILE="$SCRIPT_DIR/current-theme/configured-themes.txt"

# Check if the themes file exists and has content
if [[ ! -f "$CONFIGURED_THEMES_FILE" ]]; then
    echo "Error: No configured themes file found. Run '$THEME_SCRIPT update' first." >&2
    exit 1
fi

# Read themes into array
themes=()
while IFS= read -r theme; do
    [[ -n "$theme" ]] && themes+=("$theme")
done < "$CONFIGURED_THEMES_FILE"

if [[ ${#themes[@]} -eq 0 ]]; then
    echo "Error: No configured themes found." >&2
    exit 1
fi

# Show wofi menu
selected=$(printf '%s\n' "${themes[@]}" | wofi --dmenu --prompt "Select theme")

if [[ -z "$selected" ]]; then
    echo "No theme selected"
    exit 0
fi

# Apply the selected theme
echo "Applying theme: $selected"
exec "$THEME_SCRIPT" apply "$selected"
