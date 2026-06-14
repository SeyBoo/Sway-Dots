#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Kill the process owning the currently focused window.

# Get PID of the focused window via sway's tree
active_pid=$(swaymsg -t get_tree | jq '.. | select(.focused?==true) | .pid' 2>/dev/null | head -1)

if [[ -z "$active_pid" || ! "$active_pid" =~ ^[0-9]+$ ]]; then
  notify-send -u low -i "$HOME/.config/swaync/images/error.png" "Kill Active Window" "No active window PID found."
  exit 1
fi

# Close active window
kill "$active_pid"
