#!/bin/bash
cliphist list | rofi -dmenu -theme ~/.config/rofi/themes/rounded-nord-dark.rasi | cliphist decode | wl-copy