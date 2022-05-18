#!/bin/bash

links=(
  nvim
  tmux
  zsh
  raycast
  alacritty
  local
  )

for i in "${links[@]}"
do
   : 
    stow $i
done
