#!/bin/bash

links=(
  nvim
  tmux
  zsh
  raycast
  iterm2
  alacritty
  )

for i in "${links[@]}"
do
   : 
    stow $i
done
