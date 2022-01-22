#!/bin/bash

links=(
  nvim
  tmux
  zsh
  raycast
  iterm2
  )

for i in "${links[@]}"
do
   : 
    stow $i
done
