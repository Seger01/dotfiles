#!/usr/bin/env python3
"""
wallpaper_selector.py - Selects wallpaper based on theme name and directory structure
Usage: wallpaper_selector.py <theme-name> <backgrounds-dir>
"""

import sys
import random
from pathlib import Path
from typing import Optional, List


def get_wallpapers(directory: Path) -> List[Path]:
    """
    Get all image files from a directory.
    
    Args:
        directory: Path to search for wallpapers
        
    Returns:
        List of wallpaper file paths
    """
    if not directory.exists() or not directory.is_dir():
        return []
    
    # Supported image extensions
    extensions = {'.jpg', '.jpeg', '.png', '.webp'}
    
    wallpapers = []
    for file in directory.iterdir():
        if file.is_file() and file.suffix.lower() in extensions:
            wallpapers.append(file)
    
    return wallpapers


def select_random_wallpaper(directory: Path) -> Optional[Path]:
    """
    Select a random wallpaper from a directory.
    
    Args:
        directory: Directory containing wallpapers
        
    Returns:
        Path to a random wallpaper, or None if no wallpapers found
    """
    wallpapers = get_wallpapers(directory)
    
    if not wallpapers:
        return None
    
    return random.choice(wallpapers)


def find_wallpaper(theme_name: str, backgrounds_dir: Path) -> Optional[Path]:
    """
    Find a wallpaper for the given theme using a priority-based search.
    
    Priority:
    1. Exact theme name match
    2. Wildcard directory match (e.g., "gruvbox-*" matches "gruvbox-dark-hard")
    3. Default directory
    
    Args:
        theme_name: Name of the theme
        backgrounds_dir: Root directory containing wallpaper subdirectories
        
    Returns:
        Path to selected wallpaper, or None if no wallpaper found
    """
    if not backgrounds_dir.exists():
        return None
    
    # 1. Check for exact theme name match
    exact_match = backgrounds_dir / theme_name
    if exact_match.exists() and exact_match.is_dir():
        wallpaper = select_random_wallpaper(exact_match)
        if wallpaper:
            return wallpaper
    
    # 2. Check for wildcard matches
    for subdir in backgrounds_dir.iterdir():
        if not subdir.is_dir():
            continue
        
        dirname = subdir.name
        # If directory ends with *, treat it as a wildcard pattern
        if dirname.endswith('*'):
            pattern = dirname[:-1]  # Remove trailing *
            if theme_name.startswith(pattern):
                wallpaper = select_random_wallpaper(subdir)
                if wallpaper:
                    return wallpaper
    
    # 3. Fall back to default directory
    default_dir = backgrounds_dir / 'default'
    if default_dir.exists() and default_dir.is_dir():
        wallpaper = select_random_wallpaper(default_dir)
        if wallpaper:
            return wallpaper
    
    return None


def main():
    """Main entry point for the script."""
    if len(sys.argv) < 3:
        print(f"Usage: {sys.argv[0]} <theme-name> <backgrounds-dir>", file=sys.stderr)
        sys.exit(1)
    
    theme_name = sys.argv[1]
    backgrounds_dir = Path(sys.argv[2])
    
    wallpaper = find_wallpaper(theme_name, backgrounds_dir)
    
    if wallpaper:
        print(str(wallpaper))
        sys.exit(0)
    else:
        sys.exit(1)


if __name__ == '__main__':
    main()
