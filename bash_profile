
[[ -s "$HOME/.profile" ]] && source "$HOME/.profile" # Load the default .profile

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

# Git branch in prompt.

parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}


export PS1="\[\e[00;37m\][\u] \[\e[0m\]\[\e[01;37m\]\W\[\e[0m\]\[\e[00;37m\] \$(parse_git_branch)\[\e[0m\] "

[ -s "/Users/spencerdixon/.scm_breeze/scm_breeze.sh" ] && source "/Users/spencerdixon/.scm_breeze/scm_breeze.sh"

alias c="clear"
alias v="vim"
alias rs="rails s"
alias rc="rails c"
