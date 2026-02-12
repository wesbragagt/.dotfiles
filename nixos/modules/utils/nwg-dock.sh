#!/bin/bash
# nwg-dock-hyprland launch script
# -i 32: icon size 32px
# -w 5: window width (number of icons before wrapping)
# -mb 10: margin bottom 10px
# -x: exclusive zone (don't overlap with other windows)
# -lp start: launcher position (start means left-aligned)
# -c: launcher command (use rofi)
exec nwg-dock-hyprland \
  -i 32 \
  -w 5 \
  -mb 10 \
  -x \
  -lp start \
  -c "rofi -show drun -theme ~/.config/rofi/themes/raycast-nord.rasi"
