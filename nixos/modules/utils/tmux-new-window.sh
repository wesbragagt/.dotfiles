#!/bin/bash

# fzf a list of directories from ~/dev and open a new window from selection

work_dir=$1

if [[ -z $work_dir ]];then
  echo "please set a directory to target for this script to work"
  exit 1;
else
  directory=$(ls -d `printf "$work_dir/*"` | fzf --reverse --header tmux-create-window)
  if [[ -z $directory ]];then
    exit 0;
  else
    session_name=$(basename $directory)
    # does not matter if session is created just switch to it
    tmux neww -n $session_name -c $directory &> /dev/null
  fi
fi
