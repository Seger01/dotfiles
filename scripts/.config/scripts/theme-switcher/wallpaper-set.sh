#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <wallpaper_path>"
    exit 1
fi

if [ ! -f "$1" ]; then
    echo "Error: File '$1' not found"
    exit 1
fi

echo "$1"

hyprctl hyprpaper wallpaper ",$1"
