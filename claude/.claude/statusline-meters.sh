#!/usr/bin/env bash
# Status line matching the Pi usage footer (pi/.pi/agent/extensions/usage-footer.ts).
# Left: cwd. Center: Context, Current (5h) and Weekly used %. Right: git branch + status, model + effort.
# All meters show USED capacity, not remaining capacity.
export LC_ALL=en_US.UTF-8
input=$(cat)

j() { jq -r "$1 // empty" <<<"$input"; }
model=$(j '.model.id')
effort=$(j '.effort.level')
dir=$(j '.workspace.current_dir'); [ -z "$dir" ] && dir=$(j '.cwd')
ctx=$(j '.context_window.used_percentage')
h5=$(j '.rate_limits.five_hour.used_percentage')
h5r=$(j '.rate_limits.five_hour.resets_at')
wk=$(j '.rate_limits.seven_day.used_percentage')
wkr=$(j '.rate_limits.seven_day.resets_at')

# Pi theme colours mapped to ANSI.
R=$'\033[0m'
fg() { # role text
  local c
  case $1 in
    muted) c='38;5;250' ;; dim) c='38;5;245' ;; text) c=39 ;; accent) c=36 ;;
    success) c=32 ;; warning) c=33 ;; error) c=31 ;;
    thinkingMinimal) c='38;5;245' ;; thinkingLow) c=34 ;; thinkingMedium) c=36 ;;
    thinkingHigh) c=35 ;; thinkingXhigh) c=95 ;; thinkingMax) c=91 ;;
    *) c=39 ;;
  esac
  printf '\033[%sm%s%s' "$c" "$2" "$R"
}

# Visible width and ANSI-aware truncation with an ellipsis.
width() { perl -CSA -e '(my $s = $ARGV[0]) =~ s/\e\[[0-9;]*m//g; print length $s' -- "$1"; }
truncate() { # text budget
  perl -CSA -e '
    my ($s, $w) = @ARGV; (my $p = $s) =~ s/\e\[[0-9;]*m//g;
    if (length $p <= $w) { print $s; exit }
    exit if $w <= 0;
    my ($out, $n) = ("", 0);
    while ($s =~ /\G(\e\[[0-9;]*m|.)/gs) {
      my $t = $1;
      if ($t =~ /^\e/) { $out .= $t; next }
      last if $n >= $w - 1;
      $out .= $t; $n++;
    }
    print "$out\x{2026}\e[0m";' -- "$1" "$2"
}

usage_text() { # label pct
  local label=$1 pct=$2 color
  if [ -z "$pct" ]; then printf '%s %s' "$(fg muted "$label")" "$(fg dim n/a)"; return; fi
  pct=$(printf '%.0f' "$pct")
  if [ "$pct" -ge 90 ]; then color=error; elif [ "$pct" -ge 70 ]; then color=warning; else color=success; fi
  printf '%s %s' "$(fg muted "$label")" "$(fg $color "$pct%")"
}

reset_text() { # epoch seconds
  local m d h
  m=$(( (${1%.*} - $(date +%s) + 59) / 60 )); [ "$m" -lt 0 ] && m=0
  d=$((m / 1440)); h=$((m % 1440 / 60))
  if [ "$m" -eq 0 ]; then printf 'reset due'
  elif [ "$d" -gt 0 ]; then printf '↻ %dd %dh' "$d" "$h"
  elif [ "$h" -gt 0 ]; then printf '↻ %dh %dm' "$h" $((m % 60))
  else printf '↻ %dm' "$m"; fi
}

usage_row() { # with_resets
  local out
  out="$(usage_text Context "$ctx")   $(usage_text 'Current (5h)' "$h5")"
  [ "$1" = 1 ] && [ -n "$h5" ] && [ -n "$h5r" ] && out+=" $(fg dim "$(reset_text "$h5r")")"
  out+="   $(usage_text Weekly "$wk")"
  [ "$1" = 1 ] && [ -n "$wk" ] && [ -n "$wkr" ] && out+=" $(fg dim "$(reset_text "$wkr")")"
  printf '%s' "$out"
}

# Git branch, status and ahead/behind.
branch="" dirty=0 conflicted=0 ahead=0 behind=0 oid=""
if [ -n "$dir" ] && status=$(git -C "$dir" --no-optional-locks status --porcelain=v2 --branch \
    --untracked-files=normal --ignore-submodules 2>/dev/null); then
  while IFS= read -r line; do
    case $line in
      '# branch.head '*) branch=${line#\# branch.head } ;;
      '# branch.oid '*) oid=${line#\# branch.oid } ;;
      '# branch.ab '*) read -r _ _ a b <<<"$line"; ahead=${a#+}; behind=${b#-} ;;
      '# '*|'') ;;
      u\ *) dirty=1; conflicted=1 ;;
      *) dirty=1 ;;
    esac
  done <<<"$status"
  [ "$branch" = "(detached)" ] && branch="@${oid:0:7}"
