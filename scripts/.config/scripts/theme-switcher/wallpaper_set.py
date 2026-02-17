#!/usr/bin/env python3
"""
wallpaper_set.py - Sets wallpaper using hyprctl
Usage: wallpaper_set.py <wallpaper_path>
"""

import sys
import subprocess
from pathlib import Path


def set_wallpaper(wallpaper_path: Path) -> bool:
    """
    Set wallpaper using hyprctl hyprpaper command.
    
    Args:
        wallpaper_path: Path to the wallpaper file
        
    Returns:
        True if successful, False otherwise
    """
    try:
        # Run hyprctl command to set wallpaper
        result = subprocess.run(
            ['hyprctl', 'hyprpaper', 'wallpaper', f',{wallpaper_path}'],
            capture_output=True,
            text=True,
            check=True
        )
        return True
    except subprocess.CalledProcessError as e:
        print(f"Error setting wallpaper: {e}", file=sys.stderr)
        if e.stderr:
            print(e.stderr, file=sys.stderr)
        return False
    except FileNotFoundError:
        print("Error: hyprctl command not found", file=sys.stderr)
        return False


def main():
    """Main entry point for the script."""
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <wallpaper_path>", file=sys.stderr)
        sys.exit(1)
    
    wallpaper_path = Path(sys.argv[1])
    
    if not wallpaper_path.exists():
        print(f"Error: File '{wallpaper_path}' not found", file=sys.stderr)
        sys.exit(1)
    
    print(str(wallpaper_path))
    
    if set_wallpaper(wallpaper_path):
        sys.exit(0)
    else:
        sys.exit(1)


if __name__ == '__main__':
    main()
