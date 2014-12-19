# Dotfiles

My split window vim, and iterm2 setup for Ruby on Rails development

## Installation

Install Vundle to manage vim plugins:

`git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim`

To install plugins, run this from the command line:

`vim +PluginInstall +qall`

Run these commands from your command line to use the install script:

```
cd ~
git clone git://github.com/spencerldixon/dotfiles.git
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

## Updating

It's just git! Pull and push as you would normally. You will need to run the installation script each time to copy new files and folders.

## Help

For some problems I've come across during installation, these might help...

https://help.github.com/articles/changing-a-remote-s-url/
https://help.github.com/articles/generating-ssh-keys/