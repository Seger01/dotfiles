#!/usr/bin/env bash

hex=$(<~/.config/scripts/theme-switcher/current-theme/folder-color.txt)

~/.local/share/icons/papirus-folders.sh -p -C $hex -t ~/.local/share/icons/Papirus
