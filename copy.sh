#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  #
# Adapted for Sway-Dots — KooL-style Sway rice
# Original: https://github.com/JaKooLit/Hyprland-Dots (GPL-3.0)
# Translation/adaptation: community Sway port, not affiliated with JaKooLit.
#
# Purpose:
#   Copies/upgrades KooL's Sway dotfiles into ~/.config.
#   Handles interactive prompts, backups, per-app tweaks, and express mode.

clear

sway_cfg="$HOME/.config/sway"
wallpaper=$HOME/.config/sway/wallpaper_effects/.wallpaper_current
waybar_style="$HOME/.config/waybar/style/[Extra] Neon Circuit.css"
waybar_config="$HOME/.config/waybar/configs/[TOP] Default"
waybar_config_laptop="$HOME/.config/waybar/configs/[TOP] Default Laptop"

# Set some colors for output messages
OK="$(tput setaf 2)[OK]$(tput sgr0)"
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
NOTE="$(tput setaf 3)[NOTE]$(tput sgr0)"
INFO="$(tput setaf 4)[INFO]$(tput sgr0)"
WARN="$(tput setaf 1)[WARN]$(tput sgr0)"
CAT="$(tput setaf 6)[ACTION]$(tput sgr0)"
MAGENTA="$(tput setaf 5)"
ORANGE="$(tput setaf 214)"
WARNING="$(tput setaf 1)"
YELLOW="$(tput setaf 3)"
GREEN="$(tput setaf 2)"
BLUE="$(tput setaf 4)"
SKY_BLUE="$(tput setaf 6)"
RESET="$(tput sgr0)"

MIN_EXPRESS_VERSION="2.3.18"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ---------------------------------------------------------------------------
# Helper: backup directory timestamp
# ---------------------------------------------------------------------------
get_backup_dirname() {
  date +%Y%m%d_%H%M%S
}

# ---------------------------------------------------------------------------
# Helper: backup a config directory, then copy in new one
#   backup_and_copy <src_in_repo> <dest_in_home>
# ---------------------------------------------------------------------------
backup_and_copy() {
  local src="$1"
  local dest="$2"

  if [ -d "$dest" ]; then
    local bak="${dest}-backup-$(get_backup_dirname)"
    echo "${NOTE} - Backing up $dest → $bak" 2>&1 | tee -a "$LOG"
    mv "$dest" "$bak" 2>&1 | tee -a "$LOG"
  fi

  if cp -r "$src" "$dest" 2>&1 | tee -a "$LOG"; then
    echo "${OK} - Copied $src → $dest" 2>&1 | tee -a "$LOG"
  else
    echo "${ERROR} - Failed to copy $src → $dest" 2>&1 | tee -a "$LOG"
  fi
}

# ---------------------------------------------------------------------------
# Version helpers
# ---------------------------------------------------------------------------
version_gte() {
  [ "$1" = "$(printf '%s\n%s' "$1" "$2" | sort -V | tail -n1)" ]
}

get_installed_dotfiles_version() {
  local sway_dir="$HOME/.config/sway"
  if [ -d "$sway_dir" ]; then
    # Pick the highest semantic version among files named vX.Y.Z
    find "$sway_dir" -maxdepth 1 -type f -name 'v*.*.*' -printf '%f\n' 2>/dev/null \
      | sed 's/^v//' \
      | sort -V \
      | tail -n1
  fi
}

express_supported() {
  local current_version
  current_version=$(get_installed_dotfiles_version)
  if [ -z "$current_version" ]; then
    return 1
  fi
  version_gte "$current_version" "$MIN_EXPRESS_VERSION"
}

# ---------------------------------------------------------------------------
# Usage
# ---------------------------------------------------------------------------
print_usage() {
  cat <<'EOF'
Usage: copy.sh [--upgrade] [--express-upgrade] [--help]

Options:
  --upgrade           Run the script in upgrade mode (can still prompt for express).
  --express-upgrade   Upgrade with express behavior (no restore prompts, trims backups).
  -h, --help          Show this help message and exit.
EOF
}

