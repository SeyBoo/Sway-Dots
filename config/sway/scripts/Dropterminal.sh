#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Dropdown terminal via sway scratchpad.
# Usage: ./Dropterminal.sh [terminal]   (default: kitty)
# kitty uses --class to set app_id; other terminals may differ.

term="${1:-kitty}"

if swaymsg -t get_tree | jq -e '.. | (.marks? // []) | index("dropterm")' >/dev/null 2>&1; then
  swaymsg '[con_mark="dropterm"] scratchpad show'
else
  $term --class dropterm &
  sleep 0.4
  swaymsg '[app_id="dropterm"] mark dropterm, move scratchpad, scratchpad show, resize set 60ppt 50ppt, move position center'
fi
