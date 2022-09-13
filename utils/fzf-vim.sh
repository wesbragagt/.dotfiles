#!/bin/bash

# pipes fzf selection to open vim on selected file
set -e

if [[ $# -eq 1 ]]; then
    selected=$1
else
    # uses fd which is a super fast replacement for find
    items=`rg --files --hidden --glob '!.git' --glob '!node_modules'`
    # with a preview window
    selected=`echo "$items" | fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'`
fi

nvim $selected
if [[ $? -eq 0 ]]; then
    exit 0
fi
