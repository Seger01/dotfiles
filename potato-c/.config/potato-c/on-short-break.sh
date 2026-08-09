#!/usr/bin/sh
# pause any music if playing 
playerctl pause

# play notification sound
mpv ~/.config/potato-c/endnotify.mp3 &
