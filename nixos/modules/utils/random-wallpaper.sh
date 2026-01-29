#!/usr/bin/env bash

export WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-wayland-1}

WALLPAPERS_DIR="$HOME/wallpapers"
WALLPAPER=$(find -L "$WALLPAPERS_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \) | shuf -n 1)
swww img "$WALLPAPER" --transition-type wipe --transition-duration 2
