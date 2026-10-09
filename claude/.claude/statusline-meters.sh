#!/usr/bin/env bash
# Status line: 3 centered meters. Context, 5h usage + reset, weekly usage + reset.
input=$(cat)

ctx=$(jq -r '.context_window.used_percentage // empty' <<<"$input")
h5=$(jq -r '.rate_limits.five_hour.used_percentage // empty' <<<"$input")
h5r=$(jq -r '.rate_limits.five_hour.resets_at // empty' <<<"$input")
wk=$(jq -r '.rate_limits.seven_day.used_percentage // empty' <<<"$input")
wkr=$(jq -r '.rate_limits.seven_day.resets_at // empty' <<<"$input")

# colour by fill: green <60, yellow <85, red otherwise
color() {
  local p=${1%.*}
  if   [ "$p" -ge 85 ]; then printf '\033[31m'
  elif [ "$p" -ge 60 ]; then printf '\033[33m'
  else printf '\033[32m'; fi
}

bar() { # pct -> 10-cell bar
  local p=${1%.*} n i out=""
  n=$(( (p * 10 + 50) / 100 )); [ "$n" -gt 10 ] && n=10
  for ((i=0; i<10; i++)); do
    if [ "$i" -lt "$n" ]; then out+="█"; else out+="░"; fi
  done
  printf '%s' "$out"
}

# epoch -> "2h14m" / "3d4h"
until_reset() {
  [ -z "$1" ] && return
  local s=$(( ${1%.*} - $(date +%s) ))
  [ "$s" -lt 0 ] && s=0
  if [ "$s" -ge 86400 ]; then printf '%dd%dh' $((s/86400)) $((s%86400/3600))
  else printf '%dh%02dm' $((s/3600)) $((s%3600/60)); fi
}

meter() { # label pct reset
  local label=$1 pct=$2 reset=$3
  if [ -z "$pct" ]; then
    printf '\033[2m%s ░░░░░░░░░░ --\033[0m' "$label"; return
  fi
  printf '\033[2m%s\033[0m %s%s\033[0m %s%%' "$label" "$(color "$pct")" "$(bar "$pct")" "${pct%.*}"
  [ -n "$reset" ] && printf ' \033[2m↻%s\033[0m' "$reset"
}

line="$(meter ctx "$ctx" "")   $(meter 5h "$h5" "$(until_reset "$h5r")")   $(meter wk "$wk" "$(until_reset "$wkr")")"

# visible width: strip ANSI, count chars
plain=$(printf '%s' "$line" | sed $'s/\033\\[[0-9;]*m//g')
len=$(printf '%s' "$plain" | wc -m | tr -d ' ')

cols=${COLUMNS:-}
[ -z "$cols" ] && cols=$(stty size </dev/tty 2>/dev/null | awk '{print $2}')
[ -z "$cols" ] && cols=$(tput cols 2>/dev/null)
[ -z "$cols" ] && cols=100

pad=$(( (cols - len) / 2 )); [ "$pad" -lt 0 ] && pad=0
printf '%*s%s' "$pad" "" "$line"
