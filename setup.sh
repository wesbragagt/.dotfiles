#!/bin/bash

links=(
  nvim
  tmux
  zsh
  raycast
  alacritty
  karabiner 
  wezterm
  sesh
  starship
  ghostty
  foot
  opencode
  wallpapers
  fish
  # Launcher
  wofi
  rofi
  # Status bar
  waybar
  # Hyprland
  hypr
  # Screenshots
  swappy
  # Notification daemon
  mako

  # database management
  harlequin
)

for i in "${links[@]}"
do
   : 
    stow $i --adopt
done

# Stow keyd only on Linux systems
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    sudo stow --target=/ keyd
    sudo systemctl enable keyd --now
    sudo keyd reload
fi
