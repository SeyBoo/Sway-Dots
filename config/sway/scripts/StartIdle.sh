#!/bin/bash
# Shared swayidle launcher (used by Startup_Apps.conf and IdleInhibit.sh)
pkill -x swayidle 2>/dev/null
exec swayidle -w \
  timeout 540 'notify-send -i "$HOME/.config/swaync/images/ja.png" " You are idle!"' \
  timeout 600 "$HOME/.config/sway/scripts/LockScreen.sh" \
  before-sleep 'loginctl lock-session'
