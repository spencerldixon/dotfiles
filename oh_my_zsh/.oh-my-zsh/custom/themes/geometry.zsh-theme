# Minimal Geometry with SSH and AWS context only when explicitly active.
# Read Git once per prompt; avoid history walks and optional index writes.
_geometry_precmd() {
  local git_status line branch oid ahead=0 behind=0 dirty=0 conflicted=0
  local elapsed=0
  local aws_profile=${AWS_PROFILE:-${AWS_DEFAULT_PROFILE:-}}
  typeset -g _geometry_git='' _geometry_duration='' _geometry_ssh='' _geometry_aws=''

  [[ -n ${SSH_CONNECTION:-}${SSH_CLIENT:-}${SSH_TTY:-} ]] && \
    _geometry_ssh='%F{242}%m:%f'
  [[ -n "$aws_profile" ]] && \
    _geometry_aws="%F{242}aws:${aws_profile//\%/%%}%f"

  if (( ${+_geometry_started} )); then
    elapsed=$(( SECONDS - _geometry_started ))
    unset _geometry_started
    (( elapsed >= 3 )) && _geometry_duration=" %F{242}${elapsed}s%f"
  fi

  git_status=$(GIT_OPTIONAL_LOCKS=0 command git status --porcelain=v2 --branch \
    --untracked-files=normal --ignore-submodules 2>/dev/null) || return 0

  for line in "${(@f)git_status}"; do
    case "$line" in
      '# branch.head '*) branch=${line#\# branch.head } ;;
      '# branch.oid '*) oid=${line#\# branch.oid } ;;
      '# branch.ab '*)
        ahead=${${line#\# branch.ab +}%% *}
        behind=${line##* -}
        ;;
      '# '*) ;;
      'u '*) dirty=1; conflicted=1 ;;
      *) dirty=1 ;;
    esac
  done

  [[ "$branch" == '(detached)' ]] && branch="@${oid[1,7]}"
  [[ -n "$branch" ]] || return 0
  # Branch names may contain prompt escapes. Keep them literal.
  _geometry_git="%F{white}${branch//\%/%%}%f"
  if (( conflicted )); then
    _geometry_git+=' %F{red}!%f'
  elif (( dirty )); then
    _geometry_git+=' %F{yellow}±%f'
  else
    _geometry_git+=' %F{green}✓%f'
  fi
  (( ahead )) && _geometry_git+=" %F{cyan}↑${ahead}%f"
  (( behind )) && _geometry_git+=" %F{cyan}↓${behind}%f"
  return 0
}

_geometry_preexec() {
  typeset -g _geometry_started=$SECONDS
}

autoload -Uz add-zsh-hook
# Remove the previous theme's hooks when reloading an existing shell.
add-zsh-hook -d preexec _set_cmd_title
add-zsh-hook -d precmd _set_title
add-zsh-hook precmd _geometry_precmd
add-zsh-hook preexec _geometry_preexec

setopt prompt_subst
PROMPT=$'\n%F{white}▲ %f${_geometry_ssh}%F{white}%B%~%b%f${_geometry_duration}\n%(?.%F{green}.%F{red})▷%f '
PROMPT2='%F{white}◇%f '
RPROMPT='${_geometry_git}${_geometry_git:+${_geometry_aws:+ }}${_geometry_aws}'
