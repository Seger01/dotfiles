#!/bin/bash
### Base16 Theme Switcher

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config.toml"
COLOR_DEFS_DIR="$SCRIPT_DIR/color-defs/base16"
TEMPLATES_DIR="$SCRIPT_DIR/templates"
BACKGROUNDS_DIR="$SCRIPT_DIR/backgrounds"
WALLPAPER_SELECTOR="$SCRIPT_DIR/wallpaper-selector.sh"
TEMPLATE_SUBSTITUTER="$SCRIPT_DIR/template-substituter.sh"
WALLPAPER_SETTER="$SCRIPT_DIR/wallpaper-set.sh"
CURRENT_THEME_DIR="$SCRIPT_DIR/current-theme"

# Ensure required scripts are executable
chmod +x "$WALLPAPER_SELECTOR" "$TEMPLATE_SUBSTITUTER" 2>/dev/null || true

# Function to list all available themes
list_themes() {
    echo "Available themes:"
    if [[ ! -d "$COLOR_DEFS_DIR" ]]; then
        echo "Error: Color definitions directory not found: $COLOR_DEFS_DIR" >&2
        exit 1
    fi
    
    find -L "$COLOR_DEFS_DIR" -name "*.yaml" -type f | while read -r file; do
        basename "$file" .yaml
    done | sort
}

