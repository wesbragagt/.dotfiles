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
  nix
  starship
  ghostty
  opencode
  wallpapers
  fish
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
