#!/bin/bash
STATE_FILE="/tmp/sway-gaming-mode"

if [ -f "$STATE_FILE" ]; then
    rm "$STATE_FILE"
    swaymsg gaps inner all set 5
    swaymsg gaps outer all set 5
    swaymsg bar mode dock
    notify-send "Gaming mode" "OFF"
else
    touch "$STATE_FILE"
    swaymsg gaps inner all set 0
    swaymsg gaps outer all set 0
    swaymsg bar mode invisible
    notify-send "Gaming mode" "ON"
fi
