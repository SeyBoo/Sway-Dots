#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# This is for changing kb_layouts under Sway.
# Layouts are configured in the sway config (xkb_layout).

notif_icon="$HOME/.config/swaync/images/ja.png"

# Refined ignore list with patterns or specific device names
ignore_patterns=(
  "--(avrcp)"
  "Bluetooth Speaker"
  "Other Device
  Name"
)

# Function to check if a device matches any ignore pattern
is_ignored() {
  local device_name=$1
  for pattern in "${ignore_patterns[@]}"; do
    if [[ "$device_name" == *"$pattern"* ]]; then
      return 0 # Device matches ignore pattern
    fi
  done
  return 1 # Device does not match any ignore pattern
}

# Function to get current layout info from the first non-ignored keyboard
# Sets: layout_mapping[], variant_mapping[], layout_index
get_current_layout_info() {
  local found_kb=false

  while IFS= read -r name; do
    if ! is_ignored "$name"; then
      found_kb=true

      local layout_mapping_str
      layout_mapping_str=$(swaymsg -t get_inputs |
        jq -r --arg name "$name" '.[] | select(.identifier==$name) | .xkb_layout_names | join(",")')
      IFS="," read -r -a layout_mapping <<<"$layout_mapping_str"

      # Build a variant array of the same length (sway does not expose per-layout variants)
      variant_mapping=()
      for _ in "${layout_mapping[@]}"; do
        variant_mapping+=("")
      done

      layout_index=$(swaymsg -t get_inputs |
        jq -r --arg name "$name" '.[] | select(.identifier==$name) | .xkb_active_layout_index')
      break
    fi
  done < <(swaymsg -t get_inputs | jq -r '.[] | select(.type=="keyboard") | .identifier')

  $found_kb && return 0
  return 1
}

# Function to switch keyboard layout (cycle to next)
change_layout() {
  swaymsg input type:keyboard xkb_switch_layout next
}

# Stores values in layout_mapping, variant_mapping and layout_index
if ! get_current_layout_info; then
  echo "Could not get current layout information." >&2
  echo "There might not be any keyboards available, \
    or some were unnecessarily set as ignored." >&2
  notify-send -u low -t 2000 'kb_layout' " Error:" " Layout change failed"
  echo "Exiting $0 $*" >&2
  exit 1
fi

current_layout=${layout_mapping[$layout_index]}
current_variant=${variant_mapping[$layout_index]}

if [[ "$1" == "status" ]]; then
  echo "$current_layout${current_variant:+($current_variant)}"
elif [[ "$1" == "switch" ]]; then
  echo "Current layout: $current_layout($current_variant)"

  layout_count=${#layout_mapping[@]}
  echo "Number of layouts: $layout_count"

  next_index=$(( (layout_index + 1) % layout_count ))
  new_layout="${layout_mapping[$next_index]}"
  new_variant="${variant_mapping[$next_index]}"
  echo "Next layout: $new_layout"

  # Execute layout change and notify
  if ! change_layout; then
    notify-send -u low -t 2000 'kb_layout' " Error:" " Layout change failed"
    echo "Layout change failed." >&2
    exit 1
  else
    notify-send -u low -i "$notif_icon" " kb_layout: $new_layout${new_variant:+($new_variant)}"
    echo "Layout change notification sent."
  fi
else
  echo "Usage: $0 {status|switch}"
fi
