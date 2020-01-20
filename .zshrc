# Path to your oh-my-zsh installation.
export ZSH=/Users/spencerdixon/.oh-my-zsh

# RVM Path
export GEM_HOME=$HOME/.gem
export GEM_PATH=$HOME/.gem
# Set CLICOLOR if you want Ansi Colors in iTerm2
export CLICOLOR=1
#
# # Set colors to match iTerm2 Terminal Colors
export TERM=xterm-256color

 #Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

export PATH="/usr/local/sbin:$PATH"

# Base16 Shell
#BASE16_SHELL="$HOME/.config/base16-shell/base16-eighties.dark.sh"
#[[ -s $BASE16_SHELL ]] && source $BASE16_SHELL

#Gruvbox
#source "$HOME/dotfiles/vim/bundle/gruvbox/gruvbox_256palette_osx.sh"

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="geometry"

#UNCOMMENT THESE LINES FOR PURE THEME
#autoload -U promptinit && promptinit
#PROMPT='%(?.%F{magenta}.%F{red}❯%F{magenta})❯%f '
#PURE_GIT_PULL=0
#prompt pure

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"
# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git bundler osx rake ruby)

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

source $ZSH/oh-my-zsh.sh

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Settings for SCM Breeze shortcuts
# [ -s "/Users/spencerdixon/.scm_breeze/scm_breeze.sh" ] && source "/Users/spencerdixon/.scm_breeze/scm_breeze.sh"
[ -s "$HOME/.scm_breeze/scm_breeze.sh" ] && source "$HOME/.scm_breeze/scm_breeze.sh"
#

# Colorize icons in ls with - https://github.com/athityakumar/colorls
lc () { ruby ~/bin/colorls/colorls.rb $1; }

# Example aliases
 alias rs="rails s"
 alias rc="rails c"
 alias c="clear"
 alias v="vim"
 alias fucking="sudo"
 alias zshconfig="v ~/.zshrc && . ~/.zshrc"
 alias zshrc="zshconfig"
 alias vimrc="v ~/dotfiles/.vimrc"
 alias dotfiles="v ~/dotfiles"
 alias tmuxreload="tmux source-file ~/.tmux.conf"
 alias tmuxconfig="v ~/dotfiles/.tmux.conf && tmuxreload"
 alias ohmyzsh="v ~/.oh-my-zsh"
 alias be="bundle exec"
 alias bundaru="bundle"
 alias upadataru="update"
 alias instaru="install"
 alias railsu="rails"
 alias sideconf="bundle exec sidekiq -C config/sidekiq.yml"
 alias clean_merged="git branch --merged | grep -v '\*' | xargs -n 1 git branch -d"
 alias fuck='$(thefuck $(fc -ln -1))'
 alias FUCK='fuck'
 alias babs="babushka"
 alias ls="ls -GF"
 alias t="tmux"
 alias ts="tmux list-sessions"
 alias ta="tmux attach -t"
 alias td="tmux detach"
 alias tns="TMUX= tmux new-session -d -s"
 alias py="python"
 alias smlist='spoof-mac.py list --wifi'
 alias smrandom='sudo spoof-mac.py randomize wi-fi; echo "Mac address spoofed!"; spoof-mac.py list --wifi'
 alias theme='v ~/.oh-my-zsh/custom/themes/geometry.zsh-theme'
 alias beyonce='osascript ~/dotfiles/beyonce.scpt && for (( c=1; c<=40; c++)) ; do echo "👑 🐝 🍋 " && sleep 0.2; done'
 alias newpost='./initpost.sh -c'
 alias firefox='open /Applications/Firefox.app'
 alias ngrok='~/Rails/./ngrok http'
 alias gclean="git branch --merged origin/master | grep -v '\\*\\|master\\|develop' | xargs -n 1 git branch -d"
 alias ciaclean='gclean'
 alias flushdns='sudo dscacheutil -flushcache;sudo killall -HUP mDNSResponder'
 alias lc='lc -r'
 alias findrails='lsof -wni tcp:3000'
 alias killrails='kill -9 '
 alias taskdone='osascript ~/dotfiles/done.scpt'

export PATH="/usr/local/bin:/usr/local/sbin:$PATH"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
export PATH="/usr/local/opt/openssl/bin:$PATH"

export PATH="/Users/spencerdixon/anaconda/bin:$PATH"

export PATH="$PATH:/Applications/Postgres.app/Contents/Versions/latest/bin"
export PATH="/usr/local/opt/qt@5.5/bin:$PATH"

