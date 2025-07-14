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
  )

for i in "${links[@]}"
do
   : 
    stow $i --adopt
done
