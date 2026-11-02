#!/usr/bin/env bash
# PreToolUse hook: block Write/Edit/Bash (git commit, gh pr) that ADDS an em dash.
# Existing em dashes in a file are allowed; only new ones are blocked.
set -u
export LC_ALL=C
DASH=$(printf '\xe2\x80\x94')
input=$(cat)
tool=$(jq -r '.tool_name // empty' <<<"$input")
count() { grep -o "$DASH" | wc -l | tr -d ' '; }

case "$tool" in
  Write)
    file=$(jq -r '.tool_input.file_path // empty' <<<"$input")
    new=$(jq -r '.tool_input.content // empty' <<<"$input" | count)
    old=0; [ -f "$file" ] && old=$(count < "$file")
    ;;
  Edit)
    new=$(jq -r '.tool_input.new_string // empty' <<<"$input" | count)
    old=$(jq -r '.tool_input.old_string // empty' <<<"$input" | count)
    ;;
  Bash)
    cmd=$(jq -r '.tool_input.command // empty' <<<"$input")
    if grep -Eq 'git[[:space:]]+commit|gh[[:space:]]+pr' <<<"$cmd"; then
      new=$(count <<<"$cmd"); old=0
    else
      exit 0
    fi
    ;;
  *) exit 0 ;;
esac

if [ "$new" -gt "$old" ]; then
  echo "Blocked: this adds an em dash. User rule: never use em dash. Use a plain dash (-) or rephrase, then retry." >&2
  exit 2
fi
exit 0
