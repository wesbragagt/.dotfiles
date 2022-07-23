#!/bin/bash

# pipes ripgrep search to fzf selection and opens vim on selected file
set -e

items=`rg -l --hidden -g '!.git/' $@`
selected=`echo "$items" | fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'`

nvim $selected
if [[ $? -eq 0 ]]; then
    exit 0
fi
