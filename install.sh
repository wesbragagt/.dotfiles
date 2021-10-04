#!/bin/bash
# exec > output.log
 
echo "Configuring Homebrew..."

# Useful dev settings that increase accessibility
chflags nohidden ~/Library
defaults write com.apple.finder AppleShowAllFiles YES
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true

xcode-select --install

sudo chown -R $(whoami) /usr/local/share/zsh /usr/local/share/zsh/site-functions
chmod u+w /usr/local/share/zsh /usr/local/share/zsh/site-functions

# Check for Homebrew, install if we don't have it
if test ! $(which brew); then
    echo "Installing homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else 
	echo "Brew installed"
fi

# Update homebrew recipes
brew update

echo "Installing cask..."
brew install cask


PACKAGES=(
  fzf
  stow
	nvm
	zsh
	node
	git
	python3
	docker
	openssl
	wget
	yarn
  neovim
  ripgrep
  jq
  golang
  gh
)

echo "Installing packages..."
brew install ${PACKAGES[@]}

#install vim-plug
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

#install pip
if test $(which python); then
    echo "Installing pip..."
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
    python get-pip.py

else
	echo "Python needs to be installed before installing Pip."
fi    

export HOMEBREW_CASK_OPTS="--appdir=/Applications"

apps=(
    slack
    visual-studio-code  
    google-chrome
    postman
    iterm2
    runjs
    rectangle
)

#install casks
echo "Installing cask apps..."
brew install --cask ${apps[@]} --appdir=/Applications

if ! command -v npm &> /dev/null
then
    echo "COMMAND could not be found"
    exit -1
else
# NPM 
npm install -g typescript-language-server typescript ts-node
fi
