#!/bin/bash

# wallpaper-selector.sh - Selects wallpaper based on theme name and directory structure
# Usage: wallpaper-selector.sh <theme-name> <backgrounds-dir>

THEME_NAME="$1"
BACKGROUNDS_DIR="$2"

if [[ -z "$THEME_NAME" || -z "$BACKGROUNDS_DIR" ]]; then
    echo "Usage: $0 <theme-name> <backgrounds-dir>" >&2
    exit 1
fi

# Function to select a random wallpaper from a directory
select_random_wallpaper() {
    local dir="$1"
    local wallpapers=()
    
    while IFS= read -r -d '' file; do
        wallpapers+=("$file")
    done < <(find "$dir" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -print0 2>/dev/null)
    
    if [[ ${#wallpapers[@]} -eq 0 ]]; then
        return 1
    fi
    
    echo "${wallpapers[RANDOM % ${#wallpapers[@]}]}"
    return 0
}

# 1. Check for exact theme name match
if [[ -d "$BACKGROUNDS_DIR/$THEME_NAME" ]]; then
    wallpaper=$(select_random_wallpaper "$BACKGROUNDS_DIR/$THEME_NAME")
    if [[ -n "$wallpaper" ]]; then
        echo "$wallpaper"
        exit 0
    fi
fi

# 2. Check for wildcard matches (e.g., gruvbox-material-dark-* matches gruvbox-material-dark-hard)
for dir in "$BACKGROUNDS_DIR"/*; do
    [[ ! -d "$dir" ]] && continue
    
    dirname=$(basename "$dir")
    # If directory ends with *, treat it as a wildcard pattern
    if [[ "$dirname" == *\* ]]; then
        # Remove trailing * and check if theme name starts with this pattern
        pattern="${dirname%\*}"
        if [[ "$THEME_NAME" == "$pattern"* ]]; then
            wallpaper=$(select_random_wallpaper "$dir")
            if [[ -n "$wallpaper" ]]; then
                echo "$wallpaper"
                exit 0
            fi
        fi
    fi
done

# 3. Fall back to default directory
if [[ -d "$BACKGROUNDS_DIR/default" ]]; then
    wallpaper=$(select_random_wallpaper "$BACKGROUNDS_DIR/default")
    if [[ -n "$wallpaper" ]]; then
        echo "$wallpaper"
        exit 0
    fi
fi

# No wallpaper found
exit 1