UPGRADE_MODE=0
EXPRESS_MODE=0
RUN_MODE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
  --upgrade)
    UPGRADE_MODE=1
    RUN_MODE="upgrade"
    ;;
  --express-upgrade)
    UPGRADE_MODE=1
    EXPRESS_MODE=1
    RUN_MODE="express"
    ;;
  -h | --help)
    print_usage
    exit 0
    ;;
  *)
    echo "${ERROR} Unknown option: $1"
    print_usage
    exit 1
    ;;
  esac
  shift
done

INSTALLED_VERSION=$(get_installed_dotfiles_version)
EXPRESS_SUPPORTED=0
if express_supported; then
  EXPRESS_SUPPORTED=1
fi
if [ "$EXPRESS_MODE" -eq 1 ] && [ "$EXPRESS_SUPPORTED" -eq 0 ]; then
  echo "${WARN} Express upgrade requires installed dotfiles v${MIN_EXPRESS_VERSION} or newer. Falling back to standard upgrade."
  EXPRESS_MODE=0
  RUN_MODE="upgrade"
fi

if [ -z "$RUN_MODE" ]; then
  # Simple interactive menu
  while [ -z "$RUN_MODE" ]; do
    echo ""
    echo "${MAGENTA}KooL Sway-Dots Installer${RESET}"
    echo ""
    echo "  1) Install   (fresh install)"
    echo "  2) Upgrade   (preserve UserConfigs/UserScripts)"
    if [ "$EXPRESS_SUPPORTED" -eq 1 ]; then
      echo "  3) Express   (upgrade, skip restore prompts)"
    fi
    echo "  q) Quit"
    echo ""
    echo -n "${CAT} Enter choice: "
    read -r menu_choice
    case "$menu_choice" in
    1 | install)
      RUN_MODE="install"
      UPGRADE_MODE=0
      EXPRESS_MODE=0
      ;;
    2 | upgrade)
      RUN_MODE="upgrade"
      UPGRADE_MODE=1
      EXPRESS_MODE=0
      ;;
    3 | express)
      if [ "$EXPRESS_SUPPORTED" -eq 0 ]; then
        echo "${WARN} Express mode requires installed dotfiles v${MIN_EXPRESS_VERSION} or newer."
        continue
      fi
      RUN_MODE="express"
      UPGRADE_MODE=1
      EXPRESS_MODE=1
      ;;
    q | quit)
      echo "${NOTE} Exiting per user selection."
      exit 0
      ;;
    *)
      echo "${WARN} Invalid selection."
      ;;
    esac
  done
fi

# Check if running as root
if [[ $EUID -eq 0 ]]; then
  echo "${ERROR}  This script should ${WARNING}NOT${RESET} be executed as root!! Exiting......."
  printf "\n%.0s" {1..2}
  exit 1
fi

# Function to print colorful text
print_color() {
  printf "%b%b%b\n" "$1" "$2" "$RESET"
}

printf "\n%.0s" {1..1}
echo -e "\e[35m
    ╔═╗┬ ┬┌─┐┬ ┬  ╔╦╗┌─┐┌┬┐┌─┐
    ╚═╗│││├─┤└┬┘   ║║│ │ │ └─┐ 2025
    ╚═╝└┴┘┴ ┴ ┴   ═╩╝└─┘ ┴ └─┘
\e[0m"
printf "\n%.0s" {1..1}

echo "${WARNING}A T T E N T I O N !${RESET}"
echo "${MAGENTA}Kindly visit the Sway-Dots repository for changelogs${RESET}"
printf "\n%.0s" {1..1}

# Create directory for copy logs
if [ ! -d Copy-Logs ]; then
  mkdir Copy-Logs
fi

LOG="Copy-Logs/install-$(date +%d-%H%M%S)_dotfiles.log"

# Update home directories
xdg-user-dirs-update 2>&1 | tee -a "$LOG" || true
echo "${INFO} Selected workflow: ${RUN_MODE}" 2>&1 | tee -a "$LOG"
if [ "$UPGRADE_MODE" -eq 1 ]; then
  echo "${INFO} Upgrade mode enabled." 2>&1 | tee -a "$LOG"
fi
if [ "$EXPRESS_MODE" -eq 1 ]; then
  echo "${INFO} Express mode enabled. Optional restore prompts will be skipped." 2>&1 | tee -a "$LOG"
fi

printf "\n%.0s" {1..1}

# ---------------------------------------------------------------------------
# Resolution prompt
# ---------------------------------------------------------------------------
resolution=""
while true; do
  echo "${INFO} Select monitor resolution for scaling:"
  echo "  1) < 1440p   (lower DPI; smaller displays)"
  echo "  2) >= 1440p  (default; 1440p/2k/4k)"
  echo -n "${CAT} Enter the number of your choice (1 or 2): "
  read -r choice
  case "$choice" in
    1) resolution="< 1440p"; break ;;
    2) resolution=">= 1440p"; break ;;
    *) echo "${ERROR} Invalid choice. Please enter 1 or 2.";;
  esac
