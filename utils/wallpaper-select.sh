#!/bin/bash
set -euo pipefail
shopt -s nullglob

# --- CONFIGURATION ---
WALLPAPER_DIR="$HOME/wallpapers"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/wallpaper_thumbs"
THUMB_SIZE="400x225"
THEME="$HOME/.config/rofi/nord.rasi"

# --- CHECK DEPENDENCIES ---
for cmd in rofi awww magick sha1sum; do
  command -v "$cmd" >/dev/null || { echo "Error: '$cmd' not found in PATH"; exit 1; }
done

mkdir -p "$CACHE_DIR"

# --- ENSURE AWWW DAEMON IS RUNNING ---
pgrep -x awww-daemon >/dev/null 2>&1 || awww-daemon >/dev/null 2>&1 &
for _ in {1..50}; do
  awww query >/dev/null 2>&1 && break
  sleep 0.1
done

thumb_path() {
  local img="$1"
  local hash
  hash=$(printf '%s' "$img" | sha1sum | cut -d ' ' -f 1)
  printf '%s/%s.png\n' "$CACHE_DIR" "$hash"
}

generate_thumb() {
  local img="$1"
  local thumb="$2"

  [[ -f "$thumb" ]] && return 0

  magick "$img" \
    -auto-orient \
    -thumbnail "${THUMB_SIZE}^" \
    -gravity center \
    -background "#181825" \
    -extent "$THUMB_SIZE" \
    -alpha off \
    -flatten \
    -colorspace sRGB \
    "PNG24:$thumb"
}

mapfile -d '' images < <(
  find -L "$WALLPAPER_DIR" -maxdepth 1 -type f \
    \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.gif' -o -iname '*.webp' \) \
    -print0 | sort -z
)

[[ ${#images[@]} -gt 0 ]] || { echo "No wallpapers found in $WALLPAPER_DIR" >&2; exit 1; }

# --- BUILD ROFI INPUT LIST ---
LIST_FILE=$(mktemp)
trap 'rm -f "$LIST_FILE"' EXIT

for img in "${images[@]}"; do
  thumb=$(thumb_path "$img")
  generate_thumb "$img" "$thumb"
  name=$(basename "${img%.*}")
  printf '%s\0icon\x1f%s\n' "$name" "$thumb" >> "$LIST_FILE"
done

# --- LAUNCH ROFI ---
SELECTED_INDEX=$(rofi -dmenu \
  -theme "$THEME" \
  -p "Select wallpaper:" \
  -show-icons \
  -theme-str 'listview { columns: 4; lines: 4; } window { width: 1200px; }' \
  -format "i" < "$LIST_FILE" 2>/dev/null || true)

[[ -z "$SELECTED_INDEX" || "$SELECTED_INDEX" == "-1" ]] && exit 0

SELECTED="${images[$SELECTED_INDEX]}"

# --- APPLY WALLPAPER ---
awww img "$SELECTED" --transition-type grow --transition-fps 60 --transition-duration 1.25

notify-send "Wallpaper changed" "$(basename "$SELECTED")"

