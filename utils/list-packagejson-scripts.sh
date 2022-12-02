#! /bin/bash
set -e
# This script will put a list of scripts available into a fuzzy searcher like fzf and run the selection
# Pipes a list of scripts available in package.json to fzf for selection
if [ ! -e package.json ]; then
  echo "Not a package.json in this directory"
  exit -1
else
  run_command="npm run $(jq '.scripts | keys[]' package.json | sed 's/"//g' | fzf)"
  eval $run_command
fi

