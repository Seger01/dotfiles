#!/bin/bash

# Single wallpaper for all monitors:
WALLPAPER="{{image}}"

cp /home/seger/.config/matugen/sddm/matugen.conf /usr/share/sddm/themes/silent/configs/matugen.conf

cp $WALLPAPER /usr/share/sddm/themes/silent/backgrounds/matugen

magick /usr/share/sddm/themes/silent/backgrounds/matugen /usr/share/sddm/themes/silent/backgrounds/matugen.png
 
