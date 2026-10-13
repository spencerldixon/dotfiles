# 🔴 Dotfiles

Personal macOS configuration managed with [GNU Stow](https://www.gnu.org/software/stow/).

[Command cheatsheet](CHEATSHEET.md) · [Codex status bar](codex/README.md)

| Package | Configuration |
| --- | --- |
| `agents` | Shared instructions for Claude Code, Codex, and Pi |
| `claude` | Claude Code settings and status line |
| `codex` | Codex settings and status line |
| `git` | Global ignore rules |
| `ghostty` | Ghostty terminal |
| `mise` | Development tool versions |
| `nvim` | Neovim |
| `oh_my_zsh` | Custom shell theme |
| `pi` | Pi settings, MCP servers, and usage footer |
| `tmux` | tmux and plugin manager |
| `zsh` | Shell configuration |

## Installation

Install [Homebrew](https://brew.sh) and finish installing Xcode Command Line Tools (`xcode-select --install`) first.

Ensure you have pre-requisites installed. Do this via the ansible scripts in [config](https://github.com/spencerldixon/config) or manually:

```sh
brew install stow mise neovim tmux jq fzf zsh-autosuggestions zoxide ripgrep tree-sitter-cli node openssl@3 readline libyaml gmp autoconf scmpuff direnv
brew install --cask ghostty claude-code codex font-jetbrains-mono-nerd-font
```
```sh
git clone --recurse-submodules https://github.com/spencerldixon/dotfiles.git ~/dotfiles
cd ~/dotfiles

stow --no-folding agents claude codex git ghostty mise nvim oh_my_zsh pi tmux zsh
```

## Post-installation

- In tmux, press `Ctrl + A`, then `Shift + I` to install plugins.
- Shell navigation uses zoxide (`z dotfiles`); fzf provides `Ctrl + R` history and `Ctrl + T` file search.

## Agent instructions

Edit [AGENTS.md](AGENTS.md) once for all three harnesses. `stow --no-folding agents` installs these global symlinks:

| Harness | Instruction file |
| --- | --- |
| Claude Code | `~/.claude/CLAUDE.md` |
| Codex | `~/.codex/AGENTS.md` |
| Pi | `~/.pi/agent/AGENTS.md` |

Start new Claude Code and Codex sessions after edits; use `/reload` in Pi. 

## Updating

```sh
cd ~/dotfiles
git pull
git submodule update --init --recursive
```

Rerun the relevant Stow command when adding files. Linked-file edits change this repository directly.
