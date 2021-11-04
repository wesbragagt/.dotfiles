#!/bin/bash

set -e

branch=$(git branch | fzf)

git checkout $branch
