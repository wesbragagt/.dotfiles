#!/bin/bash
set -euo pipefail

# Set a random wallpaper with awww.
WALLPAPER_DIR="$HOME/wallpapers"

if ! command -v awww >/dev/null 2>&1; then
  echo "awww is not installed" >&2
  exit 1
fi

pgrep -x awww-daemon >/dev/null 2>&1 || awww-daemon >/dev/null 2>&1 &

for _ in {1..50}; do
  if awww query >/dev/null 2>&1; then
    break
  fi
  sleep 0.1
done

WALLPAPER=$(find -L "$WALLPAPER_DIR" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.gif' \) | shuf -n 1)

if [[ -z "${WALLPAPER:-}" ]]; then
  echo "No wallpapers found in $WALLPAPER_DIR" >&2
  exit 1
fi

awww img "$WALLPAPER" --transition-type wipe --transition-duration 2
