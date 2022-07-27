#!/bin/bash

if [[ -z $WORK_DIR ]];then
  echo "please set a WORK_DIR for this script to work"
  exit 1;
fi

# lists directories within a work_dir and creates a new tmux session for that directory
directory=$(ls -d `printf "$WORK_DIR/*"` | fzf)
echo $WORK_DIR

if [[ -z $directory ]];then
  exit 0;
else
  session_name=$(basename $directory)
  # does not matter if session is created just switch to it
  tmux new-session -d -s $session_name -c $directory &> /dev/null
  tmux switch-client -t $session_name 
fi
