#!/bin/bash

set -e
tmux_session_name=`tmux display-message -p "#S"`

tmux send-keys -t "$tmux_session_name.$1" "$2" ENTER
