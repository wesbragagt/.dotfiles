#!/bin/bash

# Get the name of the current branch
BRANCH=$(git symbolic-ref --short HEAD)

# Get the name of the branch that the current branch was created from
PARENT_BRANCH=$(git merge-base --fork-point master $BRANCH)

# If the parent branch is "master", create a pull request against "master"
if [[ "$PARENT_BRANCH" == "main" ]]; then
  TARGET_BRANCH="main"
else
  TARGET_BRANCH="$PARENT_BRANCH"
fi

# Push the current branch upstream
git push -u origin "$BRANCH"

# Get the URL of the remote repository
REMOTE_URL=$(git config --get remote.origin.url)

# Get the username and repository name from the remote URL
USERNAME=$(echo "$REMOTE_URL" | cut -d '/' -f4)
REPO=$(echo "$REMOTE_URL" | cut -d '/' -f5)

# Open the pull request page for the new branch in a web browser
open "https://github.com/$USERNAME/$REPO/compare/$TARGET_BRANCH...$BRANCH?expand=1"
