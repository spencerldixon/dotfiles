# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set CLICOLOR if you want Ansi Colors in iTerm2
export CLICOLOR=1

# # Set colors to match iTerm2 Terminal Colors
export TERM=xterm-256color

 #Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"
export PATH="/usr/local/sbin:$PATH"

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
HIST_STAMPS="dd.mm.yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git bundler macos rake ruby docker docker-compose)

source $ZSH/oh-my-zsh.sh

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

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
[ -s "$HOME/.scm_breeze/scm_breeze.sh" ] && source "$HOME/.scm_breeze/scm_breeze.sh"

# Colorize icons in ls with - https://github.com/athityakumar/colorls
# lc () { ruby ~/bin/colorls/colorls.rb $1; }

# Example aliases
 alias rs="rails s"
 alias rc="rails c"
 alias c="clear"
 alias v="vim"
 alias fucking="sudo"
 alias zshconfig="v ~/dotfiles/zsh/.zshrc && . ~/dotfiles/zsh/.zshrc"
 alias zshrc="zshconfig"
 alias vimrc="v ~/dotfiles/vim/.vimrc"
 alias babushkadeps="v ~/.babushka/sources/spencerldixon"
 alias dotfiles="v ~/dotfiles"
 alias tmuxreload="tmux source-file ~/.tmux.conf"
 alias tmuxconfig="v ~/dotfiles/tmux/.tmux.conf && tmuxreload"
 alias sideconf="bundle exec sidekiq -C config/sidekiq.yml"
 alias clean_merged="git branch --merged | grep -v '\*' | xargs -n 1 git branch -d"
 alias fuck='$(thefuck $(fc -ln -1))'
 alias FUCK='fuck'
 alias ls="ls -GF"
 alias t="tmux"
 alias ts="tmux list-sessions"
 alias ta="tmux attach -t"
 alias td="tmux detach"
 alias tns="TMUX=tmux new-session -d -s"
 alias smlist='spoof-mac.py list --wifi'
 alias smrandom='sudo spoof-mac.py randomize wi-fi; echo "Mac address spoofed!"; spoof-mac.py list --wifi'
 alias theme='v ~/dotfiles/oh_my_zsh/.oh-my-zsh/custom/themes/geometry.zsh-theme'
 alias ngrok='~/Rails/./ngrok http'
 alias gclean="git branch --merged origin/main | grep -v '\\*\\|main\\|develop' | xargs -n 1 git branch -d"
 alias ciaclean='gclean'
 alias flushdns='sudo dscacheutil -flushcache;sudo killall -HUP mDNSResponder'
 alias lc='lc -r'
 alias findrails='lsof -wni tcp:3000'
 alias killrails='kill -9 '
