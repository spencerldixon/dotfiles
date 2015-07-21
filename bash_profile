
[[ -s "$HOME/.profile" ]] && source "$HOME/.profile" # Load the default .profile

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

# Git branch in prompt.

parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

# Output name in console

export PS1="\[\e[00;37m\][\u] \[\e[0m\]\[\e[01;37m\]\W\[\e[0m\]\[\e[00;37m\] \$(parse_git_branch)\[\e[0m\] "

# Use SCM Breeze shortcuts for git

[ -s "/Users/spencerdixon/.scm_breeze/scm_breeze.sh" ] && source "/Users/spencerdixon/.scm_breeze/scm_breeze.sh"

# Make directories bold

LSCOLORS='GxFxCxDxBxegedabagaced'
export LSCOLORS

 #Aliases

alias c="clear"
alias v="vim"
alias rs="rails s"
alias rc="rails c"
alias be="bundle exec"
alias sideconf="bundle exec sidekiq -C config/sidekiq.yml"
alias clean_merged="git branch --merged | grep -v '\*' | xargs -n 1 git branch -d"
alias fuck='$(thefuck $(fc -ln -1))'
alias FUCK='fuck'
alias babs="babushka"
alias ls="ls -GF"
alias t="tmux"
alias ts="tmux list-sessions"
alias ta="tmux attach -t"
alias tns="TMUX= tmux new-session -d -s"
alias td="tmux detach"
