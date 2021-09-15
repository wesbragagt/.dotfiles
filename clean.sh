#!/bin/bash

links=(
  nvim
  tmux
  zsh
  )

for i in "${links[@]}"
do
   : 
    stow -D $i 
done
