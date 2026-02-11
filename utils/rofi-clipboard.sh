#!/bin/bash
cliphist list | rofi -dmenu -theme ~/.config/rofi/raycast-nord.rasi | cliphist decode | wl-copy
