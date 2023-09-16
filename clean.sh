#!/bin/bash

links=(
  nvim
  tmux
  zsh
  raycast
  alacritty
  )

for i in "${links[@]}"
do
   : 
    stow -D $i 
done
