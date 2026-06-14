#!/bin/bash
# Start xdg-desktop-portal-wlr (replaces PortalHyprland.sh)
killall -e xdg-desktop-portal-wlr 2>/dev/null
killall -e xdg-desktop-portal 2>/dev/null
sleep 1
/usr/libexec/xdg-desktop-portal-wlr &
sleep 2
/usr/libexec/xdg-desktop-portal &
