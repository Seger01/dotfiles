# Base16 Theme Switcher

A system-wide theme switcher for base16 color schemes with wallpaper management.

## Features

- Apply base16 themes to multiple applications
- Automatic wallpaper selection with theme-specific and wildcard support
- Template-based configuration for easy customization
- Post-hook execution for reloading applications
- Support for 15+ applications out of the box

## Directory Structure

```
theme-switcher/
├── theme.sh                  # Main theme switcher script
├── template-substituter.sh   # Template variable substitution
├── wallpaper-selector.sh     # Wallpaper selection logic
├── config.toml               # Application configuration
├── color-defs/
│   └── base16/              # Base16 color scheme YAML files (200+ themes)
├── templates/               # Application template files
│   ├── kitty-colors.conf
│   ├── hyprland-colors.conf
│   ├── hyprpaper.conf
│   ├── colors.css           # Waybar, Wofi, GTK
│   ├── starship-colors.toml
│   ├── tmux-colors.conf
│   ├── neovim-colors.lua
│   ├── spotify-player-theme.toml
│   ├── yazi-theme.toml
│   ├── gtk-colors.css
│   ├── spotify-colors.ini   # Spicetify
│   ├── sddm-silent-template.conf
│   ├── sddm_theme_copy.sh
│   ├── folder-color.txt
│   └── obsidian-minimal-colors.css
├── backgrounds/            # Wallpaper directories
│   ├── default/           # Fallback wallpapers
│   ├── theme-name/        # Theme-specific wallpapers
│   └── theme-prefix-*/    # Wildcard matching wallpapers
└── themes/                 # Current theme state
    ├── current-theme.txt
    └── current-wallpaper.txt
```

## Supported Applications

- **Kitty** - Terminal emulator
- **Hyprland** - Wayland compositor
- **Hyprpaper** - Wallpaper daemon
- **Waybar** - Status bar
- **Wofi** - Application launcher
- **Starship** - Shell prompt
- **Tmux** - Terminal multiplexer
- **Neovim** - Text editor (base16-colorscheme plugin)
- **Spotify Player** - TUI music player
- **Yazi** - File manager
- **GTK 3/4** - GTK applications
- **Spicetify** - Spotify theming
- **SDDM** - Display manager
- **Papirus Folders** - Icon themes
- **Obsidian** - Note-taking app

## Usage

### List all available themes
```bash
./theme.sh list
```

### List themes with configured wallpapers
```bash
./theme.sh list-configured
```

### Apply a theme
```bash
./theme.sh apply <theme-name>
```

Example:
```bash
./theme.sh apply catppuccin-mocha
./theme.sh apply gruvbox-material-dark-hard
./theme.sh apply monokai
```

## Wallpaper Configuration

Wallpapers are selected in the following order:

1. **Exact match**: `backgrounds/<theme-name>/`
2. **Wildcard match**: `backgrounds/<pattern>*/` (e.g., `gruvbox-material-dark-*` matches all gruvbox-material-dark variants)
3. **Default fallback**: `backgrounds/default/`

### Examples

- Theme `catppuccin-mocha` → `backgrounds/catppuccin-mocha/`
- Theme `gruvbox-material-dark-hard` → `backgrounds/gruvbox-material-dark-*/`
- Theme without specific folder → `backgrounds/default/`

## Configuration

Edit `config.toml` to configure applications:

```toml
[[kitty]]
input_path = 'templates/kitty-colors.conf'
output_path = '~/.config/kitty/colors.conf'
post_hook = 'pkill -SIGUSR1 kitty'
```

### Configuration Options

- `input_path`: Template file path (relative to script directory or absolute)
- `output_path`: Where to write the themed configuration
- `post_hook`: Command to execute after applying theme (e.g., reload application)

## Template Variables

### Base16 Colors

Available in all templates:

- `{{base00}}` - Default Background
- `{{base01}}` - Lighter Background
- `{{base02}}` - Selection Background
- `{{base03}}` - Comments, Invisibles
- `{{base04}}` - Dark Foreground
- `{{base05}}` - Default Foreground
- `{{base06}}` - Light Foreground
- `{{base07}}` - Light Background
- `{{base08}}` - Red
- `{{base09}}` - Orange
- `{{base0A}}` - Yellow
- `{{base0B}}` - Green
- `{{base0C}}` - Cyan
- `{{base0D}}` - Blue
- `{{base0E}}` - Magenta/Purple
- `{{base0F}}` - Brown

### Stripped Hex Values

For applications that need hex colors without the `#` prefix:

- `{{base00_stripped}}` through `{{base0F_stripped}}`

### Wallpaper Path

- `{{wallpaper}}` - Full path to the selected wallpaper

## Adding New Applications

1. Create a template in `templates/<app-name>.conf`
2. Use `{{baseXX}}` for base16 colors
3. Add configuration section to `config.toml`
4. Run `./theme.sh apply <theme-name>`

### Example Template

```conf
# Colors use base16 variables
background {{base00}}
foreground {{base05}}
color0     {{base00}}
color1     {{base08}}
color2     {{base0B}}
```

## Adding New Themes

1. Add a base16 YAML file to `color-defs/base16/`
2. (Optional) Create wallpaper directory in `backgrounds/`
3. Apply with `./theme.sh apply <new-theme-name>`

## Scripts

### theme.sh
Main script that orchestrates theme application. Handles:
- Theme listing and filtering
- Wallpaper selection
- Template processing for all applications
- Post-hook execution

### template-substituter.sh
Parses base16 YAML files and substitutes variables:
- `{{baseXX}}` → hex colors with `#` prefix
- `{{baseXX_stripped}}` → hex colors without `#`
- `{{wallpaper}}` → wallpaper path

### wallpaper-selector.sh
Selects appropriate wallpaper based on theme name and directory structure with wildcard support.

## Migration from Matugen

This theme switcher is designed as a base16 replacement for matugen (Material Design color generation). Key differences:

- Uses standard base16 color schemes instead of Material Design 3
- All templates converted to use base16 color variables
- Compatible with 200+ existing base16 themes
- Simpler, shell-based implementation

All templates have been converted from matugen's Material Design color names to base16 standard colors.
