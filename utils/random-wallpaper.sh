#!/usr/bin/bash

WALLPAPERS_DIR="$HOME/wallpapers"
WALLPAPER=$(find "$WALLPAPERS_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \) | shuf -n 1)
swww img "$WALLPAPER" --transition-type wipe --transition-duration 2
