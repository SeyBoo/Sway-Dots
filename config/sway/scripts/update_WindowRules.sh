#!/usr/bin/env bash
# /* ---- 💫 https://github.com/seyboo/Sway-Dots 💫 ---- */  ##
# Opens the Sway WindowRules config for editing.
# NOTE: The upstream Hyprland version auto-selected a windowrule syntax version
# based on Hyprland >= 0.53.  Sway uses a single stable 'for_window' syntax,
# so no version-switching is needed.  This script simply opens the file for
# manual editing.

CONFIGS_DIR="$HOME/.config/sway/configs"
TARGET_FILE="$CONFIGS_DIR/WindowRules.conf"
USER_RULES="$HOME/.config/sway/UserConfigs/WindowRules.conf"

# Prefer user overlay if it exists, otherwise open the system default
if [[ -f "$USER_RULES" ]]; then
    edit_file="$USER_RULES"
else
    edit_file="$TARGET_FILE"
fi

if [[ ! -f "$edit_file" ]]; then
    notify-send -i "$HOME/.config/swaync/images/error.png" "E-R-R-O-R" \
        "WindowRules config not found: $edit_file"
    exit 1
fi

# Open in user's preferred terminal + editor (fall back to xterm + nano)
term="${TERMINAL:-kitty}"
editor="${EDITOR:-nano}"

if command -v "$term" &>/dev/null; then
    "$term" -e "$editor" "$edit_file"
else
    xterm -e "$editor" "$edit_file"
fi
