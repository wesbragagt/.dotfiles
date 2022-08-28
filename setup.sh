#!/bin/bash

links=(
  nvim
  tmux
  zsh
  raycast
  alacritty
  fish
  )

for i in "${links[@]}"
do
   : 
    stow $i
done
