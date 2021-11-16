#!/bin/bash

set -e

branch=$(git branch -r | fzf)

git checkout $branch
