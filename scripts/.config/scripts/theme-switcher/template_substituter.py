#!/usr/bin/env python3
"""
template_substituter.py - Substitutes base16 color variables in templates
Usage: template_substituter.py <template-file> <output-file> <color-yaml-file> [wallpaper-path]
"""

import sys
import re
from pathlib import Path
from typing import Dict, Optional
import yaml


def parse_color_yaml(yaml_path: Path) -> tuple[Dict[str, str], str]:
    """
    Parse a YAML file and extract base16 color values and variant.
    
    Args:
        yaml_path: Path to the YAML color definition file
        
    Returns:
        Tuple of (colors dict, variant string)
        
    Raises:
        ValueError: If required colors are missing
    """
    with open(yaml_path, 'r') as f:
        data = yaml.safe_load(f)
    
    colors = {}
    variant = data.get('variant', 'dark')
    
    # Check if colors are nested under 'palette' key
    palette = data.get('palette', data)
    
    # Extract base16 colors
    required_colors = [
        'base00', 'base01', 'base02', 'base03',
        'base04', 'base05', 'base06', 'base07',
        'base08', 'base09', 'base0A', 'base0B',
        'base0C', 'base0D', 'base0E', 'base0F'
    ]
    
    for color_key in required_colors:
        if color_key in palette:
            # Remove # prefix if present and store without it
            value = palette[color_key]
            if isinstance(value, str):
                colors[color_key] = value.lstrip('#')
            else:
                colors[color_key] = value
        else:
            raise ValueError(f"Missing color definition for {color_key}")
    
    return colors, variant


def substitute_template(
    template_path: Path,
    output_path: Path,
    colors: Dict[str, str],
    variant: str,
    wallpaper_path: Optional[str] = None
) -> None:
    """
    Substitute color variables in a template file.
    
    Args:
        template_path: Path to the template file
        output_path: Path to write the output file
        colors: Dictionary of color values (without # prefix)
        variant: Theme variant (e.g., "dark", "light")
        wallpaper_path: Optional wallpaper path to substitute
    """
    with open(template_path, 'r') as f:
        content = f.read()
    
    # Substitute each color variable with # prefix
    for color_key, value in colors.items():
        # Ensure value has # prefix for {{baseXX}} substitutions
        prefixed_value = f"#{value}" if not value.startswith('#') else value
        content = content.replace(f"{{{{{color_key}}}}}", prefixed_value)
    
    # Substitute stripped hex values (without #)
    for color_key, value in colors.items():
        stripped_value = value.lstrip('#')
        content = content.replace(f"{{{{{color_key}_stripped}}}}", stripped_value)
    
    # Substitute wallpaper variable if provided
    if wallpaper_path:
        content = content.replace("{{wallpaper}}", wallpaper_path)
    
    # Substitute variant variable
    content = content.replace("{{variant}}", variant)
    
    # Write to output file
    with open(output_path, 'w') as f:
        f.write(content)


def main():
    """Main entry point for the script."""
    if len(sys.argv) < 4:
        print(f"Usage: {sys.argv[0]} <template-file> <output-file> <color-yaml-file> [wallpaper-path]", file=sys.stderr)
        sys.exit(1)
    
    template_file = Path(sys.argv[1])
    output_file = Path(sys.argv[2])
    color_yaml = Path(sys.argv[3])
    wallpaper_path = sys.argv[4] if len(sys.argv) > 4 else None
    
    # Validate inputs
    if not template_file.exists():
        print(f"Error: Template file not found: {template_file}", file=sys.stderr)
        sys.exit(1)
    
    if not color_yaml.exists():
        print(f"Error: Color YAML file not found: {color_yaml}", file=sys.stderr)
        sys.exit(1)
    
    try:
        # Parse color definitions
        colors, variant = parse_color_yaml(color_yaml)
        
        # Substitute template
        substitute_template(template_file, output_file, colors, variant, wallpaper_path)
        
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()
