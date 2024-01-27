#!/bin/bash

links=(
  nvim
  tmux
  zsh
  raycast
  alacritty
  karabiner 
  wezterm
  )

for i in "${links[@]}"
do
   : 
    stow $i --adopt
done