# Function to check if a theme has a configured wallpaper
has_wallpaper() {
    local theme_name="$1"
    
    # Check for exact match
    [[ -d "$BACKGROUNDS_DIR/$theme_name" ]] && return 0
    
    # Check for wildcard match
    for dir in "$BACKGROUNDS_DIR"/*; do
        [[ ! -d "$dir" ]] && continue
        local dirname=$(basename "$dir")
        if [[ "$dirname" == *\* ]]; then
            local pattern="${dirname%\*}"
            [[ "$theme_name" == "$pattern"* ]] && return 0
        fi
    done
    
    return 1
}

# Function to list themes with configured wallpapers
list_configured() {
    echo "Themes with configured wallpapers:"
    if [[ ! -d "$COLOR_DEFS_DIR" ]]; then
        echo "Error: Color definitions directory not found: $COLOR_DEFS_DIR" >&2
        exit 1
    fi
    
    find -L "$COLOR_DEFS_DIR" -name "*.yaml" -type f | while read -r file; do
        theme_name=$(basename "$file" .yaml)
        if has_wallpaper "$theme_name"; then
            echo "  $theme_name"
        fi
    done | sort
    
    echo ""
    echo "Wallpaper directories:"
    if [[ -d "$BACKGROUNDS_DIR" ]]; then
        ls -1 "$BACKGROUNDS_DIR" | while read -r dir; do
            [[ -d "$BACKGROUNDS_DIR/$dir" ]] && echo "  $dir"
        done
    fi
}

# Function to update configured themes list file
update_configured_list() {
    local output_file="$CURRENT_THEME_DIR/configured-themes.txt"
    
    if [[ ! -d "$COLOR_DEFS_DIR" ]]; then
        echo "Error: Color definitions directory not found: $COLOR_DEFS_DIR" >&2
        exit 1
    fi
    
    mkdir -p "$CURRENT_THEME_DIR"
    
    # Clear or create the file
    > "$output_file"
    
    # Write all configured themes to file
    find -L "$COLOR_DEFS_DIR" -name "*.yaml" -type f | while read -r file; do
        theme_name=$(basename "$file" .yaml)
        if has_wallpaper "$theme_name"; then
            echo "$theme_name"
        fi
    done | sort >> "$output_file"
    
    echo "Updated configured themes list: $output_file"
}

# Function to parse TOML config
parse_toml() {
    local section=""
    local -n result=$1
    
    while IFS= read -r line; do
        # Skip empty lines and comments
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
        
        # Check for section header
        if [[ "$line" =~ ^\[\[([^]]+)\]\] ]]; then
            section="${BASH_REMATCH[1]}"
            result["${section}_found"]="1"
            continue
        fi
        
        # Parse key-value pairs
        if [[ "$line" =~ ^[[:space:]]*([^=]+)[[:space:]]*=[[:space:]]*(.+)$ ]]; then
            local key="${BASH_REMATCH[1]}"
            local value="${BASH_REMATCH[2]}"
            # Remove leading/trailing whitespace and quotes
            key=$(echo "$key" | xargs)
            value=$(echo "$value" | sed "s/^['\"]//; s/['\"]$//")
            
            if [[ -n "$section" ]]; then
                result["${section}_${key}"]="$value"
            fi
        fi
    done < "$CONFIG_FILE"
}

# Function to expand tilde in paths
expand_path() {
    local path="$1"
    echo "${path/#\~/$HOME}"
}

# Function to apply a theme
apply_theme() {
    local theme_name="$1"
    local wallpaper_filename="$2"
    local color_file="$COLOR_DEFS_DIR/${theme_name}.yaml"
    
    if [[ ! -f "$color_file" ]]; then
        echo "Error: Theme not found: $theme_name" >&2
        echo "Available themes:" >&2
        list_themes >&2
        exit 1
    fi
    
    echo "Applying theme: $theme_name"
    
    # Select wallpaper
    local wallpaper
    if [[ -n "$wallpaper_filename" ]]; then
        # Find wallpaper file in theme directory
        if [[ -d "$BACKGROUNDS_DIR/$theme_name" ]]; then
            wallpaper="$BACKGROUNDS_DIR/$theme_name/$wallpaper_filename"
        else
            # Check for wildcard match
            for dir in "$BACKGROUNDS_DIR"/*; do
                [[ ! -d "$dir" ]] && continue
                local dirname=$(basename "$dir")
                if [[ "$dirname" == *\* ]]; then
                    local pattern="${dirname%\*}"
                    if [[ "$theme_name" == "$pattern"* ]]; then
                        wallpaper="$dir/$wallpaper_filename"
                        break
                    fi
                fi
            done
            # Fall back to default
            if [[ -z "$wallpaper" && -d "$BACKGROUNDS_DIR/default" ]]; then
                wallpaper="$BACKGROUNDS_DIR/default/$wallpaper_filename"
            fi
        fi
        
        if [[ ! -f "$wallpaper" ]]; then
            echo "Error: Wallpaper file not found: $wallpaper_filename" >&2
            exit 1
        fi
    else
        # Select wallpaper automatically
        wallpaper=$("$WALLPAPER_SELECTOR" "$theme_name" "$BACKGROUNDS_DIR" 2>/dev/null) || wallpaper=""
    fi
    
    if [[ -n "$wallpaper" ]]; then
        echo "Selected wallpaper: $wallpaper"
        # Store wallpaper path for potential use by applications
        mkdir -p "$CURRENT_THEME_DIR"
        echo "$wallpaper" > "$CURRENT_THEME_DIR/current-wallpaper.txt"
        echo "$theme_name" > "$CURRENT_THEME_DIR/current-theme.txt"

        # Set wallpaper 
        $WALLPAPER_SETTER $wallpaper
    else
        echo "No wallpaper found for theme"
    fi
    
    # Parse config.toml
    declare -A config
    parse_toml config
    
    # Process each application section
    local sections=()
    for key in "${!config[@]}"; do
        if [[ "$key" == *_found ]]; then
            local section="${key%_found}"
            sections+=("$section")
        fi
    done
    
    for section in "${sections[@]}"; do
        local input_path="${config[${section}_input_path]}"
        local output_path=$(expand_path "${config[${section}_output_path]}")
        local post_hook="${config[${section}_post_hook]}"
        
        if [[ -z "$input_path" ]]; then
            echo "Warning: No input_path defined for $section, skipping" >&2
            continue
        fi
        
        # Expand path and handle relative paths
        input_path=$(expand_path "$input_path")
        
        # If path is relative (doesn't start with /), prepend SCRIPT_DIR
        if [[ "$input_path" != /* ]]; then
            input_path="$SCRIPT_DIR/$input_path"
        fi
        
        if [[ ! -f "$input_path" ]]; then
            echo "Warning: Template file not found: $input_path, skipping" >&2
            continue
        fi
        
        if [[ -z "$output_path" ]]; then
            echo "Warning: No output_path defined for $section, skipping" >&2
            continue
        fi
        
        echo "Processing $section..."
        echo "  Template: $input_path"
        echo "  Output: $output_path"
        
        # Create output directory if it doesn't exist
        local output_dir=$(dirname "$output_path")
        mkdir -p "$output_dir"
        
        # Create temporary file
        local temp_file=$(mktemp)
        trap "rm -f '$temp_file'" EXIT
        
        # Substitute template variables
        if "$TEMPLATE_SUBSTITUTER" "$input_path" "$temp_file" "$color_file" "$wallpaper"; then
            # Copy to output location
            cp "$temp_file" "$output_path"
            echo "  ✓ Applied"
            
            # Execute post_hook if defined
            if [[ -n "$post_hook" ]]; then
                echo "  Running post-hook..."
                eval "$post_hook" &>/dev/null || echo "  Warning: Post-hook failed" >&2
            fi
        else
            echo "  ✗ Failed to process template" >&2
        fi
        
        rm -f "$temp_file"
    done
    
    echo "Theme applied successfully!"
}

# Main command handling
case "${1:-}" in
    list)
        list_themes
        ;;
    list-configured)
        list_configured
        ;;
    update)
        update_configured_list
        ;;
    apply)
        if [[ -z "$2" ]]; then
            echo "Usage: $0 apply <theme-name> [wallpaper-filename]" >&2
            exit 1
        fi
        apply_theme "$2" "$3"
        ;;
    *)
        echo "Usage: $0 {list|list-configured|update|apply <theme-name> [wallpaper-filename]}"
        echo ""
        echo "Commands:"
        echo "  list                            - List all available themes"
        echo "  list-configured                 - List themes with configured wallpapers"
        echo "  update                          - Update configured themes list file"
        echo "  apply <theme> [wallpaper]       - Apply a theme with optional wallpaper filename"
        exit 1
        ;;
esac

