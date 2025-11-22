#!/usr/bin/env bash

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# hold the array of all command to configure tmux theme
declare -a TMUX_CMDS

# load libraries
source "$PLUGIN_DIR/src/helper_methods.sh"
source "$PLUGIN_DIR/src/tmux_utils.sh"

# Load theme (uses tmux interpolation for colors)
source "$PLUGIN_DIR/src/theme_matugen.sh"

TMUX_CMDS=() # clear

# Call theme function
theme_set_dark "#S" " %Y-%m-%d" " %H:%M" " #h" "false"

# execute commands with tmux as array of options
tmux "${TMUX_CMDS[@]}"
