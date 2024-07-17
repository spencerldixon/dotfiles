# 🔴 Dotfiles

My dotfiles setup using gnu stow for the following

- Neovim
- Vim
- Iterm
- Zellij
- Zsh
- Oh my zsh
- .gitignore (global)

## Installation

Ensure you have stow installed:

```
brew install stow
```

```
cd ~
git clone git://github.com/spencerldixon/dotfiles.git
git pull --recurse-submodules
cd ~/dotfiles
stow git iterm2 nvim oh_my_zsh tmux vim zellij zsh
```

## Post-Installation

- Run `tmux prefix (Ctrl + A) + I` to install tmux plugins
- Set the iTerm colour scheme to Tokyo Night Dark and font to MesloLGL nerd font.

You might need to run `source ~/.zshrc` to reload zsh

## Gitignore

You can set the global gitignore with:

```
git config --global core.excludesfile ~/.gitignore_global
```

## Submodules

Since dotfiles can rely on other repos, I've chosen to add these in as git submodules, meaning they should pull their respective repos when this repo is cloned.

Submodules are as follows:

- `tmux/.tmux/plugins/tpm` - https://github.com/tmux-plugins/tpm

## Updating

It's just git! Pull and push as you would normally.
