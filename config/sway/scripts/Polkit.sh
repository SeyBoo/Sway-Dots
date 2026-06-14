#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Polkit authentication agent (lxqt-policykit, replaces hyprpolkitagent)

pgrep -x lxqt-policykit-agent >/dev/null || /usr/bin/lxqt-policykit-agent &
