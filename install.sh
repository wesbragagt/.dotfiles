#!/bin/sh

set -e

# Setups up a new development environment on macos

if ! command -v brew &> /dev/null
then
    echo "COMMAND could not be found"
    exit -1
else
    echo "Homebrew found"
fi

# Go setup directory
mkdir -p $HOME/go/{src, bin, pkg}

brew update &&
brew install nvm neovim ripgrep jq golang
brew install --cask iterm2 docker runjs rectangle visual-studio-code postman spotify


if ! command -v npm &> /dev/null
then
    echo "COMMAND could not be found"
    exit -1
else
# NPM 
npm install -g yarn &&
yarn install -g typescript-language-server typescript ts-node
fi
