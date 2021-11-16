export NVM_DIR="$HOME/.nvm"
  [ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH:${GOPATH}/bin:${GOROOT}/bin:$PATH
# make git use nvim for editing
export VISUAL=nvim
export EDITOR="$VISUAL"
export GOPATH=$HOME/go
export GOROOT="$(brew --prefix golang)/libexec"
export DOTFILES="$HOME/.dotfiles"
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="simple"

plugins=(git)
source $ZSH/oh-my-zsh.sh
alias scripts="jq '.scripts' ./package.json"
alias ls="logo-ls -a"
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
code () { VSCODE_CWD="$PWD" open -n -b "com.microsoft.VSCode" --args $* ;}

alias luamake=/Users/weslleybraga/.dotfiles/nvim/.config/nvim/lua-language-server/3rd/luamake/luamake
senv(){
  export $(cat $1 | xargs)
}
alias denv="senv .env.development"
alias penv="senv .env.production"
alias gta="git add -A && git commit --amend --no-edit"
alias clean="git branch --merged | egrep -v '(^\*|master|main|nonprod)' | xargs git branch -D"
