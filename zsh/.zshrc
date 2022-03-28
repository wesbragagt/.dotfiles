export PATH=$HOME/bin:/opt/homebrew/bin:/usr/local/bin:$HOME/.npm_global/bin:$PATH
# make git use nvim for editing
export VISUAL=nvim
export EDITOR="$VISUAL"

export NVM_DIR="$HOME/.node_version_manager"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

export NPM_PREFIX="$HOME/.npm_global"
export DOTFILES="$HOME/.dotfiles"
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
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
alias l="logo-ls -1 -a"
alias dc="docker-compose"
alias new="git checkout -b"
