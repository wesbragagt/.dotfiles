#!/bin/bash

# pipes fzf selection to open vim on selected file
set -e

if [[ $# -eq 1 ]]; then
    selected=$1
else
    # uses fd which is a super fast replacement for find
    items=`fd --hidden --exclude .git`

    selected=`echo "$items" | fzf`
fi

nvim $selected
if [[ $? -eq 0 ]]; then
    exit 0
fi
