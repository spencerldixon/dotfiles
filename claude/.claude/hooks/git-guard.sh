#!/usr/bin/env bash
# PreToolUse hook on Bash: enforce git safety rules from the ship-it skill.
# Blocks: force push, --no-verify (and commit -n), git add -A/--all/., staging secrets.
set -u
cmd=$(jq -r '.tool_input.command // empty')
[ -z "$cmd" ] && exit 0
orig=$cmd
# Drop quoted strings (commit messages etc.) so flags inside them do not match
cmd=$(sed -E "s/'[^']*'/Q/g; s/\"[^\"]*\"/Q/g" <<<"$cmd")
S='[[:space:]]'
E='([[:space:]]|$)'
NOT_SEP='[^;&|]*'   # stay within one command of a chain like "a && b"

block() { echo "Blocked by git-guard: $1" >&2; exit 2; }

grep -Eq "git${S}+push${NOT_SEP}${S}(--force|--force-with-lease|-[a-zA-Z]*f[a-zA-Z]*)(=|${E})" <<<"$cmd" \
  && block "force push is never allowed. If the push is rejected, stop and report."
grep -Eq "git${S}+push${NOT_SEP}${S}\+[^[:space:]]+" <<<"$cmd" \
  && block "'+refspec' is a force push. Stop and report instead."
grep -Eq "git${S}+[a-z-]+${NOT_SEP}${S}--no-verify${E}" <<<"$cmd" \
  && block "--no-verify is never allowed. Fix the failing git hook, or stop and report."
grep -Eq "git${S}+commit${NOT_SEP}${S}-[a-zA-Z]*n[a-zA-Z]*${E}" <<<"$cmd" \
  && block "'git commit -n' skips git hooks (same as --no-verify). Not allowed."
grep -Eq "git${S}+add${NOT_SEP}${S}(-A|--all|\.|\./|:/)${E}" <<<"$cmd" \
  && block "do not stage everything. Stage the files that belong to this work by name."

# Secrets and local-only files passed to git add
if grep -Eq "git${S}+add${S}" <<<"$cmd"; then
  addpart=$(tr -d "\"'" <<<"$orig" | grep -Eo "git${S}+add${S}${NOT_SEP}")
  for tok in $addpart; do
    base=${tok##*/}
    case "$base" in
      .env.example|.env.sample|.env.template) ;;
      .env|.env.*|*.pem|*.key|*.p12|*.pfx|id_rsa*|id_ed25519*|credentials*|*.log|master.key)
        block "'$tok' looks like a secret or local-only file. Never stage it." ;;
    esac
  done
fi
exit 0
