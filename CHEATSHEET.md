# Command cheatsheet

These commands match this repository's Zsh, Ghostty, and tmux configuration. Open a new terminal after shell configuration changes, or reload with `source ~/.zshrc`.

## Shell navigation and history

| Command / shortcut | Action |
| --- | --- |
| `Ctrl + R` | Search command history with fzf; Enter inserts the selected command. |
| `Ctrl + T` | Select file paths with fzf and insert them into the command line. |
| `Alt + C` | Select a directory with fzf and change into it. |
| Right arrow at the end of the line | Accept the gray autosuggestion from history. |
| `z dotfiles` | Jump to a previously visited directory matching `dotfiles`. |
| `z -l dotfiles` | List matching directories without changing directory. |
| `c` | Clear the terminal. |
| `n file` | Open a file in Neovim. |
| `dotfiles` | Open the dotfiles directory in Neovim. |
| `zshconfig` / `zshrc` | Edit the shell config in Neovim, then reload it. |
| `alias` | List the current shell aliases. |
| `type command` | Check whether a command is an alias, function, or executable. |

If your terminal captures `Alt + C`, try Esc followed by C.

## Git

These shortcuts come from the enabled Oh My Zsh Git plugin. Optional SCM Breeze may override some aliases; use `type shortcut` to check the active definition.

| Command | Action |
| --- | --- |
| `gst` | Show Git status. |
| `gd` | Show unstaged changes. |
| `gds` | Show staged changes. |
| `gaa` | Stage changes under the current directory (SCM Breeze adds `.`). |
| `gcmsg "message"` | Commit with a message. |
| `gco branch` | Check out a branch. |
| `gcb branch` | Create and check out a branch. |
| `glog` | Show a compact commit graph. |
| `gl` | Show a formatted commit graph (overridden by SCM Breeze on this machine). |
| `git pull` | Pull changes. |
| `gp` | Push changes. |
| `gclean` / `ciaclean` | Delete local branches merged into `origin/main`, excluding the current branch, `main`, and `develop`. |

## Docker Compose

The enabled plugin uses `docker compose` when available, otherwise `docker-compose`.

| Command | Action |
| --- | --- |
| `dcup` | Start services in the foreground. |
| `dcupd` | Start services in the background. |
| `dcupdb` | Build and start services in the background. |
| `dcps` | List services. |
| `dclf` | Follow service logs. |
| `dce service sh` | Open a shell in a running service. |
| `dcdn` | Stop and remove the project's containers and networks. |
| `findrails` | Show the process listening on port 3000. |

## Python and uv

| Command | Action |
| --- | --- |
| `pm check` | Run `python manage.py check`. |
| `uvpm check` / `uvrm check` | Run `uv run manage.py check`. |
| `uvr pytest` | Run `uv run pytest`. |

These aliases need the corresponding project files and tools installed.

## Ghostty

| Shortcut | Action |
| --- | --- |
| Cmd + backquote (\`) | Toggle the dropdown terminal from any app while Ghostty is running. |
| `Cmd + Shift + E` | Open the entire scrollback in the macOS default text editor. |
| `Cmd + Shift + ,` | Reload Ghostty configuration. |

The dropdown appears at the top of the screen under the mouse and fills 45% of its height. It hides when focus moves to another window.

Commands that run for at least 10 seconds send a desktop notification when they finish if their terminal is unfocused. This uses Ghostty's enabled Zsh shell integration.

The background uses 99% opacity with blur, including tmux and Neovim cell backgrounds. The mouse pointer hides while typing. Restart Ghostty after changing background opacity on macOS.

## tmux

The prefix is `Ctrl + A`. For prefix shortcuts, press the prefix, release it, then press the listed key.

| Command / shortcut | Action |
| --- | --- |
| `t` | Start tmux. |
| `ts` | List sessions. |
| `ta name` | Attach to a session. |
| `tns name` | Create a detached session. |
| `td` | Detach from the current session. |
| Prefix, `c` | Create a window in the current pane's directory. |
| Prefix, `\|` | Split into side-by-side panes. |
| Prefix, `-` | Split into stacked panes. |
| Prefix, `h` / `j` / `k` / `l` | Move left / down / up / right between panes. |
| Prefix, `r` | Reload tmux configuration. |
| Prefix, `Shift + I` | Install configured tmux plugins with TPM. |
| `tmuxreload` | Reload tmux configuration from the shell. |
| `tmuxconfig` | Edit tmux configuration, then reload it. |

## mise

Global tool versions live in `mise/.config/mise/config.toml`, linked to `~/.config/mise/config.toml`. Project configuration can override them.

| Command | Action |
| --- | --- |
| `mise --version` | Show the mise version. |
| `mise ls` | Show tool versions and their configuration sources. |
| `mise current` | Show the selected versions for the current directory. |
| `mise install` | Install tools declared by the current configuration. |
| `mise use python@3.13` | Install and select Python 3.13 in the current project's mise config. |
| `mise use --pin python@3.13` | Resolve Python 3.13 and save its exact version in the project config. |
| `mise use -g python@3.13` | Change the global Python version. |
| `mise exec python@3.13 -- python --version` | Run a command with a particular tool version without changing configuration. |
| `mise tasks` | List available project tasks. |
| `mise run test` | Run a project task named `test`, if defined. |
| `mise doctor` | Diagnose mise setup problems. |
| `~/.local/bin/mise self-update --yes --no-plugins` | Update the standalone mise used for shell activation. |
| `brew upgrade mise` | Update the separate Homebrew mise installation, if installed. |

The configured `python.uv_venv_auto` setting integrates with uv project virtual environments. See the [mise settings documentation](https://mise.jdx.dev/configuration/settings.html#python-uv_venv_auto) for supported values.

### Useful next steps for projects

These are examples to add to an application's `mise.toml`; they are not enabled by this dotfiles repository.

- **Project versions:** run `mise use --pin python@3.13` inside a project and commit the resulting configuration. Keep global versions as defaults and select the project's required version explicitly. See [mise use](https://mise.jdx.dev/cli/use.html).
- **Tasks:** give common development commands names that teammates and CI can share. See [mise tasks](https://mise.jdx.dev/tasks/).
- **Environment variables:** declare project settings in `[env]` so mise applies them when entering the project. See [mise environments](https://mise.jdx.dev/environments/).
- **One-off versions:** use `mise exec python@3.13 -- python --version` to try a tool version without editing configuration. Missing versions may be installed automatically. See [mise exec](https://mise.jdx.dev/cli/exec.html).

For a Django project, a starting point is:

```toml
[env]
DJANGO_SETTINGS_MODULE = "myapp.settings"

[tasks.test]
run = "uv run pytest"

[tasks.check]
run = "uv run manage.py check"

[tasks.dev]
run = "uv run manage.py runserver"
```

Replace `myapp.settings` with your project's module and adjust the test command to its test runner. Run these with `mise run test`, `mise run check`, or `mise run dev` from that project.

## Dotfiles maintenance

Run Stow from `~/dotfiles`.

| Command | Action |
| --- | --- |
| `stow --no-folding mise` | Link the mise configuration. |
| `stow --no-folding zsh oh_my_zsh` | Link shell configuration and the custom theme. |
| `stow -n -v --no-folding mise` | Preview Stow operations without changing files. |
| `git diff` | Review configuration changes. |

If Stow reports a conflicting regular file, back up that specific file before retrying. `--adopt` moves the existing file into the repository and can replace its tracked configuration.
