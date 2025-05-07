#!/bin/bash

# pipes fzf selection to open vim on selected file
set -e

files_excluded=(
  node_modules
  .git
  .obsidian
  .terragrunt-cache
  .terraform
  .venv
  .direnv
  dist
)

EXCLUDES=`echo ${files_excluded[@]} | xargs -n1 | awk '{print "--exclude=" $1}' | xargs`
FZF_DEFAULT_COMMAND="fd --type=file --hidden --no-ignore --follow ${EXCLUDES}"
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
    # if a file name contains spaces it ends up opening multiple buffers for each word. We do not want that.
    # We can use the following to open the file in a single buffer
    # open in a single buffer
    nvim "$selected"
fi
