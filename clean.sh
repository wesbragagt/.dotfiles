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
  rofi
  ai
  )

for i in "${links[@]}"
do
   : 
    stow -D $i 
done
