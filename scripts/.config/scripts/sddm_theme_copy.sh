#!/bin/bash

WALLPAPER="/home/seger/.config/wallpapers/wallpapers/wallhaven-gwwzy3_2560x1440.png"

cp /home/seger/.config/matugen/sddm/matugen.conf /usr/share/sddm/themes/silent/configs/matugen.conf

cp $WALLPAPER /usr/share/sddm/themes/silent/backgrounds/matugen

magick /usr/share/sddm/themes/silent/backgrounds/matugen /usr/share/sddm/themes/silent/backgrounds/matugen.png
 
