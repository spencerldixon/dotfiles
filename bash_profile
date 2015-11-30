
[[ -s "$HOME/.profile" ]] && source "$HOME/.profile" # Load the default .profile

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

# Git branch in prompt.

parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

# Output name in console

export PS1="\[\e[00;37m\][\u] \[\e[0m\]\[\e[01;37m\]\W\[\e[0m\] \[\e[0;31m\][\$(parse_git_branch)]\[\e[00;37m\] >>>\[\e[0m\] "

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
alias py="python"
alias smlist='spoof-mac.py list --wifi'
alias smrandom='sudo spoof-mac.py randomize wi-fi; echo "Mac address spoofed!"; spoof-mac.py list --wifi'

##
# Your previous /Users/spencerdixon/.bash_profile file was backed up as /Users/spencerdixon/.bash_profile.macports-saved_2015-08-14_at_16:16:09
##

# MacPorts Installer addition on 2015-08-14_at_16:16:09: adding an appropriate PATH variable for use with MacPorts.
export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
# Finished adapting your PATH environment variable for use with MacPorts.