done
echo "${OK} You have chosen $resolution resolution." 2>&1 | tee -a "$LOG"

if [ "$resolution" = "< 1440p" ]; then
  # kitty font size
  sed -i 's/font_size 16.0/font_size 14.0/' config/kitty/kitty.conf

  # rofi fonts reduction
  rofi_config_file="config/rofi/0-shared-fonts.rasi"
  if [ -f "$rofi_config_file" ]; then
    sed -i '/element-text {/,/}/s/[[:space:]]*font: "JetBrainsMono Nerd Font SemiBold 13"/font: "JetBrainsMono Nerd Font SemiBold 11"/' "$rofi_config_file" 2>&1 | tee -a "$LOG"
    sed -i '/configuration {/,/}/s/[[:space:]]*font: "JetBrainsMono Nerd Font SemiBold 15"/font: "JetBrainsMono Nerd Font SemiBold 13"/' "$rofi_config_file" 2>&1 | tee -a "$LOG"
  fi
fi

printf "\n%.0s" {1..1}

# 12h clock prompt
while true; do
  echo -n "${CAT} Do you want to use 12-hour clock format? (y/N): "
  read -r clock_choice
  clock_choice=$(echo "$clock_choice" | tr '[:upper:]' '[:lower:]')
  case "$clock_choice" in
  y | yes)
    echo "${NOTE} 12h clock selected. You can adjust waybar config manually if needed." 2>&1 | tee -a "$LOG"
    break
    ;;
  n | no | "")
    echo "${NOTE} 24h clock retained." 2>&1 | tee -a "$LOG"
    break
    ;;
  *)
    echo "${WARN} Please answer 'y' or 'n'."
    ;;
  esac
done

printf "\n%.0s" {1..1}

set -e

# Check if the ~/.config/ directory exists
if [ ! -d "$HOME/.config" ]; then
  echo "${ERROR} - $HOME/.config directory does not exist. Creating it now."
  mkdir -p "$HOME/.config" && echo "Directory created successfully." || echo "Failed to create directory."
fi

# ---------------------------------------------------------------------------
# Create runtime wallust output dirs so first run does not fail
# ---------------------------------------------------------------------------
mkdir -p "$HOME/.config/sway/wallust" \
         "$HOME/.config/rofi/wallust" \
         "$HOME/.config/waybar/wallust"

# ---------------------------------------------------------------------------
# COPY PHASE 1: configs with per-directory prompts
# (fastfetch, kitty, rofi, swaync)
# ---------------------------------------------------------------------------
printf "${INFO} - Copying dotfiles ${SKY_BLUE}first${RESET} part\n"

for app in fastfetch kitty rofi swaync; do
  src="config/$app"
  dest="$HOME/.config/$app"
  if [ ! -d "$src" ]; then
    echo "${NOTE} - $src not found in repo, skipping." 2>&1 | tee -a "$LOG"
    continue
  fi
  if [ ! -d "$dest" ]; then
    echo "${INFO} - $app config not found in ~/.config, copying new config."
    cp -r "$src/" "$dest" 2>&1 | tee -a "$LOG"
    echo "${OK} - $app config copied." 2>&1 | tee -a "$LOG"
  else
    if [ "$EXPRESS_MODE" -eq 1 ]; then
      backup_and_copy "$src/" "$dest"
    else
      echo -n "${CAT} Do you want to overwrite your existing ${YELLOW}${app}${RESET} config? [y/N] "
      read -r answer_app
      case "$answer_app" in
      [Yy]*)
        backup_and_copy "$src/" "$dest"
        ;;
      *)
        echo "${NOTE} - Skipping overwrite of $app config." 2>&1 | tee -a "$LOG"
        ;;
      esac
    fi
  fi
