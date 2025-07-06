#!/bin/bash

# Use fd instead of find for faster searches, ignoring common directories like .git
# The -t d and -t f flags ensure fd searches for both directories and files
# The --hidden flag allows fd to search hidden files/folders if needed
# The -E flag excludes specific patterns or directories
pathtocheck="$(fd --hidden -t d -t f . \
    --exclude .git \
    --exclude node_modules \
    --exclude .DS_Store \
    | fzf --preview 'bat {}')"

file_info=$(stat -c "%F" "$pathtocheck")

if [ "$file_info" = "directory" ]; then
    cd "$pathtocheck"
elif [ "$file_info" = "regular file" ]; then
    file_directory=$(dirname "$pathtocheck")
    cd "$file_directory"
    # Open file in your chosen editor relative to the new directory
    "$EDITOR" "$(basename "$pathtocheck")"
else
    echo "Something went wrong"
fi
