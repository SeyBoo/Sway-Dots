#!/bin/bash
# Lock screen — swaylock (replaces hyprlock LockScreen.sh)
pidof swaylock || swaylock -C "$HOME/.config/swaylock/config"
