#!/bin/bash

links=(
  nvim
  tmux
  zsh
  )

for i in "${links[@]}"
do
   : 
    stow $i
done
