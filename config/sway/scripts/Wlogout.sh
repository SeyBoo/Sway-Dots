#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# wlogout (Power, Screen Lock, Suspend, etc) — Sway edition

# Set variables for parameters. First numbers correspond to Monitor Resolution
# i.e 2160 means 2160p
A_2160=600
B_2160=600
A_1600=400
B_1600=400
A_1440=400
B_1440=400
A_1080=200
B_1080=200
A_720=50
B_720=50

# Check if wlogout is already running
if pgrep -x "wlogout" > /dev/null; then
    pkill -x "wlogout"
    exit 0
fi

# Detect focused monitor resolution and scaling factor via swaymsg
resolution=$(swaymsg -t get_outputs | jq -r '.[] | select(.focused == true) | .current_mode.height / (if .scale then .scale else 1 end)' | awk -F'.' '{print $1}')
sway_scale=$(swaymsg -t get_outputs | jq -r '.[] | select(.focused == true) | if .scale then .scale else 1 end')

# Set parameters based on screen resolution and scaling factor
if ((resolution >= 2160)); then
    T_val=$(awk "BEGIN {printf \"%.0f\", $A_2160 * 2160 * $sway_scale / $resolution}")
    B_val=$(awk "BEGIN {printf \"%.0f\", $B_2160 * 2160 * $sway_scale / $resolution}")
    echo "Setting parameters for resolution >= 4k"
    wlogout --protocol layer-shell -b 6 -T $T_val -B $B_val &
elif ((resolution >= 1600 && resolution < 2160)); then
    T_val=$(awk "BEGIN {printf \"%.0f\", $A_1600 * 1600 * $sway_scale / $resolution}")
    B_val=$(awk "BEGIN {printf \"%.0f\", $B_1600 * 1600 * $sway_scale / $resolution}")
    echo "Setting parameters for resolution >= 2.5k and < 4k"
    wlogout --protocol layer-shell -b 6 -T $T_val -B $B_val &
elif ((resolution >= 1440 && resolution < 1600)); then
    T_val=$(awk "BEGIN {printf \"%.0f\", $A_1440 * 1440 * $sway_scale / $resolution}")
    B_val=$(awk "BEGIN {printf \"%.0f\", $B_1440 * 1440 * $sway_scale / $resolution}")
    echo "Setting parameters for resolution >= 2k and < 2.5k"
    wlogout --protocol layer-shell -b 6 -T $T_val -B $B_val &
elif ((resolution >= 1080 && resolution < 1440)); then
    T_val=$(awk "BEGIN {printf \"%.0f\", $A_1080 * 1080 * $sway_scale / $resolution}")
    B_val=$(awk "BEGIN {printf \"%.0f\", $B_1080 * 1080 * $sway_scale / $resolution}")
    echo "Setting parameters for resolution >= 1080p and < 2k"
    wlogout --protocol layer-shell -b 6 -T $T_val -B $B_val &
elif ((resolution >= 720 && resolution < 1080)); then
    T_val=$(awk "BEGIN {printf \"%.0f\", $A_720 * 720 * $sway_scale / $resolution}")
    B_val=$(awk "BEGIN {printf \"%.0f\", $B_720 * 720 * $sway_scale / $resolution}")
    echo "Setting parameters for resolution >= 720p and < 1080p"
    wlogout --protocol layer-shell -b 3 -T $T_val -B $B_val &
else
    echo "Setting default parameters"
    wlogout &
fi
