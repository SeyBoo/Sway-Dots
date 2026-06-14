#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Game mode (sway): toggle idle inhibitor + notify.
# Sway has no animations/blur to disable; we inhibit idle instead.

notif="$HOME/.config/swaync/images/ja.png"

if [ -f /tmp/.sway_gamemode ]; then
  rm -f /tmp/.sway_gamemode
  pkill -f 'swayidle.*gamemode' 2>/dev/null || true
  notify-send -e -u low -i "$notif" " Gamemode:" " disabled"
else
  touch /tmp/.sway_gamemode
  notify-send -e -u normal -i "$notif" " Gamemode:" " enabled — idle inhibited"
fi
