#!/bin/bash

# template-substituter.sh - Substitutes base16 color variables in templates
# Usage: template-substituter.sh <template-file> <output-file> <color-yaml-file> [wallpaper-path]

set -e

TEMPLATE_FILE="$1"
OUTPUT_FILE="$2"
COLOR_YAML="$3"
WALLPAPER_PATH="${4:-}"

if [[ -z "$TEMPLATE_FILE" || -z "$OUTPUT_FILE" || -z "$COLOR_YAML" ]]; then
    echo "Usage: $0 <template-file> <output-file> <color-yaml-file> [wallpaper-path]" >&2
    exit 1
fi

if [[ ! -f "$TEMPLATE_FILE" ]]; then
    echo "Error: Template file not found: $TEMPLATE_FILE" >&2
    exit 1
fi

if [[ ! -f "$COLOR_YAML" ]]; then
    echo "Error: Color YAML file not found: $COLOR_YAML" >&2
    exit 1
fi

# Parse YAML and extract color values
declare -A colors
variant=""

while IFS= read -r line; do
    if [[ "$line" =~ ^[[:space:]]*(base[0-9A-F]{2}):[[:space:]]*\"?#?([0-9a-fA-F]{6})\"? ]]; then
        key="${BASH_REMATCH[1]}"
        value="${BASH_REMATCH[2]}"
        colors["$key"]="$value"
    elif [[ "$line" =~ ^variant:[[:space:]]*\"?([a-z]+)\"? ]]; then
        variant="${BASH_REMATCH[1]}"
    fi
done < "$COLOR_YAML"

# Verify we have all 16 base16 colors
required_colors=(base00 base01 base02 base03 base04 base05 base06 base07 base08 base09 base0A base0B base0C base0D base0E base0F)
for color in "${required_colors[@]}"; do
    if [[ -z "${colors[$color]}" ]]; then
        echo "Error: Missing color definition for $color in $COLOR_YAML" >&2
        exit 1
    fi
done

# Read template
template_content=$(<"$TEMPLATE_FILE")

# Substitute each color variable (with # prefix)
for color in "${!colors[@]}"; do
    value="${colors[$color]}"
    [[ "$value" != \#* ]] && value="#$value"
    template_content="${template_content//\{\{$color\}\}/$value}"
done

# Substitute stripped hex values (without #)
for color in "${!colors[@]}"; do
    value="${colors[$color]}"
    template_content="${template_content//\{\{${color}_stripped\}\}/$value}"
done

# Substitute wallpaper variable if provided
if [[ -n "$WALLPAPER_PATH" ]]; then
    template_content="${template_content//\{\{wallpaper\}\}/$WALLPAPER_PATH}"
fi

# Substitute variant variable (default to "dark" if not specified)
[[ -z "$variant" ]] && variant="dark"
template_content="${template_content//\{\{variant\}\}/$variant}"

# Write to output file
echo "$template_content" > "$OUTPUT_FILE"

exit 0
