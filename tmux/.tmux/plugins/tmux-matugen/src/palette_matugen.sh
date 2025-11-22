#!/bin/bash

##########################
# matugen palette
##########################

# Read colors from Matugen generated.conf at runtime
GENERATED_CONF="$HOME/.dotfiles/tmux/.tmux/generated.conf"

# Extract color values from generated.conf
extract_color() {
  local var_name="$1"
  grep "set -gq @${var_name}[[:space:]]" "$GENERATED_CONF" 2>/dev/null | awk '{print $NF}' | tr -d '"' | head -1
}

# shellcheck disable=2034
col_bg=$(extract_color "thm_bg")
col_bg0=$(grep "set -g status-bg" "$GENERATED_CONF" 2>/dev/null | awk '{print $NF}' | tr -d '"' | head -1)
col_bg1="#ffffff"
col_bg2=$(extract_color "thm_surface")
col_bg3=$(extract_color "thm_surface_variant")
col_bg4=$(extract_color "thm_surface_variant")
col_gray0=$(extract_color "thm_outline")
col_gray1=$(extract_color "thm_outline")
col_gray2=$(extract_color "thm_text_variant")
col_fg=$(extract_color "thm_fg")
col_fg4=$(extract_color "thm_fg")
col_fg3=$(extract_color "thm_fg")
col_fg2=$(extract_color "thm_fg")
col_fg1=$(extract_color "thm_text_variant")
col_fg0=$(extract_color "thm_fg")

# Using primary as accent color (like yellow in gruvbox)
col_primary=$(extract_color "thm_primary")
col_primary2=$(extract_color "thm_primary")

# Inverse primary for contrast
col_inverse=$(extract_color "thm_inverse_primary")

# Derived accent colors based on primary
col_red=$(extract_color "thm_primary")
col_red2=$(extract_color "thm_inverse_primary")
col_green=$(extract_color "thm_primary")
col_green2=$(extract_color "thm_inverse_primary")
col_yellow=$(extract_color "thm_primary")
col_yellow2=$(extract_color "thm_primary")
col_blue=$(extract_color "thm_primary")
col_blue2=$(extract_color "thm_inverse_primary")
col_purple=$(extract_color "thm_primary")
col_purple2=$(extract_color "thm_inverse_primary")
col_aqua=$(extract_color "thm_primary")
col_aqua2=$(extract_color "thm_inverse_primary")
col_orange=$(extract_color "thm_primary")
col_orange2=$(extract_color "thm_inverse_primary")