done

printf "\n%.0s" {1..1}

# ---------------------------------------------------------------------------
# WAYBAR: special handling (backup configs/styles, then copy)
# ---------------------------------------------------------------------------
printf "${INFO} - Copying ${SKY_BLUE}waybar${RESET} config\n"

waybar_src="config/waybar"
waybar_dest="$HOME/.config/waybar"

if [ -d "$waybar_src" ]; then
  if [ ! -d "$waybar_dest" ]; then
    cp -r "$waybar_src/" "$waybar_dest" 2>&1 | tee -a "$LOG"
    echo "${OK} - waybar config copied." 2>&1 | tee -a "$LOG"
  else
    if [ "$EXPRESS_MODE" -eq 1 ]; then
      backup_and_copy "$waybar_src/" "$waybar_dest"
    else
      echo -n "${CAT} Do you want to overwrite your existing ${YELLOW}waybar${RESET} config? [y/N] "
      read -r answer_waybar
      case "$answer_waybar" in
      [Yy]*)
        backup_and_copy "$waybar_src/" "$waybar_dest"
        ;;
      *)
        echo "${NOTE} - Skipping overwrite of waybar config." 2>&1 | tee -a "$LOG"
        ;;
      esac
    fi
  fi
fi

printf "\n%.0s" {1..1}

# ---------------------------------------------------------------------------
# COPY PHASE 2: remaining configs (direct backup-and-copy, no per-dir prompt)
# List of WM-agnostic + sway-specific configs
# ---------------------------------------------------------------------------
printf "${INFO} - Copying dotfiles ${SKY_BLUE}second${RESET} part\n"

PHASE2_DIRS="btop cava environment.d ghostty Kvantum qt5ct qt6ct swappy sway swaylock wezterm wlogout wallust"

for app in $PHASE2_DIRS; do
  src="config/$app"
  dest="$HOME/.config/$app"
  if [ ! -d "$src" ]; then
    echo "${NOTE} - $src not found in repo, skipping." 2>&1 | tee -a "$LOG"
    continue
  fi
  backup_and_copy "$src/" "$dest"
done

printf "\n%.0s" {1..1}

# ---------------------------------------------------------------------------
# UserConfigs / UserScripts restore logic
# On upgrade: offer to restore user customisations from backup
# ---------------------------------------------------------------------------
restore_from_backup() {
  local label="$1"   # e.g. "UserConfigs"
  local dest="$2"    # e.g. "$HOME/.config/sway/UserConfigs"

  # Find the most recent backup directory (created just above in phase2)
  local bak
  bak=$(find "$(dirname "$dest")" -maxdepth 1 -type d -name "$(basename "$dest")-backup-*" 2>/dev/null \
        | sort | tail -n1)

  if [ -z "$bak" ]; then
    return
  fi

  if [ "$EXPRESS_MODE" -eq 1 ]; then
    echo "${NOTE} Express mode: skipping restore prompt for $label." 2>&1 | tee -a "$LOG"
    return
  fi

  echo -n "${CAT} Restore your previous ${YELLOW}${label}${RESET} from backup? [y/N] "
  read -r answer_restore
  case "$answer_restore" in
  [Yy]*)
    cp -r "$bak/." "$dest/" 2>&1 | tee -a "$LOG"
    echo "${OK} - ${label} restored from $bak" 2>&1 | tee -a "$LOG"
    ;;
  *)
    echo "${NOTE} - Keeping new $label (backup retained at $bak)." 2>&1 | tee -a "$LOG"
    ;;
  esac
}

if [ "$UPGRADE_MODE" -eq 1 ]; then
  restore_from_backup "UserConfigs" "$HOME/.config/sway/UserConfigs"
  restore_from_backup "UserScripts" "$HOME/.config/sway/UserScripts"
fi

printf "\n%.0s" {1..1}

