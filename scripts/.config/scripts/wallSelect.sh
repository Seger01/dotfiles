#!/bin/bash

set -e

WALLPAPER_DIR="$HOME/.config/wallpapers/Wallpapers_orig/"

menu() {
    find "${WALLPAPER_DIR}" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) | awk '{print "img:"$0}'
}
main() {
    choice=$(menu | wofi -c ~/.config/wofi/style-wallpaper-conf -s ~/.config/wofi/style-wallpaper.css --show dmenu --prompt "Select Wallpaper:" -n)
    selected_wallpaper=$(echo "$choice" | sed 's/^img://')
    swww img "$selected_wallpaper" --transition-type any --transition-fps 30 --transition-duration 4
    matugen image $selected_wallpaper -t scheme-tonal-spot  --contrast 0.07
}
main

