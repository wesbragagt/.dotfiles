# clears path before path_helper so I don't get a screwed up path running tmux
# https://stackoverflow.com/questions/47442647/when-using-tmux-nvm-isnt-being-sourced
# https://superuser.com/questions/544989/does-tmux-sort-the-path-variable
if [ "$TMUX" ]; then
  if [ -f /etc/profile ];then
    PATH=""
    source /etc/profile
  fi
fi
export WORK_DIR="$HOME/dev/work"
export XDG_CONFIG_HOME="$HOME/.config"
export TYPESCRIPT_PLAYGROUND="$HOME/.playground/typescript"
export BASH_PLAYGROUND="$HOME/.playground/bash"
export DEBUG_ADAPTERS_DIR="$HOME/.debug_adapters"
export PATH=$HOME/bin:/opt/homebrew/bin:/usr/local/bin:$HOME/.npm_global/bin:$PATH

# dependencies that rely on chromium fail on M1 macs
# this will bypass any installs that might error
export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
export PUPPETEER_EXECUTABLE_PATH=chromium not found


# make git use nvim for editing
export VISUAL=nvim
export EDITOR="$VISUAL"

# fnm
if command -v fnm &> /dev/null;then
  eval "$(fnm env --use-on-cd)" &&
  export NODEJS_PATH=$(which node)
fi

# Rust or bust
source $HOME/.cargo/env &> /dev/null

# Golang
export GOPATH=$HOME/go

export NPM_PREFIX="$HOME/.npm_global"
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export FZF_DEFAULT_COMMAND='fd --type file --hidden --no-ignore --exclude node_modules --exclude .git --exclude build --exclude dist'
# select all - https://github.com/junegunn/fzf/issues/257
export FZF_DEFAULT_OPTS="-m --bind ctrl-t:toggle-all"

ZSH_THEME="simple"

plugins=(
  git 
  zsh-autosuggestions
  vi-mode
  fzf-tab
  z
)

# Binds Ctrl+y to confirm suggestion
bindkey '^y' autosuggest-accept

source $ZSH/oh-my-zsh.sh
source $HOME/.zsh-env &> /dev/null
source $HOME/.aliases &> /dev/null

# pnpm
export PNPM_HOME="$HOME/Library/pnpm/"
export PATH="$PNPM_HOME:$PATH"
# pnpm end
#
if command -v pyenv 1>/dev/null 2>&1; 
  then eval "$(pyenv init -)"
fi

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/weslleybraga/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)

# bun completions
[ -s "/Users/wesbragagt/.bun/_bun" ] && source "/Users/wesbragagt/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
#java
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
