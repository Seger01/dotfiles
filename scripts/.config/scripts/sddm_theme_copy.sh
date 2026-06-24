#!/bin/bash

WALLPAPER="/home/seger/.dotfiles/scripts/.config/scripts/theme-switcher/backgrounds/e-ink/a_road_going_through_a_desert.jpeg"

cp /home/seger/.config/theme-switcher-sddm/sddm.conf /usr/share/sddm/themes/silent/configs/custom.conf

cp "$WALLPAPER" /usr/share/sddm/themes/silent/backgrounds/wallpaper

magick /usr/share/sddm/themes/silent/backgrounds/wallpaper /usr/share/sddm/themes/silent/backgrounds/wallpaper.png
