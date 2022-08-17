# clears path before path_helper so I don't get a screwed up path running tmux
# https://stackoverflow.com/questions/47442647/when-using-tmux-nvm-isnt-being-sourced
# https://superuser.com/questions/544989/does-tmux-sort-the-path-variable
if [ -f /etc/profile ]; then
    PATH=""
    source /etc/profile
fi

export XDG_CONFIG_HOME="$HOME/.config"
export TYPESCRIPT_PLAYGROUND="$HOME/.playground/typescript"
export BASH_PLAYGROUND="$HOME/.playground/bash"
export DEBUG_ADAPTERS_DIR="$HOME/.debug_adapters"
export PATH=$HOME/bin:/opt/homebrew/bin:/usr/local/bin:$HOME/.npm_global/bin:$PATH

# nix
export PATH=/nix/var/nix/profiles/default/bin:$PATH
# make git use nvim for editing
export VISUAL=nvim
export EDITOR="$VISUAL"

# fnm
eval "$(fnm env --use-on-cd)"

export NPM_PREFIX="$HOME/.npm_global"
export DOTFILES="$HOME/.dotfiles"
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export FZF_DEFAULT_COMMAND='rg --files --hidden --no-require-git --follow --glob "!.git/*"'

ZSH_THEME="simple"

plugins=(git)

source $ZSH/oh-my-zsh.sh
source "$DOTFILES/zsh/.zsh-env" &> /dev/null

alias scripts="jq '.scripts' ./package.json"
alias dot="cd $DOTFILES"
alias dotsync="cd $DOTFILES && git add -A && git commit -m 'sync' && git push"
alias vi="nvim"
alias config="vi $DOTFILES/zsh/.zshrc"
alias config-nvim="vi $DOTFILES/nvim/.config/nvim/init.vim" 
alias reset="source ~/.zshrc"
alias dev="cd ~/dev"
# fzf combo scripts
alias ff="bash $DOTFILES/utils/tmux-sessionizer.sh"
alias ss="bash $DOTFILES/utils/list-packagejson-scripts.sh"
alias to="bash $DOTFILES/utils/fzf-git-checkout.sh"
alias fa="bash $DOTFILES/utils/fzf-vim.sh"
alias fp="bash $DOTFILES/utils/fzf-rg.sh"
alias send-cmd="bash $DOTFILES/utils/tmux-commander.sh"
code () { VSCODE_CWD="$PWD" open -n -b "com.microsoft.VSCode" --args $* ;}

senv(){
  export $(cat $1 | xargs)
}
alias gta="git add -A && git commit --amend --no-edit"
alias gtf="gta && git push -f"
alias clean="git branch --merged | egrep -v '(^\*|master|main|dev|nonprod)' | xargs git branch -D"
alias tt="tmux -f $HOME/.config/tmux/.tmux.conf"
alias y="yarn"
alias ls="ls -a"
alias l="lsd -a"
alias dc="docker-compose"
alias new="git checkout -b"
alias mux="bash $DOTFILES/utils/tmux-new-session.sh"
# Run a fuzzy search through test files and run jest
function jj(){
  node_modules/.bin/jest `find ./src -type f \( -name "*.test*" -or -name "*.spec*" \) | fzf`
}


function cdl(){
  cd $(dirname `fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'`)
}

function cd/(){
  cd $(git rev-parse --show-toplevel)
}

function get_external_ip(){
  curl ipecho.net/plain ; echo
}

function emoji () { # Fuzzy match emoji printing. Credits: Trace Ohrt
  local emojis selected_emoji
  emojis=$(curl -sSL 'https://git.io/JXXO7')
  selected_emoji=$(echo "$emojis" | fzf)
  echo $selected_emoji
}
