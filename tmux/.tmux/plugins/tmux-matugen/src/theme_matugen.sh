#!/bin/bash

# shellcheck disable=SC2154
theme_set_dark() {
  local _left_status_a _right_status_x _right_status_y _right_status_z _statusbar_alpha
  _left_status_a=$1
  _right_status_x=$2
  _right_status_y=$3
  _right_status_z=$4
  _statusbar_alpha=$5

  # Get actual color values from tmux options (for options that don't support interpolation)
  local thm_fg=$(tmux show-option -gqv "@thm_fg")
  local thm_bg=$(tmux show-option -gqv "@thm_bg")
  local thm_surface=$(tmux show-option -gqv "@thm_surface")
  local thm_inverse_primary=$(tmux show-option -gqv "@thm_inverse_primary")

  tmux_append_seto "status" "on"

  # default statusbar bg color
  local _statusbar_bg="#{@thm_surface}"
  if [[ "$_statusbar_alpha" == "true" ]]; then _statusbar_bg="default"; fi
  tmux_append_seto "status-style" "bg=${_statusbar_bg},fg=#{@thm_text_variant}"

  # default window title colors
  local _window_title_bg="#{@thm_primary}"
  if [[ "$_statusbar_alpha" == "true" ]]; then _window_title_bg="default"; fi
  tmux_append_setwo "window-status-style" "bg=${_window_title_bg},fg=#{@thm_surface}"

  # default window with an activity alert
  tmux_append_setwo "window-status-activity-style" "bg=#{@thm_surface},fg=#{@thm_fg}"

  # active window title colors
  local _active_window_title_bg="#{@thm_primary}"
  if [[ "$_statusbar_alpha" == "true" ]]; then _active_window_title_bg="default"; fi
  tmux_append_setwo "window-status-current-style" "bg=${_active_window_title_bg},fg=#{@thm_surface}"

  # pane border
  tmux_append_seto "pane-active-border-style" "fg=#{@thm_fg}"
  tmux_append_seto "pane-border-style" "fg=#{@thm_primary}"

  # message infos
  tmux_append_seto "message-style" "bg=#{@thm_surface},fg=#{@thm_text_variant}"

  # writing commands inactive
  tmux_append_seto "message-command-style" "bg=#{@thm_fg},fg=#{@thm_surface}"

  # pane number display - these don't support interpolation, use actual values
  tmux_append_seto "display-panes-active-colour" "${thm_fg}"
  tmux_append_seto "display-panes-colour" "${thm_surface}"

  # bell
  tmux_append_setwo "window-status-bell-style" "bg=${thm_inverse_primary},fg=${thm_bg}"

  ## Theme settings
  tmux_append_seto "status-justify" "left"
  tmux_append_seto "status-left-style" none
  tmux_append_seto "status-left-length" "80"
  tmux_append_seto "status-right-style" none
  tmux_append_seto "status-right-length" "80"
  tmux_append_setwo "window-status-separator" ""

  tmux_append_seto "status-left" "#[bg=#{@thm_primary},fg=#{@thm_surface}] ${_left_status_a} #[bg=#{@thm_surface},fg=#{@thm_primary},nobold,noitalics,nounderscore]"

  # # right status
  # local _status_right_bg="#{@thm_surface}"
  # if [[ "$_statusbar_alpha" == "true" ]]; then _status_right_bg="default"; fi
  # tmux_append_seto "status-right" "#[bg=${_status_right_bg},fg=#{@thm_fg},nobold,noitalics,nounderscore]#[bg=#{@thm_fg},fg=#{@thm_surface}] ${_right_status_z}"

  # current window
  local _current_window_status_format_bg="#{@thm_surface}"
  if [[ "$_statusbar_alpha" == "true" ]]; then _current_window_status_format_bg="default"; fi
  tmux_append_setwo "window-status-current-format" "#[bg=#{@thm_surface},fg=#{@thm_primary},nobold,noitalics,nounderscore] #[bg=#{@thm_primary},fg=#{@thm_surface}] #I >#[bg=#{@thm_primary},fg=#{@thm_surface},bold] #W#{?window_zoomed_flag,*Z,} #{?window_end_flag,#[bg=${_current_window_status_format_bg}],#[bg=#{@thm_surface}]}#[fg=#{@thm_primary},nobold,noitalics,nounderscore]"

  # default window
  local _default_window_status_format_bg="#{@thm_surface}"
  if [[ "$_statusbar_alpha" == "true" ]]; then _default_window_status_format_bg="default"; fi
  tmux_append_setwo "window-status-format" "#[bg=#{@thm_surface},fg=#{@thm_text_variant}]  #I >#[bg=#{@thm_surface},fg=#{@thm_text_variant}] #W  #{?window_end_flag,#[bg=${_default_window_status_format_bg}],#[bg=${_default_window_status_format_bg}]}"
}
