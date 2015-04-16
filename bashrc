
export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting

# added by travis gem
[ -f /Users/spencerdixon/.travis/travis.sh ] && source /Users/spencerdixon/.travis/travis.sh
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

export PS1="\[\e[01;37m\][\u@\h]\[\e[0m\]\[\e[00;37m\] \w\W\[\e[0m\]"

[ -s "/Users/spencerdixon/.scm_breeze/scm_breeze.sh" ] && source "/Users/spencerdixon/.scm_breeze/scm_breeze.sh"

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"
