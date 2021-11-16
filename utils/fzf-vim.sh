#!/bin/bash

# pipes fzf selection to open vim on selected file
set -e

if [[ $# -eq 1 ]]; then
    selected=$1
else
    items=`find * -type f -not -path 'node_modules/*'`
    selected=`echo "$items" | fzf`
fi

nvim $selected
if [[ $? -eq 0 ]]; then
    exit 0
fi



