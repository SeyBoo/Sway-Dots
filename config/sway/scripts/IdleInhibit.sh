#!/bin/bash
# Idle inhibitor toggle for waybar (replaces Hyprland Hypridle.sh).
# "Active" = swayidle running (screen will lock/idle). "Inhibited" = swayidle killed.
case "$1" in
  status)
    if pgrep -x swayidle >/dev/null; then
      echo '{"text":"󱫗","tooltip":"Idle active — click to inhibit","class":"active"}'
    else
      echo '{"text":"󱫦","tooltip":"Idle inhibited — click to re-enable","class":"inhibited"}'
    fi ;;
  toggle)
    if pgrep -x swayidle >/dev/null; then
      pkill -x swayidle; notify-send "Idle inhibitor" "Enabled (idle/lock disabled)"
    else
      setsid "$HOME/.config/sway/scripts/StartIdle.sh" >/dev/null 2>&1 &
      notify-send "Idle inhibitor" "Disabled (idle/lock active)"
    fi ;;
esac
