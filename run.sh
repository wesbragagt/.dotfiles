#! /bin/bash
# This script will symlink all the necessary files to the home directory

set -e
# Run
sudo ln -svf ~/.dotfiles/nvim/init.vim ~/.config/nvim/init.vim &&
sudo ln -svf ~/.dotfiles/nvim/coc-settings.json ~/.config/nvim/coc-settings.json &&
sudo ln -svf ~/.dotfiles/zsh/.zshrc ~/.zshrc &&
sudo ln -svf ~/.dotfiles/tmux/.tmux.config ~/.tmux.config

echo "Done symlinking files."
