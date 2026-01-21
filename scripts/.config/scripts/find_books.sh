#!/bin/bash
book_dir="$HOME/Documents/books"

# Find all book files, store in an array
mapfile -t files < <(fd . "$book_dir" -e pdf -e epub -e djvu)

# Prepare a list of basenames for wofi, keep a mapping to full paths
choices=""
for f in "${files[@]}"; do
    choices+=$(basename "$f")$'\n'
done

# User selects basename
selected=$(echo "$choices" | wofi --dmenu --prompt "Select book:")

# Find the full path for the selected file
for f in "${files[@]}"; do
    if [[ $(basename "$f") == "$selected" ]]; then
        zathura "$f"
        break
    fi
done
