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
  )

for i in "${links[@]}"
do
   : 
    stow $i --adopt
done
