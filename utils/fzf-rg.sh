#!/bin/bash

# allows selecting files
INITIAL_QUERY=""
RG_PREFIX="rg --column --color=always --smart-case "
FZF_DEFAULT_COMMAND="$RG_PREFIX '$INITIAL_QUERY'"

fzf_output=$(fzf -m --bind "ctrl-a:select-all,ctrl-d:deselect-all,ctrl-t:toggle-all,change:reload:$RG_PREFIX {q} || true" \
      --query "$INITIAL_QUERY" \
      --ansi --disabled
    )

if [[ -n "$fzf_output" ]]; then
  nvim -q <(printf "$fzf_output") +cw
fi

if [[ $? -eq 0 ]]; then
     exit 0
fi
