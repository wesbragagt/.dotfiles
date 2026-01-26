#!/bin/bash

# fzf a list of directories from ~/dev and open a new session from selection

work_dir=$1

if [[ -z $work_dir ]];then
  echo "please set a WORK_DIR for this script to work"
  exit 1;
else
  directory=$(ls -d `printf "$work_dir/*"` | fzf --reverse --header tmux-create-session)
  if [[ -z $directory ]];then
    exit 0;
  else
    session_name=$(basename $directory)
    # does not matter if session is created just switch to it
    tmux new-session -d -s $session_name -c $directory &> /dev/null
    tmux switch-client -t $session_name
  fi
fi
