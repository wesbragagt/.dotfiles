#! /bin/bash
# This script will symlink all the necessary files to the home directory

# Run
mkdir -p ~/.config/nvim &&
ln -svf ~/.dotfiles/nvim/init.vim ~/.config/nvim/init.vim 
ln -svf ~/.dotfiles/nvim/coc-settings.json ~/.config/nvim/coc-settings.json 
ln -svf ~/.dotfiles/zsh/.zshrc ~/.zshrc 
ln -svf ~/.dotfiles/tmux/.tmux.conf ~/.tmux.conf

echo "Done symlinking files."
