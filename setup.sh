#!/bin/bash

links=(
  nvim
  tmux
  zsh
  raycast
  alacritty
  karabiner 
  )

for i in "${links[@]}"
do
   : 
    stow $i
done
