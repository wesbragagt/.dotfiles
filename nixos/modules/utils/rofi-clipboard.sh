#!/bin/bash
cliphist list | rofi -dmenu -theme ~/.config/rofi/themes/raycast-nord.rasi | cliphist decode | wl-copy