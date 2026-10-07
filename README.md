# 🔴 Dotfiles

Personal configuration managed with [GNU Stow](https://www.gnu.org/software/stow/).

| Package | Configuration |
| --- | --- |
| `git` | Global Git ignore rules |
| `ghostty` | Ghostty terminal |
| `mise` | Development tool versions |
| `nvim` | Neovim |
| `oh_my_zsh` | Custom Oh My Zsh theme |
| `pi` | Pi settings, MCP servers, and custom usage footer |
| `tmux` | tmux and its plugin manager |
| `zsh` | Zsh shell |

## Installation

Install Stow, then clone this repository with its submodules:

```sh
brew install stow
git clone --recurse-submodules https://github.com/spencerldixon/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow --no-folding git ghostty mise nvim oh_my_zsh pi tmux zsh
```

Stow links files into your home directory. Install the applications separately, including Oh My Zsh if you use the shell configuration.

If Stow reports existing files, back them up and remove only the conflicting files before retrying. Do not delete whole configuration directories: they may contain credentials or other local data.

## Post-installation

- Reload the shell with `source ~/.zshrc`.
- In tmux, press the prefix (`Ctrl + A`), then `Shift + I` to install plugins.
- Configure Git to use the global ignore file:

  ```sh
  git config --global core.excludesfile ~/.gitignore_global
  ```

## Pi

The `pi` package links configuration into `~/.pi/agent`. To install only this package:

```sh
cd ~/dotfiles
stow --no-folding pi
```

Credentials, sessions, installed packages, caches, and the Herdr-managed extension stay local and are not tracked.

On a new machine:

1. Install Pi.
2. Run `/login` inside Pi to authenticate your AI provider.
3. Run `pi mcp login atlassian` to authenticate the Atlassian MCP server.

Pi installs the skills package declared in `settings.json` at startup. Run `/reload` in an existing Pi session after changing configuration.

## Updating

Pull configuration changes and update submodules:

```sh
cd ~/dotfiles
git pull
git submodule update --init --recursive
```

Run the Stow command again when adding new configuration files. Edits to linked files appear directly in this repository; review them before committing.

### Submodules

- `tmux/.tmux/plugins/tpm` — [tmux Plugin Manager](https://github.com/tmux-plugins/tpm)
