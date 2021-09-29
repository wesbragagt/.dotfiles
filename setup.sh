#!/bin/bash

links=(
  nvim
  tmux
  zsh
  yabai
  skhd
  )

for i in "${links[@]}"
do
   : 
    stow $i
done
