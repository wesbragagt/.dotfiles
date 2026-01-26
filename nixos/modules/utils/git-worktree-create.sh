#!/bin/bash

# Script to create a git worktree with automatic .env file copying
# Usage: git-worktree-create.sh <branch-name>

set -e

# Check if branch name is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <branch-name>"
    echo "Creates a new git worktree branch and copies .env files from the main worktree"
    exit 1
fi

BRANCH_NAME=$1

# Get the name of the current worktree directory
CURRENT_DIR_NAME=$(basename "$GIT_ROOT")

# Determine the main worktree directory name
# Typically it's named 'main' or the repository name without any branch suffix
MAIN_WORKTREE_NAME="main"

# Check if we're already in the main worktree
if [ "$CURRENT_DIR_NAME" = "$MAIN_WORKTREE_NAME" ]; then
    MAIN_WORKTREE_PATH="$GIT_ROOT"
else
    # Look for the main worktree in the parent directory
    MAIN_WORKTREE_PATH="$MAIN_WORKTREE_NAME"
    if [ ! -d "$MAIN_WORKTREE_PATH" ]; then
        echo "Warning: Could not find main worktree at $MAIN_WORKTREE_PATH"
        echo "Continuing without .env file copying..."
        MAIN_WORKTREE_PATH=""
    fi
fi

# Create the new worktree
NEW_WORKTREE_PATH="$BRANCH_NAME"

echo "Creating new worktree at: $NEW_WORKTREE_PATH"
# Check if branch already exists
if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
    # Branch exists, use it
    git worktree add "$NEW_WORKTREE_PATH" "$BRANCH_NAME"
else
    # Branch doesn't exist, create it
    git worktree add "$NEW_WORKTREE_PATH" -b "$BRANCH_NAME"
fi

# Copy .env files from main worktree if it exists
if [ -n "$MAIN_WORKTREE_PATH" ] && [ -d "$MAIN_WORKTREE_PATH" ]; then
    echo "Looking for .env files in main worktree..."
    
    # Find all .env files in the main worktree
    while IFS= read -r -d '' env_file; do
        # Get the relative path from the main worktree root
        rel_path="${env_file#$MAIN_WORKTREE_PATH/}"
        
        # Construct the destination path
        dest_path="$NEW_WORKTREE_PATH/$rel_path"
        dest_dir=$(dirname "$dest_path")
        
        # Create the destination directory if it doesn't exist
        mkdir -p "$dest_dir"
        
        # Copy the .env file
        cp "$env_file" "$dest_path"
        echo "Copied: $rel_path"
    done < <(find "$MAIN_WORKTREE_PATH" -name ".env*" -type f -print0)
fi

echo "Worktree created successfully!"
echo "To switch to the new worktree, run:"
echo "  cd $NEW_WORKTREE_PATH"
