#!/bin/bash

# pipes fzf selection to open vim on selected file
set -e

FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude={.git,node_modules,.cache,.pycache}'
FZF_DEFAULT_OPTS="-m --bind ctrl-t:toggle-all --preview-window 'up,60%,border-bottom,+{2}+3/3,~3'"

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

if [[ -n "$selected" ]]; then
    nvim $selected
fi
