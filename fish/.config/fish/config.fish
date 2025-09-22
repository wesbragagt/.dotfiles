# Environment variables
set -gx DOTFILES ~/.dotfiles

starship init fish | source
zoxide init fish | source

source $HOME/.config/fish/.aliases
