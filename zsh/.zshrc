# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH:${GOPATH}/bin:${GOROOT}/bin:$PATH
# make git use nvim for editing
export VISUAL=nvim
export EDITOR="$VISUAL"
export NVM_DIR="$HOME/.nvm"
  [ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
export GOPATH=$HOME/go
export GOROOT="$(brew --prefix golang)/libexec"
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="simple"

plugins=(git)

source $ZSH/oh-my-zsh.sh
alias dotsync="cd ~/.dotfiles && git add -A && git commit -m 'sync' && git push"
alias vi="nvim"
alias config="vi ~/.dotfiles/zsh/.zshrc"
alias config-nvim="vi ~/.dotfiles/nvim/init.vim" 
alias reset="source ~/.zshrc"
alias gta="git add -A && git commit"
alias awslocal="aws --endpoint-url=http://localhost:4566"
code () { VSCODE_CWD="$PWD" open -n -b "com.microsoft.VSCode" --args $* ;}
alias 0="yarn start"
