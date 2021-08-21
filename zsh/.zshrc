# make git use nvim for editing
export VISUAL=nvim
export EDITOR="$VISUAL"
export NVM_DIR="$HOME/.nvm"
  [ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH
export BAT_THEME="monokai_pro"

# Path to your oh-my-zsh installation.
export ZSH="/Users/weslleybraga/.oh-my-zsh"
ZSH_THEME="amuse"

plugins=(git)

source $ZSH/oh-my-zsh.sh
alias ls="ls -1 -a"
alias vi="nvim"
alias config="vi ~/.zshrc"
alias reset="source ~/.zshrc"
alias gta="git add -A && git commit"
alias github="cd ~/Github"
alias speedtest="docker run -it --rm wesbragagt/alpine-speedtest"
alias awslocal="aws --endpoint-url=http://localhost:4566"
alias localstack-start="docker run --rm -p 4566:4566 -p 4571:4571 localstack/localstack"
code () { VSCODE_CWD="$PWD" open -n -b "com.microsoft.VSCode" --args $* ;}
alias 0="yarn start"
alias ydownload="node ~/Documents/Github/YoutubeMP3Downloader/index.js"
alias dc="docker-compose"
alias viconf="vi ~/.config/nvim/init.vim"
alias nvimdir="cd ~/.config/nvim"
