# 🔴 Dotfiles

Personal macOS configuration managed with [GNU Stow](https://www.gnu.org/software/stow/).

[Command cheatsheet](CHEATSHEET.md) · [Codex status bar](codex/README.md)

| Package | Configuration |
| --- | --- |
| `agents` | Shared instructions for Claude Code, Codex, and Pi |
| `claude` | Claude Code settings and status line |
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

```sh
brew install stow mise neovim tmux jq fzf zsh-autosuggestions zoxide ripgrep tree-sitter-cli node
brew install openssl@3 readline libyaml gmp autoconf
brew install --cask ghostty claude-code codex font-jetbrains-mono-nerd-font
git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
curl -fsSL https://pi.dev/install.sh | sh
```

Clone and link the configuration, then install the Mise-managed tools:

```sh
git clone --recurse-submodules https://github.com/spencerldixon/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow --no-folding agents claude git ghostty mise nvim oh_my_zsh pi tmux zsh
mise install
git config --global core.excludesfile ~/.gitignore_global
source ~/.zshrc
```

For Stow conflicts, back up and move only the conflicting files, then retry. Keep configuration directories containing credentials or runtime data.

Neovim needs version 0.12+ and tree-sitter CLI 0.26.1+; Xcode supplies the C compiler. The extra libraries support Ruby builds. Optional shell helpers: `brew install scmpuff direnv`.

## Post-installation

- Use **JetBrainsMono Nerd Font** in your terminal. Open `nvim` to install plugins, then run `:checkhealth`.
- In tmux, press `Ctrl + A`, then `Shift + I` to install plugins.
- Run `claude` and `codex` to sign in. In Pi, run `/login`, then `pi mcp login atlassian` in your shell.
- Shell navigation uses zoxide (`z dotfiles`); fzf provides `Ctrl + R` history and `Ctrl + T` file search.

## Agent instructions

Edit [AGENTS.md](AGENTS.md) once for all three harnesses. `stow --no-folding agents` installs these global symlinks:

| Harness | Instruction file |
| --- | --- |
| Claude Code | `~/.claude/CLAUDE.md` |
| Codex | `~/.codex/AGENTS.md` |
| Pi | `~/.pi/agent/AGENTS.md` |

Start new Claude Code and Codex sessions after edits; use `/reload` in Pi. Pi installs the shared skills package at startup.

## Local dependencies

Before starting Claude, restore the private skills checkout to `~/Rails/private-skills` and register its path on this machine:

```sh
claude plugin marketplace add "$HOME/Rails/private-skills"
claude plugin install private-skills@spencerldixon-private
```

Herdr hooks run only when installed. Credentials, sessions, caches, and Herdr-managed files stay local.

## Updating

```sh
cd ~/dotfiles
git pull
git submodule update --init --recursive
```

Rerun the relevant Stow command when adding files. Linked-file edits change this repository directly.
