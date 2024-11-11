# If you get an error like 2: command not found: compdef, then add the following to the beginning of your ~/.zshrc file:
autoload -Uz compinit
compinit

# https://superuser.com/questions/1403020/enter-key-prints-m-in-certain-situations-in-iterm
stty sane

# kubectl completion
if command -v kubectl &> /dev/null; then
  source <(kubectl completion zsh)
fi
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
export PATH=$HOME/bin:/opt/homebrew/bin:/usr/local/bin:$HOME/.npm_global/bin:$HOME/.local/bin:$PATH

# I hate pagers as default behavior on CLIs
export AWS_PAGER=""

# dependencies that rely on chromium fail on M1 macs
# this will bypass any installs that might error
export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
export PUPPETEER_EXECUTABLE_PATH=chromium not found

# provide auto completion for kubectl
if command -v kubectl &> /dev/null; then
  source <(kubectl completion zsh)
fi

# make git use nvim for editing
export VISUAL=nvim
export EDITOR="$VISUAL"

# fnm
if command -v fnm &> /dev/null;then
  eval "$(fnm env --use-on-cd)" &&
  export NODEJS_PATH=$(which node)
fi

if command -v direnv &> /dev/null; then
  eval "$(direnv hook zsh)"
fi

# Rust or bust
source $HOME/.cargo/env &> /dev/null

# Golang
export GOPATH=$HOME/go

# Python
# Make sure the virtualenv prompt always shows up
export VIRTUAL_ENV_DISABLE_PROMPT=

# on cd make sure to try to source a .venv/bin/activate

export NPM_PREFIX="$HOME/.npm_global"
export FZF_DEFAULT_COMMAND='fd --type file --hidden --no-ignore --exclude node_modules --exclude .git --exclude build --exclude dist --exclude .terragrunt-cache'
# select all - https://github.com/junegunn/fzf/issues/257
export FZF_DEFAULT_OPTS="-m --bind ctrl-t:toggle-all"

############################################
# ZSH Prompt & Plugins
# https://starship.rs/
############################################
eval "$(starship init zsh)"
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
if [ -d "$HOME/.zsh/zsh-autosuggestions/" ]; then
  # Accept suggestion with Ctrl + E
  source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

source $HOME/.zsh-env &> /dev/null
source $HOME/.aliases &> /dev/null

# pnpm
export PNPM_HOME="$HOME/Library/pnpm/"
export PATH="$PNPM_HOME:$PATH"
# pnpm end
#
if command -v pyenv 1>/dev/null 2>&1; then 
  export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
fi

if [[ -d "$HOME/.docker/bin" ]] then
  export PATH="$HOME/.docker/bin:$PATH"
fi

# bun completions
[ -s "/Users/wesbragagt/.bun/_bun" ] && source "/Users/wesbragagt/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
#java
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

# nix working with zsh
# https://github.com/NixOS/nix/issues/2280#issuecomment-1559447638
export PATH="$NIX_LINK/bin:/nix/var/nix/profiles/default/bin:$PATH"
export PATH="$HOME/.nix-profile/bin:$PATH"
# . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

# show virtual environment prompt
setopt PROMPT_SUBST
show_virtual_env() {
  if [[ -n "$VIRTUAL_ENV" && -n "$DIRENV_DIR" ]]; then
    echo "($(basename $VIRTUAL_ENV))"
  fi
}
PS1='$(show_virtual_env)'$PS1

# amazing history fuzzy search
source <(fzf --zsh)
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

# https://stackoverflow.com/questions/44084846/cannot-connect-to-the-docker-daemon-on-macos
export DOCKER_HOST=unix:///Users/$USER/Library/Containers/com.docker.docker/Data/docker.raw.sock
