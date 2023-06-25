#!/bin/bash

# allows selecting files
INITIAL_QUERY="${*:-}"
RG_PREFIX="rg --column --color=always --smart-case --hidden --no-require-git --fixed-strings --glob '!.git/*' --glob '!node_modules/*'"
FZF_DEFAULT_COMMAND="$RG_PREFIX '$INITIAL_QUERY'"
FZF_DEFAULT_OPTS="-m --bind ctrl-t:toggle-all --preview-window 'up,60%,border-bottom,+{2}+3/3,~3'"

fzf_output=$(fzf -m --bind "change:reload:$RG_PREFIX {q} || true" \
      --query "$INITIAL_QUERY" \
      --ansi --disabled
    )

if [[ -n "$fzf_output" ]]; then
  # vim needs to read an errofile in order to pipe results to quickfix list
  echo -n "$fzf_output" > /tmp/errorfile &&
  nvim -q /tmp/errorfile +cw
fi

if [[ $? -eq 0 ]]; then
     exit 0
fi
