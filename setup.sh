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
    stow $i
done
