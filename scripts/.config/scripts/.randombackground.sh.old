#!/bin/bash

# Use the first argument as the sleep duration, default to 5 if none provided
sleep_duration=${1:-5}
sleep "$sleep_duration"

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Set the directory path where your .png files are located
directory=$script_dir/Wallpapers

# Check if the directory exists
if [ -d "$directory" ]; then
    # Get a list of .JPG files in the directory
    image_files=("$directory"/*)
    
    # Check if there are any .JPG files
    if [ ${#image_files[@]} -gt 0 ]; then
        # Seed the random number generator with the current time
        RANDOM=$(date +%s)

        # Generate a random index to select a file
        random_index=$((RANDOM % ${#image_files[@]}))
        
        # Get the random .JPG file
        random_png="${image_files[$random_index]}"
        
        # Echo the random .JPG file name
        echo "Random .JPG file: $random_png"
                
        # Set the wallpaper using hyprctl commands
        hyprctl hyprpaper unload unused
        hyprctl hyprpaper preload "$random_png"
        hyprctl hyprpaper wallpaper ,"$random_png"
        hyprctl hyprpaper unload unused
        # hyprpanel sw "$random_png"
    else
        echo "No .JPG files found in the specified directory."
    fi
else
    echo "Directory not found: $directory"
fi
