# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$HOME/.npm_global/bin:$PATH
# make git use nvim for editing
export VISUAL=nvim
export EDITOR="$VISUAL"
export NPM_PREFIX="$HOME/.npm_global"
export DOTFILES="$HOME/.dotfiles"
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="simple"

plugins=(git)
source $ZSH/oh-my-zsh.sh
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

alias luamake=/Users/weslleybraga/.dotfiles/nvim/.config/nvim/lua-language-server/3rd/luamake/luamake
senv(){
  export $(cat $1 | xargs)
}
alias denv="senv .env.development"
alias penv="senv .env.production"
alias gta="git add -A && git commit --amend --no-edit"
alias gtf="gta && git push -f"
alias clean="git branch --merged | egrep -v '(^\*|master|main|dev|nonprod)' | xargs git branch -D"
alias tt="tmux -f $HOME/.tmux/.tmux.conf"
alias y="yarn"
alias l="logo-ls -1"

alias asurion_refresh_aws_credentials="ssogenerator"
function asurion_set_aws_credentials () {
  echo "refreshing tokens"
  asurion_refresh_aws_credentials
  if (( $# == 0 ))
  then
    echo "usage: asurion_set_aws_credentials [profile name]";
  else
    export AWS_ACCESS_KEY_ID=`grep -F -A 3 $1 ~/.aws/credentials | grep aws_access_key_id | sed -e "s/aws_access_key_id=//g"`
    export AWS_SECRET_ACCESS_KEY=`grep -F -A 3 $1 ~/.aws/credentials | grep aws_secret_access_key | sed -e "s/aws_secret_access_key=//g"`
    export AWS_SECURITY_TOKEN=`grep -F -A 3 $1 ~/.aws/credentials | grep aws_session_token | sed -e "s/aws_session_token=//g"`
    export AWS_SESSION_TOKEN=`grep -F -A 3 $1 ~/.aws/credentials | grep aws_session_token | sed -e "s/aws_session_token=//g"`
  fi
}