fi
branch_text=""
if [ -n "$branch" ]; then
  if [ "$conflicted" = 1 ]; then gs=$(fg error '!')
  elif [ "$dirty" = 1 ]; then gs=$(fg warning '±')
  else gs=$(fg success '✓'); fi
  branch_text="$(fg text "$branch") $gs"
  [ "$ahead" -gt 0 ] && branch_text+=$(fg accent " ↑$ahead")
  [ "$behind" -gt 0 ] && branch_text+=$(fg accent " ↓$behind")
fi

# Model coloured by family, effort by level.
case $model in
  *opus*) mc=thinkingHigh ;; *sonnet*) mc=warning ;; *haiku*) mc=success ;; *) mc=thinkingMedium ;;
esac
case $effort in
  off) ec=dim ;; minimal) ec=thinkingMinimal ;; low) ec=thinkingLow ;; medium) ec=thinkingMedium ;;
  high) ec=thinkingHigh ;; xhigh) ec=thinkingXhigh ;; max) ec=thinkingMax ;; *) ec=accent ;;
esac
identity=$(fg $mc "${model:-no-model}")
[ -n "$effort" ] && identity+="  $(fg $ec "$effort")"

cwd=${dir/#$HOME/\~}

cols=${COLUMNS:-}
[ -z "$cols" ] && cols=$(stty size </dev/tty 2>/dev/null | awk '{print $2}')
[ -z "$cols" ] && cols=$(tput cols 2>/dev/null)
[ -z "$cols" ] && cols=100
# Claude Code indents the status line and truncates anything past the edge.
cols=$((cols - 4))

# Layout: reserve equal space beside usage so its center is the terminal's center.
right_text=$identity
[ -n "$branch_text" ] && right_text="$branch_text  $identity"
cwd_w=$(width "$cwd"); right_w=$(width "$right_text")
side=$(( cwd_w < 12 ? cwd_w : 12 )); [ "$right_w" -gt "$side" ] && side=$right_w
budget=$(( cols - 2 * (side + 2) )); [ "$budget" -lt $((cols / 3)) ] && budget=$((cols / 3))
row=$(usage_row 1)
[ "$(width "$row")" -gt "$budget" ] && row=$(truncate "$(usage_row 0)" "$budget")
row_w=$(width "$row")
start=$(( (cols - row_w) / 2 )); [ "$start" -lt 0 ] && start=0
end=$(( start + row_w ))
left_budget=$(( start - 2 )); [ "$left_budget" -lt 0 ] && left_budget=0
left=$(fg muted "$(truncate "$cwd" "$left_budget")")
right_budget=$(( cols - end - 2 )); [ "$right_budget" -lt 0 ] && right_budget=0
right=$(truncate "$right_text" "$right_budget")
gap_l=$(( start - $(width "$left") )); [ "$gap_l" -lt 0 ] && gap_l=0
gap_r=$(( cols - end - $(width "$right") )); [ "$gap_r" -lt 0 ] && gap_r=0
printf '%s%*s%s%*s%s' "$left" "$gap_l" "" "$row" "$gap_r" "" "$right"
