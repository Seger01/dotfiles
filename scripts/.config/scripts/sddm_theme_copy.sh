#!/bin/bash

WALLPAPER="/home/seger/.dotfiles/scripts/.config/scripts/theme-switcher/backgrounds/atelier-*-light/wallhaven-w5m6yr_2560x1440.png"

cp /home/seger/.config/theme-switcher-sddm/sddm.conf /usr/share/sddm/themes/silent/configs/custom.conf

cp "$WALLPAPER" /usr/share/sddm/themes/silent/backgrounds/wallpaper

magick /usr/share/sddm/themes/silent/backgrounds/wallpaper /usr/share/sddm/themes/silent/backgrounds/wallpaper.png
