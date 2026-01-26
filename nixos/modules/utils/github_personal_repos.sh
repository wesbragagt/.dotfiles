#!/bin/bash

# List my repositories on github public and private
#

if [ -z "$GITHUB_PAT" ];then
  echo "export a GITHUB_PAT varible before calling this script"
  exit 1
fi


curl -su wesbragagt:$GITHUB_PAT https://api.github.com/users/wesbragagt/repos?per_page=200 | jq 'map(.ssh_url) | .[]' | tr -d '"' | fzf
