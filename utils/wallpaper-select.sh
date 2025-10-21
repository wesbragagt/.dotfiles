#!/usr/bin/env bash
set -euo pipefail

# --- CONFIGURATION ---
WALLPAPER_DIR="$HOME/wallpapers"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/wallpaper_thumbs"
THUMB_SIZE="400x225"
THEME="$HOME/.config/rofi/nord.rasi"

# --- CHECK DEPENDENCIES ---
for cmd in rofi swww magick; do
    command -v "$cmd" >/dev/null || { echo "Error: '$cmd' not found in PATH"; exit 1; }
done

mkdir -p "$CACHE_DIR"

# --- ENSURE SWWW DAEMON IS RUNNING ---
pgrep swww >/dev/null 2>&1 || swww-daemon &

# --- GENERATE THUMBNAILS ---
generate_thumb() {
    local img="$1"
    local thumb="$CACHE_DIR/$(basename "$img")"

    if [[ ! -f "$thumb" ]]; then
        magick "$img" \
            -resize "${THUMB_SIZE}^" \
            -gravity center \
            -background "#181825" \
            -extent "$THUMB_SIZE" \
            -alpha off \                     # remove any transparency
            -flatten \                       # paint over dark background
            -colorspace sRGB \
            "$thumb"
    fi

    echo "$thumb"
}




# --- BUILD ROFI INPUT LIST ---
LIST_FILE=$(mktemp)
for img in "$WALLPAPER_DIR"/*.{jpg,jpeg,png,gif}; do
    [[ -e "$img" ]] || continue
    thumb=$(generate_thumb "$img")
    name=$(basename "${img%.*}")
    echo -en "$img\x00icon\x1f$thumb\x00info\x1f$name\n" >> "$LIST_FILE"
done

# --- LAUNCH ROFI ---
SELECTED=$(rofi -dmenu \
    -theme "$THEME" \
    -p "Select wallpaper:" \
    -show-icons \
    -theme-str 'listview { columns: 4; lines: 2; } window { width: 1200px; }' \
    -format "s" < "$LIST_FILE" 2>/dev/null)

[ -z "$SELECTED" ] && exit 0

# --- APPLY WALLPAPER ---
swww img "$SELECTED" --transition-type grow --transition-fps 60 --transition-duration 1.25

notify-send "Wallpaper changed" "$(basename "$SELECTED")"

