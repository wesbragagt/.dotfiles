#!/bin/bash

# This script allows fuzzy searching through all branches available in a project
# Selecting a branch
# Checking out that branch and tracking it if it doesn't already exists

branch=$(git branch -a | fzf | sed 's/remotes\/origin\///')

# check if branch exists locally first
if [ `git rev-parse --verify $branch 2>/dev/null` ]; then
  git switch $branch
else
  # echoing this branch adds a space after origin/
  remote_branch=$(echo "origin/$branch" | tr -d ' ')
  git checkout --track $remote_branch
fi
