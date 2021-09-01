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

brew update &&
brew install node@14 &&
brew install --cask docker
brew install --cask runjs  &&
brew install --cask rectangle &&
brew install --cask visual-studio-code &&
brew install --cask postman &&
brew install --cask spotify &&
brew install neovim &&
brew install jq &&
# NPM 
npm install -g yarn &&
yarn install -g typescript-language-server &&
yarn install -g typescript &&
yarn install -g ts-node
