#!/bin/bash

set -e

branch=$(git branch | fzf)

git switch $branch
