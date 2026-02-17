#!/usr/bin/env python3
"""
change_icons.py - Changes Papirus folder icon colors
Reads the folder color from current-theme/folder-color.txt and applies it to Papirus icons
"""

import sys
import subprocess
from pathlib import Path


def change_icon_colors(hex_color: str, papirus_path: Path) -> bool:
    """
    Change Papirus folder icon colors using the papirus-folders script.
    
    Args:
        hex_color: Hex color code (with or without # prefix)
        papirus_path: Path to Papirus icons directory
        
    Returns:
        True if successful, False otherwise
    """
    # Remove # prefix if present
    hex_color = hex_color.lstrip('#')
    
    # Path to the papirus-folders script
    script_path = Path.home() / '.local/share/icons/papirus-folders.sh'
    
    if not script_path.exists():
        print(f"Error: papirus-folders.sh not found at {script_path}", file=sys.stderr)
        return False
    
    try:
        # Run papirus-folders.sh with -p (partial update), -C (custom color), and -t (theme path)
        result = subprocess.run(
            [
                str(script_path),
                '-p',
                '-C', hex_color,
                '-t', str(papirus_path)
            ],
            capture_output=True,
            text=True,
            check=True
        )
        return True
    except subprocess.CalledProcessError as e:
        print(f"Error changing icon colors: {e}", file=sys.stderr)
        if e.stderr:
            print(e.stderr, file=sys.stderr)
        return False


def main():
    """Main entry point for the script."""
    # Get script directory
    script_dir = Path(__file__).parent.resolve()
    
    # Read folder color from current theme
    color_file = script_dir / 'current-theme' / 'folder-color.txt'
    
    if not color_file.exists():
        print(f"Error: Folder color file not found: {color_file}", file=sys.stderr)
        sys.exit(1)
    
    # Read hex color
    hex_color = color_file.read_text().strip()
    
    if not hex_color:
        print("Error: Folder color file is empty", file=sys.stderr)
        sys.exit(1)
    
    # Path to Papirus icons
    papirus_path = Path.home() / '.local/share/icons/Papirus'
    
    if not papirus_path.exists():
        print(f"Error: Papirus icon theme not found at {papirus_path}", file=sys.stderr)
        sys.exit(1)
    
    # Change icon colors
    if change_icon_colors(hex_color, papirus_path):
        print(f"Successfully changed folder icon colors to {hex_color}")
        sys.exit(0)
    else:
        sys.exit(1)


if __name__ == '__main__':
    main()
