#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Cycle sway layout (replaces Hyprland master/dwindle switcher).
# Cycles the focused container through: split → tabbed → stacking.

notif="$HOME/.config/swaync/images/ja.png"

case "$1" in
  init) exit 0 ;;
  *)
    swaymsg layout toggle split tabbed stacking
    new_layout=$(swaymsg -t get_tree | jq -r '.. | select(.focused? == true) | .layout' 2>/dev/null | head -1)
    notify-send -e -u low -i "$notif" " Sway Layout: ${new_layout:-toggled}"
    ;;
esac
