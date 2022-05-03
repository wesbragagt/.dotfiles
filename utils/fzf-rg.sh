#!/bin/bash

# pipes ripgrep search to fzf selection and opens vim on selected file
set -e

items=`rg -l --hidden -g '!.git/' $@`
selected=`echo "$items" | fzf`

nvim $selected
if [[ $? -eq 0 ]]; then
    exit 0
fi
