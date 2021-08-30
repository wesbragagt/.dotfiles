#! /bin/sh
# This script will symlink all the necessary files to the home directory

set -e

# roots
nvim_root="./nvim/init.vim"
zsh_root="./zsh/.zshrc"
tmux_root="./tmux/.tmux.conf"

# links
nvim_link="$HOME/.config/nvim/init.vim"
zsh_link="$HOME/.zshrc"
tmux_link="$HOME/.tmux.conf"

# Run
ln -s -f nvim_root nvim_link &&
ln -s -f zsh_root zsh_link &&
ln -s -f tmux_root tmux_link

echo "Done symlinking files."
