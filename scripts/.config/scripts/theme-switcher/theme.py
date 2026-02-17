#!/usr/bin/env python3
"""
theme.py - Base16 Theme Switcher
Main script for managing and applying themes with wallpapers and templates
"""

import sys
import shutil
import subprocess
import tempfile
from pathlib import Path
from typing import List, Dict, Optional

# Use tomllib for Python 3.11+ or tomli for older versions
try:
    import tomllib
except ImportError:
    import tomli as tomllib

# Import our custom modules
from template_substituter import parse_color_yaml, substitute_template
from wallpaper_selector import find_wallpaper
from wallpaper_set import set_wallpaper


class ThemeManager:
    """Manager for theme operations."""

    def __init__(self):
        """Initialize the theme manager with paths."""
        self.script_dir = Path(__file__).parent.resolve()
        self.config_file = self.script_dir / 'config.toml'
        self.color_defs_dir = self.script_dir / 'color-defs' / 'base16'
        self.templates_dir = self.script_dir / 'templates'
        self.backgrounds_dir = self.script_dir / 'backgrounds'
        self.current_theme_dir = self.script_dir / 'current-theme'

    def list_themes(self) -> List[str]:
        """
        List all available themes.

        Returns:
            Sorted list of theme names
        """
        if not self.color_defs_dir.exists():
            print(f"Error: Color definitions directory not found: {
                  self.color_defs_dir}", file=sys.stderr)
            return []

        themes = []
        for yaml_file in self.color_defs_dir.glob('**/*.yaml'):
            theme_name = yaml_file.stem
            themes.append(theme_name)

        return sorted(themes)

    def has_wallpaper(self, theme_name: str) -> bool:
        """
        Check if a theme has a configured wallpaper.

        Args:
            theme_name: Name of the theme

        Returns:
            True if wallpaper is available, False otherwise
        """
        if not self.backgrounds_dir.exists():
            return False

        # Check for exact match
        exact_match = self.backgrounds_dir / theme_name
        if exact_match.exists() and exact_match.is_dir():
            return True

        # Check for wildcard match
        for subdir in self.backgrounds_dir.iterdir():
            if not subdir.is_dir():
                continue

            dirname = subdir.name
            if dirname.endswith('*'):
                pattern = dirname[:-1]
                if theme_name.startswith(pattern):
                    return True

        return False

    def list_configured(self) -> None:
        """List themes with configured wallpapers."""
        print("Themes with configured wallpapers:")

        themes = self.list_themes()
        for theme in themes:
            if self.has_wallpaper(theme):
                print(f"  {theme}")

        print("\nWallpaper directories:")
        if self.backgrounds_dir.exists():
            for subdir in sorted(self.backgrounds_dir.iterdir()):
                if subdir.is_dir():
                    print(f"  {subdir.name}")

    def update_configured_list(self) -> None:
        """Update the configured themes list file."""
        output_file = self.current_theme_dir / 'configured-themes.txt'

        # Create directory if it doesn't exist
        self.current_theme_dir.mkdir(parents=True, exist_ok=True)

        # Get configured themes
        configured_themes = [
            theme for theme in self.list_themes()
            if self.has_wallpaper(theme)
        ]

        # Write to file
        with open(output_file, 'w') as f:
            f.write('\n'.join(configured_themes) + '\n')

        print(f"Updated configured themes list: {output_file}")

    def expand_path(self, path: str) -> Path:
        """
        Expand tilde and environment variables in path.

        Args:
            path: Path string to expand

        Returns:
            Expanded Path object
        """
        return Path(path).expanduser()

    def parse_config(self) -> Dict[str, Dict[str, str]]:
        """
        Parse config.toml file.

        Returns:
            Dictionary of application configurations
        """
        if not self.config_file.exists():
            return {}

        with open(self.config_file, 'rb') as f:
            config = tomllib.load(f)

        # Convert array of tables to dict
        # TOML [[section]] syntax creates lists, we take the first element
        apps = {}
        for app_name, app_config in config.items():
            if isinstance(app_config, list) and len(app_config) > 0:
                # Array of tables - take first element
                apps[app_name] = app_config[0]
            elif isinstance(app_config, dict):
                # Regular table
                apps[app_name] = app_config

        return apps

    def apply_theme(self, theme_name: str, wallpaper_filename: Optional[str] = None) -> None:
        """
        Apply a theme.

        Args:
            theme_name: Name of the theme to apply
            wallpaper_filename: Optional specific wallpaper filename
        """
        color_file = self.color_defs_dir / f"{theme_name}.yaml"

        if not color_file.exists():
            print(f"Error: Theme not found: {theme_name}", file=sys.stderr)
            print("Available themes:", file=sys.stderr)
            for theme in self.list_themes():
                print(f"  {theme}", file=sys.stderr)
            sys.exit(1)

        print(f"Applying theme: {theme_name}")

        # Select wallpaper
        wallpaper = None
        if wallpaper_filename:
            # Find wallpaper file in theme directory
            if (self.backgrounds_dir / theme_name).exists():
                wallpaper = self.backgrounds_dir / theme_name / wallpaper_filename
            else:
                # Check for wildcard match
                for subdir in self.backgrounds_dir.iterdir():
                    if not subdir.is_dir():
                        continue

                    dirname = subdir.name
                    if dirname.endswith('*'):
                        pattern = dirname[:-1]
                        if theme_name.startswith(pattern):
                            wallpaper = subdir / wallpaper_filename
                            break

                # Fall back to default
                if wallpaper is None and (self.backgrounds_dir / 'default').exists():
                    wallpaper = self.backgrounds_dir / 'default' / wallpaper_filename

            if not wallpaper or not wallpaper.exists():
                print(f"Error: Wallpaper file not found: {
                      wallpaper_filename}", file=sys.stderr)
                sys.exit(1)
        else:
            # Select wallpaper automatically
            wallpaper = find_wallpaper(theme_name, self.backgrounds_dir)

        # Handle wallpaper
        if wallpaper:
            print(f"Selected wallpaper: {wallpaper}")

            # Store wallpaper path and theme name
            self.current_theme_dir.mkdir(parents=True, exist_ok=True)
            (self.current_theme_dir / 'current-wallpaper.txt').write_text(str(wallpaper))
            (self.current_theme_dir / 'current-theme.txt').write_text(theme_name)

            # Set wallpaper
            set_wallpaper(wallpaper)
        else:
            print("No wallpaper found for theme")

        # Parse color definitions
        colors, variant = parse_color_yaml(color_file)

        # Parse config
        apps = self.parse_config()

        # Process each application
        for app_name, app_config in apps.items():
            input_path_str = app_config.get('input_path')
            output_path_str = app_config.get('output_path')
            post_hook = app_config.get('post_hook')

            if not input_path_str:
                print(f"Warning: No input_path defined for {
                      app_name}, skipping", file=sys.stderr)
                continue

            # Expand and resolve paths
            input_path = self.expand_path(input_path_str)

            # If path is relative, prepend script directory
            if not input_path.is_absolute():
                input_path = self.script_dir / input_path

            if not input_path.exists():
                print(f"Warning: Template file not found: {
                      input_path}, skipping", file=sys.stderr)
                continue

            if not output_path_str:
                print(f"Warning: No output_path defined for {
                      app_name}, skipping", file=sys.stderr)
                continue

            output_path = self.expand_path(output_path_str)

            print(f"Processing {app_name}...")
            print(f"  Template: {input_path}")
            print(f"  Output: {output_path}")

            # Create output directory if needed
            output_path.parent.mkdir(parents=True, exist_ok=True)

            try:
                # Substitute template variables
                wallpaper_str = str(wallpaper) if wallpaper else None
                substitute_template(input_path, output_path,
                                    colors, variant, wallpaper_str)
                print("  ✓ Applied")

                # Execute post-hook if defined
                if post_hook:
                    print("  Running post-hook...")
                    try:
                        subprocess.run(
                            post_hook,
                            shell=True,
                            check=True,
                            stdout=subprocess.DEVNULL,
                            stderr=subprocess.DEVNULL
                        )
                    except subprocess.CalledProcessError:
                        print("  Warning: Post-hook failed", file=sys.stderr)
            except Exception as e:
                print(f"  ✗ Failed to process template: {e}", file=sys.stderr)

        print("Theme applied successfully!")


def main():
    """Main entry point."""
    manager = ThemeManager()

    if len(sys.argv) < 2:
        print(
            "Usage: theme.py {list|list-configured|update|apply <theme-name> [wallpaper-filename]}")
        print()
        print("Commands:")
        print("  list                            - List all available themes")
        print("  list-configured                 - List themes with configured wallpapers")
        print("  update                          - Update configured themes list file")
        print(
            "  apply <theme> [wallpaper]       - Apply a theme with optional wallpaper filename")
        sys.exit(1)

    command = sys.argv[1]

    if command == 'list':
        themes = manager.list_themes()
        print("Available themes:")
        for theme in themes:
            print(theme)

    elif command == 'list-configured':
        manager.list_configured()

    elif command == 'update':
        manager.update_configured_list()

    elif command == 'apply':
        if len(sys.argv) < 3:
            print(
                "Usage: theme.py apply <theme-name> [wallpaper-filename]", file=sys.stderr)
            sys.exit(1)

        theme_name = sys.argv[2]
        wallpaper_filename = sys.argv[3] if len(sys.argv) > 3 else None
        manager.apply_theme(theme_name, wallpaper_filename)

    else:
        print(f"Unknown command: {command}", file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()
