#!/bin/bash

set -e

WALLPAPER_DIR="$HOME/.config/wallpapers/wallpapers/"

menu() {
    find "${WALLPAPER_DIR}" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) | awk '{print "img:"$0}'
}
main() {
    choice=$(menu | wofi -c ~/.config/wofi/style-wallpaper-conf -s ~/.config/wofi/style-wallpaper.css --show dmenu --prompt "Select Wallpaper:" -n)
    selected_wallpaper=$(echo "$choice" | sed 's/^img://')
    # swww img "$selected_wallpaper" --transition-type any --transition-fps 30 --transition-duration 2
    # Set the wallpaper using hyprctl commands
    # hyprctl hyprpaper "$selected_wallpaper"
    hyprctl hyprpaper wallpaper ,"$selected_wallpaper", cover

    matugen image $selected_wallpaper -t scheme-fruit-salad --show-colors >> ~/.config/scripts/matugen_colors.txt
    # matugen image $selected_wallpaper -t scheme-tonal-spot --show-colors >> ~/.config/scripts/matugen_colors.txt
    # matugen image $selected_wallpaper -t scheme-vibrant --show-colors >> ~/.config/scripts/matugen_colors.txt
    # matugen image $selected_wallpaper -t scheme-content --show-colors >> ~/.config/scripts/matugen_colors.txt
    # matugen image $selected_wallpaper -t scheme-expressive --show-colors >> ~/.config/scripts/matugen_colors.txt
    # matugen image $selected_wallpaper -t scheme-monochrome --show-colors >> ~/.config/scripts/matugen_colors.txt

    ~/.local/share/icons/papirus-folders.sh < ~/.config/matugen/papirus-folders/folder-color.txt
}
main

