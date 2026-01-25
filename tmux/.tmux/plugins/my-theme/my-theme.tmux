#!/usr/bin/env bash

# Get color values from generated.conf
thm_fg=$(tmux show-option -gqv "@thm_fg")
thm_bg=$(tmux show-option -gqv "@thm_bg")
thm_surface=$(tmux show-option -gqv "@thm_surface")
thm_inverse_primary=$(tmux show-option -gqv "@thm_inverse_primary")

# Status bar
tmux set-option -gq status "on"
tmux set-option -gq status-style "bg=#{@thm_surface},fg=#{@thm_text_variant}"
tmux set-option -gq status-justify "left"
tmux set-option -gq status-left-length "80"
tmux set-option -gq status-right-length "80"

# Window status styling
tmux set-window-option -gq window-status-style "bg=#{@thm_primary},fg=#{@thm_surface}"
tmux set-window-option -gq window-status-activity-style "bg=#{@thm_surface},fg=#{@thm_fg}"
tmux set-window-option -gq window-status-current-style "bg=#{@thm_primary},fg=#{@thm_surface}"
tmux set-window-option -gq window-status-separator ""

# Pane borders
tmux set-option -gq pane-active-border-style "fg=#{@thm_fg}"
tmux set-option -gq pane-border-style "fg=#{@thm_primary}"

# Messages
tmux set-option -gq message-style "bg=#{@thm_surface},fg=#{@thm_text_variant}"
tmux set-option -gq message-command-style "bg=#{@thm_fg},fg=#{@thm_surface}"

# Pane numbers
tmux set-option -gq display-panes-active-colour "${thm_fg}"
tmux set-option -gq display-panes-colour "${thm_surface}"

# Bell
tmux set-window-option -gq window-status-bell-style "bg=${thm_inverse_primary},fg=${thm_bg}"

# Status bar format
tmux set-option -gq status-left "#[bg=#{@thm_primary},fg=#{@thm_surface}] #S #[bg=#{@thm_surface},fg=#{@thm_primary}]"

# Window formats
tmux set-window-option -gq window-status-current-format "#[bg=#{@thm_surface},fg=#{@thm_primary}] #[bg=#{@thm_primary},fg=#{@thm_surface}] #I >#[bg=#{@thm_primary},fg=#{@thm_surface},bold] #W#{?window_zoomed_flag,*Z,} #[bg=#{@thm_surface},fg=#{@thm_primary}]"

tmux set-window-option -gq window-status-format "#[bg=#{@thm_surface},fg=#{@thm_text_variant}]  #I >#[bg=#{@thm_surface},fg=#{@thm_text_variant}] #W  "
