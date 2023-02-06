#!/bin/bash

# pipes ripgrep search to fzf selection and opens vim on selected file
set -e

# allows selecting files
INITIAL_QUERY=""
RG_PREFIX="rg --files-with-matches"
FZF_DEFAULT_COMMAND="$RG_PREFIX '$INITIAL_QUERY'"

fzf_output=$(fzf -m --bind "ctrl-a:select-all,ctrl-d:deselect-all,ctrl-t:toggle-all,change:reload:$RG_PREFIX {q} || true" \
      --print-query \
      --query "$INITIAL_QUERY" \
      --preview 'bat --style=numbers --color=always --line-range :500 {}')

if [[ -n "$fzf_output" ]]; then
  # Get the searched word from output
  final_query=$(echo $fzf_output | head -n1 | awk '{print $1;}')

  nvim -q <(rg --column $final_query) +cw
fi

if [[ $? -eq 0 ]]; then
     exit 0
fi
