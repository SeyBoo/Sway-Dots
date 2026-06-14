#!/bin/bash
# Night light via wlsunset (replaces Hyprsunset.sh)
case "$1" in
  init)   pgrep -x wlsunset >/dev/null || wlsunset -t 4000 -T 6500 & ;;
  toggle)
    if pgrep -x wlsunset >/dev/null; then pkill -x wlsunset; notify-send "Night light" "Off";
    else wlsunset -t 4000 -T 6500 & notify-send "Night light" "On"; fi ;;
  status)
    if pgrep -x wlsunset >/dev/null; then
      echo '{"text":"󰌵","tooltip":"Night light on","class":"active"}'
    else
      echo '{"text":"󰌶","tooltip":"Night light off","class":"inactive"}'
    fi ;;
esac
