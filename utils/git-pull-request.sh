#!/bin/bash

# Get the name of the current branch
BRANCH=$(git symbolic-ref --short HEAD)

# Get the default branch (usually main or master)
DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')

# Push the current branch upstream
git push -u origin HEAD

# Get the URL of the remote repository
REMOTE_URL=$(git config --get remote.origin.url)

# Extract the username and repository name from the remote URL
if [[ "$REMOTE_URL" == *"github.com"* ]]; then
  if [[ "$REMOTE_URL" == *"git@github.com"* ]]; then
    # SSH format: git@github.com:username/repo.git
    USERNAME=$(echo "$REMOTE_URL" | sed 's/.*github.com://' | sed 's/\/.*//')
    REPO=$(echo "$REMOTE_URL" | sed 's/.*github.com:[^/]*\///' | sed 's/\.git$//')
  else
    # HTTPS format: https://github.com/username/repo.git
    USERNAME=$(echo "$REMOTE_URL" | sed 's/.*github.com\///' | sed 's/\/.*//')
    REPO=$(echo "$REMOTE_URL" | sed 's/.*github.com\/[^/]*\///' | sed 's/\.git$//')
  fi
fi

echo "Username: $USERNAME"
echo "Repository: $REPO"

link="https://github.com/$USERNAME/$REPO/pull/new/$BRANCH"

# Cross-platform open command
if command -v xdg-open > /dev/null; then
  # Linux
  xdg-open "$link"
elif command -v open > /dev/null; then
  # macOS
  open "$link"
else
  echo "Cannot open browser automatically. Please visit: $link"
fi
