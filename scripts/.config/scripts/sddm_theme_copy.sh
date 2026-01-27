#!/bin/bash

WALLPAPER="/home/seger/.config/scripts/theme-switcher/backgrounds/black-metal-burzum/a_black_and_white_image_of_a_group_of_people.png"

cp /home/seger/.config/theme-switcher-sddm/sddm.conf /usr/share/sddm/themes/silent/configs/custom.conf

cp "$WALLPAPER" /usr/share/sddm/themes/silent/backgrounds/wallpaper

magick /usr/share/sddm/themes/silent/backgrounds/wallpaper /usr/share/sddm/themes/silent/backgrounds/wallpaper.png
