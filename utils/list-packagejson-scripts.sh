#! /bin/bash
set -e
# Pipes a list of scripts available in package.json to fzf for selection
if [ ! -e package.json ]; then
  echo "Not a package.json in this directory"
  exit -1
else
  run_command="npm run $(jq '.scripts | keys[]' package.json | sed 's/"//g' | fzf)"
  eval $run_command
fi

