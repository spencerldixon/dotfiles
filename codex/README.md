# Codex status bar

Merge `statusline.toml` into `~/.codex/config.toml`, keeping any existing
settings in its `[tui]` table. Restart Codex to load the change, or use
`/statusline` to select and reorder the fields interactively.

The three native indicators show context used, current (five-hour) allowance
remaining, and weekly allowance remaining. Account limits appear when available.
Unlike the Claude and Pi examples, Codex CLI 0.162.0 does not offer custom
graphical meters or reset-time status fields. Use `/status` to see reset times.

This is a configuration snippet, not a Stow package: keep account-specific
settings and project trust entries in your local Codex configuration.

See the [configuration reference](https://learn.chatgpt.com/docs/config-file/config-reference)
and [status-line command](https://learn.chatgpt.com/docs/developer-commands?surface=cli#configure-footer-items-with-statusline).
