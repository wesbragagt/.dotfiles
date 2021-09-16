#!/usr/bin/env bash

if [[ $# -eq 1 ]]; then
    selected=$1
else
    items=`find ~/dev -maxdepth 1 -mindepth 1 -type d`
    selected=`echo "$items" | fzf`
fi

tmux_session_name=`basename $selected | tr . _`

tmux switch-client -t $tmux_session_name
if [[ $? -eq 0 ]]; then
    exit 0
fi

tmux new-session -c $selected -d -s $tmux_session_name && tmux switch-client -t $tmux_session_name || tmux new -c $selected -A -s $tmux_session_name