# ---------------------------------------------------------------------------
# Rofi themes symlinks
# ---------------------------------------------------------------------------
rofi_DIR="$HOME/.local/share/rofi/themes"
if [ ! -d "$rofi_DIR" ]; then
  mkdir -p "$rofi_DIR"
fi
if [ -d "$HOME/.config/rofi/themes" ]; then
  if [ -z "$(ls -A "$HOME/.config/rofi/themes")" ]; then
    echo '/* Dummy Rofi theme */' >"$HOME/.config/rofi/themes/dummy.rasi"
  fi
  ln -snf "$HOME/.config/rofi/themes/"* "$HOME/.local/share/rofi/themes/"
  if [ -f "$HOME/.config/rofi/themes/dummy.rasi" ]; then
    rm "$HOME/.config/rofi/themes/dummy.rasi"
  fi
fi

printf "\n%.0s" {1..1}

# ---------------------------------------------------------------------------
# Wallpapers
# ---------------------------------------------------------------------------
PICTURES_DIR="$(xdg-user-dir PICTURES 2>/dev/null || echo "$HOME/Pictures")"
mkdir -p "$PICTURES_DIR/wallpapers"
if cp -r wallpapers "$PICTURES_DIR/"; then
  echo "${OK} Some ${MAGENTA}wallpapers${RESET} copied successfully!" | tee -a "$LOG"
else
  echo "${ERROR} Failed to copy some ${YELLOW}wallpapers${RESET}" | tee -a "$LOG"
fi

# ---------------------------------------------------------------------------
# Standalone config files
# ---------------------------------------------------------------------------
if [ -f "config/gamemode.ini" ]; then
  cp "config/gamemode.ini" "$HOME/.config/gamemode.ini" 2>&1 | tee -a "$LOG"
  echo "${OK} - gamemode.ini copied." 2>&1 | tee -a "$LOG"
fi

# ---------------------------------------------------------------------------
# Set scripts executable
# ---------------------------------------------------------------------------
chmod +x "$HOME/.config/sway/scripts/"* 2>&1 | tee -a "$LOG"
chmod +x "$HOME/.config/sway/UserScripts/"* 2>&1 | tee -a "$LOG"

# ---------------------------------------------------------------------------
# Waybar symlinks (desktop vs laptop)
# ---------------------------------------------------------------------------
chassis_type=""
if command -v hostnamectl >/dev/null 2>&1; then
  chassis_type=$(hostnamectl chassis 2>/dev/null || true)
fi
if [ "$chassis_type" = "desktop" ]; then
  config_file="$waybar_config"
  config_remove=" Laptop"
else
  config_file="$waybar_config_laptop"
  config_remove=""
fi

if [ ! -e "$HOME/.config/waybar/config" ] || [ -L "$HOME/.config/waybar/config" ]; then
  ln -sf "$config_file" "$HOME/.config/waybar/config" 2>&1 | tee -a "$LOG"
fi

# Remove inappropriate waybar configs
rm -rf "$HOME/.config/waybar/configs/[TOP] Default$config_remove" \
  "$HOME/.config/waybar/configs/[BOT] Default$config_remove" \
  "$HOME/.config/waybar/configs/[TOP] Default$config_remove (old v1)" \
  "$HOME/.config/waybar/configs/[TOP] Default$config_remove (old v2)" \
  "$HOME/.config/waybar/configs/[TOP] Default$config_remove (old v3)" \
  "$HOME/.config/waybar/configs/[TOP] Default$config_remove (old v4)" 2>&1 | tee -a "$LOG" || true

printf "\n%.0s" {1..1}

# ---------------------------------------------------------------------------
# Additional wallpapers (optional 1GB download)
# ---------------------------------------------------------------------------
echo "${MAGENTA}By default only a few wallpapers are copied${RESET}..."

if [ "$EXPRESS_MODE" -eq 1 ]; then
  echo "${NOTE} Express mode: skipping additional wallpaper download prompt." 2>&1 | tee -a "$LOG"
