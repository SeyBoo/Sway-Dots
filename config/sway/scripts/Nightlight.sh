#!/bin/bash
# Night light via wlsunset (replaces Hyprsunset.sh)
case "$1" in
  init)   pgrep -x wlsunset >/dev/null || wlsunset -t 4000 -T 6500 & ;;
  toggle) if pgrep -x wlsunset >/dev/null; then pkill -x wlsunset; notify-send "Night light off"; else wlsunset -t 4000 -T 6500 & notify-send "Night light on"; fi ;;
esac
