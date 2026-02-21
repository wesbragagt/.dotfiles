#!/usr/bin/env bash
ARM="$HOME/arm-compose/arm-media/completed/movies"
NAS="$HOME/mnt/nas-movies"
STATE="$HOME/arm-compose/.copied_movies"
LOG="$HOME/arm-compose/arm-copy.log"

[[ -f "$STATE" ]] || touch "$STATE"

for dir in "$ARM"/*/; do
  [[ -d "$dir" ]] || continue
  
  name=$(basename "$dir")
  grep -qx "$name" "$STATE" && continue
  
  nas_name=$(basename "$dir" | sed 's/ ([0-9]*)$//' | sed 's/--/_/g' | tr ' -' '_' | tr -d "'")
  
  echo "$(date): Copying $name → $nas_name" >> "$LOG"
  rsync -av --no-i-r --info=NAME "$dir" "$NAS/$nas_name/" >> "$LOG" 2>&1
  
  echo "$name" >> "$STATE"
done