else
  while true; do
    echo "${NOTE} A number of these wallpapers are AI generated or enhanced. Select (N/n) if this is an issue for you. "
    echo -n "${CAT} Would you like to download additional wallpapers? ${WARN} This is 1GB in size (y/n): "
    read -r WALL

    case $WALL in
    [Yy])
      echo "${NOTE} Downloading additional wallpapers..."
      if git clone "https://github.com/JaKooLit/Wallpaper-Bank.git"; then
        echo "${OK} Wallpapers downloaded successfully." 2>&1 | tee -a "$LOG"

        if [ ! -d "$PICTURES_DIR/wallpapers" ]; then
          mkdir -p "$PICTURES_DIR/wallpapers"
          echo "${OK} Created wallpapers directory." 2>&1 | tee -a "$LOG"
        fi

        if cp -R Wallpaper-Bank/wallpapers/* "$PICTURES_DIR/wallpapers/" >>"$LOG" 2>&1; then
          echo "${OK} Wallpapers copied successfully." 2>&1 | tee -a "$LOG"
          rm -rf Wallpaper-Bank 2>&1
          break
        else
          echo "${ERROR} Copying wallpapers failed" 2>&1 | tee -a "$LOG"
        fi
      else
        echo "${ERROR} Downloading additional wallpapers failed" 2>&1 | tee -a "$LOG"
      fi
      ;;
    [Nn])
      echo "${NOTE} You chose not to download additional wallpapers." 2>&1 | tee -a "$LOG"
      break
      ;;
    *)
      echo "Please enter 'y' or 'n' to proceed."
      ;;
    esac
  done
fi

printf "\n%.0s" {1..1}

# ---------------------------------------------------------------------------
# Backup cleanup
# ---------------------------------------------------------------------------
if [ "$EXPRESS_MODE" -eq 1 ]; then
  # Auto-remove backups older than the current session (keep only newest)
  echo "${NOTE} Express mode: auto-cleaning old backups." 2>&1 | tee -a "$LOG"
  find "$HOME/.config" -maxdepth 1 -type d -name '*-backup-*' 2>/dev/null \
    | sort | head -n -1 \
    | while read -r bak_dir; do
        echo "${NOTE} Removing old backup: $bak_dir" 2>&1 | tee -a "$LOG"
        rm -rf "$bak_dir"
      done
else
  echo -n "${CAT} Do you want to remove all backup directories created today? [y/N] "
  read -r clean_choice
  case "$clean_choice" in
  [Yy]*)
    find "$HOME/.config" -maxdepth 1 -type d -name '*-backup-*' 2>/dev/null \
      | while read -r bak_dir; do
          echo "${NOTE} Removing backup: $bak_dir" 2>&1 | tee -a "$LOG"
          rm -rf "$bak_dir"
        done
    echo "${OK} Backups cleaned." 2>&1 | tee -a "$LOG"
    ;;
  *)
    echo "${NOTE} Backups retained in $HOME/.config." 2>&1 | tee -a "$LOG"
    ;;
  esac
fi

# ---------------------------------------------------------------------------
# Waybar style symlink
# ---------------------------------------------------------------------------
if [ ! -e "$HOME/.config/waybar/style.css" ] || [ -L "$HOME/.config/waybar/style.css" ]; then
  ln -sf "$waybar_style" "$HOME/.config/waybar/style.css" 2>&1 | tee -a "$LOG"
fi

printf "\n%.0s" {1..1}

# Initialize wallust to avoid config errors on first sway start
if [ -f "$wallpaper" ]; then
  wallust run -s "$wallpaper" 2>&1 | tee -a "$LOG"
else
  echo "${NOTE} No initial wallpaper found at $wallpaper — run 'SUPER+W' after login to set one." 2>&1 | tee -a "$LOG"
fi

printf "\n%.0s" {1..2}
printf "${OK} GREAT! KooL's Sway-Dots is now Loaded & Ready !!! "
printf "\n%.0s" {1..1}
printf "${INFO} However, it is ${MAGENTA}HIGHLY SUGGESTED${RESET} to logout and re-login or better reboot to avoid any issues"
printf "\n%.0s" {1..1}
printf "${SKY_BLUE}Thank you${RESET} for using ${MAGENTA}KooL's Sway Configuration${RESET}... ${YELLOW}ENJOY!!!${RESET}"
printf "\n%.0s" {1..3}
