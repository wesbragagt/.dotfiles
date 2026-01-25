#!/usr/bin/env bash
set -euo pipefail

THEME_DIR="$HOME/.config/rofi/themes"
CONFIG_FILE="$HOME/.config/rofi/config.rasi"

mkdir -p "$THEME_DIR"

function list_themes() {
  echo "default"
  echo "dracula"
  echo "nord"
  echo "gruvbox-dark"
  echo "catppuccin"
}

function set_theme() {
  local theme="$1"
  local theme_file="$THEME_DIR/$theme.rasi"

  if [[ -f "$theme_file" ]]; then
    ln -sf "$theme_file" "$CONFIG_FILE"
    notify-send "Rofi Theme" "Switched to $theme theme"
  else
    notify-send --urgency=critical "Rofi Theme" "Theme $theme not found"
  fi
}

function theme_selector() {
  local theme=$(list_themes | rofi -dmenu -p "Select Theme" -matching fuzzy)
  if [[ -n "$theme" ]]; then
    set_theme "$theme"
  fi
}

case "${1:-}" in
  list) list_themes ;;
  set) set_theme "${2:-}" ;;
  *) theme_selector ;;
esac
