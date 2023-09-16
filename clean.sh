#!/bin/bash

links=(
  nvim
  tmux
  zsh
  raycast
  )

for i in "${links[@]}"
do
   : 
    stow -D $i 
done
