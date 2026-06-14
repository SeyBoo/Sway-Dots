#!/usr/bin/env bash
# /* ---- 💫 https://github.com/seyboo/Sway-Dots 💫 ---- */  ##
# searchable enabled keybinds using rofi (supports bindsym descriptions)

# kill yad to not interfere with this binds
pkill yad || true

# check if rofi is already running
if pidof rofi > /dev/null; then
  pkill rofi
fi

# define the config files
keybinds_conf="$HOME/.config/sway/configs/Keybinds.conf"
user_keybinds_conf="$HOME/.config/sway/UserConfigs/UserKeybinds.conf"
laptop_conf="$HOME/.config/sway/UserConfigs/Laptops.conf"
rofi_theme="$HOME/.config/rofi/config-keybinds.rasi"
msg='NOTE: Clicking with Mouse or Pressing ENTER will have NO function'

# collect keybind lines from available files
files=("$keybinds_conf" "$user_keybinds_conf")
[[ -f "$laptop_conf" ]] && files+=("$laptop_conf")

# Parse binds using the python script for speed
# The last argument must be the user config for override logic to work correctly
display_keybinds=$("$HOME/.config/sway/scripts/keybinds_parser.py" "${files[@]}")

# Check for suggestions file created by python script
if [[ -f "/tmp/sway_keybind_suggestions_file" ]]; then
  suggestions_file=$(cat "/tmp/sway_keybind_suggestions_file")
  rm "/tmp/sway_keybind_suggestions_file"
  if [[ -n "$suggestions_file" && -f "$suggestions_file" ]]; then
     count=$(wc -l < "$suggestions_file")
     msg="$msg | Overrides missing unbind: $count (suggestions: $suggestions_file)"
  fi
fi

# use rofi to display the keybinds
printf '%s\n' "$display_keybinds" | rofi -dmenu -i -config "$rofi_theme" -mesg "$msg"
