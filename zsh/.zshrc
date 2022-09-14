# clears path before path_helper so I don't get a screwed up path running tmux
# https://stackoverflow.com/questions/47442647/when-using-tmux-nvm-isnt-being-sourced
# https://superuser.com/questions/544989/does-tmux-sort-the-path-variable
if [ "$TMUX" ]; then
  if [ -f /etc/profile ];then
    PATH=""
    source /etc/profile
  fi
fi

export XDG_CONFIG_HOME="$HOME/.config"
export TYPESCRIPT_PLAYGROUND="$HOME/.playground/typescript"
export BASH_PLAYGROUND="$HOME/.playground/bash"
export DEBUG_ADAPTERS_DIR="$HOME/.debug_adapters"
export PATH=$HOME/bin:/opt/homebrew/bin:/usr/local/bin:$HOME/.npm_global/bin:$PATH
export GOPATH=$HOME/go

# make git use nvim for editing
export VISUAL=nvim
export EDITOR="$VISUAL"

# fnm
if command -v fnm &> /dev/null;then
  eval "$(fnm env --use-on-cd)"
fi

export NPM_PREFIX="$HOME/.npm_global"
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export FZF_DEFAULT_COMMAND='rg --files --hidden --no-require-git --follow --glob "!.git/*" --glob "!node_modules/*"'

ZSH_THEME="simple"

plugins=(
  git 
  zsh-autosuggestions
  fzf-tab
)

source $ZSH/oh-my-zsh.sh
source $HOME/.zsh-env &> /dev/null
source $HOME/.aliases &> /dev/null
