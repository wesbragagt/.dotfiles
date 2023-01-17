#!/bin/bash

# pipes fzf selection to open vim on selected file
set -e

if [[ $# -eq 1 ]]; then
    selected=$1
else
    # with a preview window
    if command -v bat &> /dev/null; then
      selected=`fzf -m --preview 'bat --style=numbers --color=always --line-range :500 {}'`
    else
      selected=`fzf`
    fi

fi

nvim $selected
if [[ $? -eq 0 ]]; then
    exit 0
fi
