#!/bin/bash

WALLPAPER="{{wallpaper}}"

cp /home/seger/.config/theme-switcher-sddm/sddm.conf /usr/share/sddm/themes/silent/configs/custom.conf

cp "$WALLPAPER" /usr/share/sddm/themes/silent/backgrounds/wallpaper

magick /usr/share/sddm/themes/silent/backgrounds/wallpaper /usr/share/sddm/themes/silent/backgrounds/wallpaper.png
