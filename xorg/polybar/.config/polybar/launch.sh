#!/usr/bin/env bash

# Terminate already running bar instances
# If all your bars have ipc enabled, you can use 
# polybar-msg cmd quit
# Otherwise you can use the nuclear option:
killall -q polybar

# Launch bar1 and bar2
# echo "---" | tee -a /tmp/polybar1.log 
# polybar -r bar 2>&1 | tee -a /tmp/polybar1.log & disown
# # polybar bar2 2>&1 | tee -a /tmp/polybar2.log & disown
# for monitor in $(xrandr --query | grep " connected" | cut -d" " -f1); do
#     echo "Starting top bar on monitor '$monitor'"
#     MONITOR="$monitor" polybar top &
#     # echo "Starting bottom bar on monitor '$monitor'"
#     # MONITOR="$monitor" polybar bottom &
# done
# echo "Bars launched..."
if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$m polybar --reload bar &
  done
else
  polybar --reload bar &
fi

