#! /bin/bash

if ! command -v go &> /dev/null
then
  brew install golang
  exit 0
fi

if ! command -v git &> /dev/null
then
  brew install git
  exit 0
fi

# https://github.com/Yash-Handa/logo-ls
cd ~ && 
git clone https://github.com/Yash-Handa/logo-ls.git &&
cd ~/logo-ls &&
go mod tidy &&
go build &&
sudo cp logo-ls /usr/local/bin
