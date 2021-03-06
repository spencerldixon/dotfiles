#!/bin/bash
############################
# .make.sh
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles
############################

########## Variables

dir=$HOME/dotfiles                            # dotfiles directory
olddir=$HOME/dotfiles_old                     # old dotfiles backup directory
files=".vimrc .tmux.conf .zshrc"              # list of files to symlink in homedir

##########

# create dotfiles_old in homedir
echo "Creating $olddir for backup of any existing dotfiles in ~"
mkdir -p $olddir
echo "...done"

# change to the dotfiles directory
echo "Changing to the $dir directory"
cd $dir
echo "...done!"

# move any existing dotfiles in homedir to dotfiles_old directory, then create symlinks
for file in $files; do
    echo "Moving any existing dotfiles from ~ to $olddir"
    mv ~/$file ~/dotfiles_old/
    echo "Creating symlink to $file in home directory."
    ln  -s $dir/$file $HOME/$file
done

# Move geometry

cd ~
mkdir -p .oh-my-zsh/custom/themes
ln -s $dir/geometry.zsh-theme $HOME/.oh-my-zsh/custom/themes/geometry.zsh-theme

# Copy tmux files

cd ~
cp -R $dir/.tmux $HOME/

# Symlink the global gitignore
ln -s $dir/.gitignore_global $HOME/.gitignore_global

# Set global gitignore
git config --global core.excludesfile ~/.gitignore_global
