#!/bin/bash
function fzfalias() {
  local cmd height
  height=20
  cmd=$(alias |
	  sed 's/[^ ]* //' |
	  sed 's/=/?/' |
	  column -t -s? -N alias,command -T command -c $COLUMNS -d |
	  fzf --height=$height |
	  awk -F '[[:space:]][[:space:]]+' '{print $2}' |
	  sed "s/'//" |
	  sed "s/\(.*\)'/\1 /")
  echo $cmd
  $($cmd)
}

function __fzfcmd() {
  [ -n "$TMUX_PANE" ] && { [ "${FZF_TMUX:-0}" != 0 ] || [ -n "$FZF_TMUX_OPTS" ]; } &&
    echo "fzf-tmux ${FZF_TMUX_OPTS:--d${FZF_TMUX_HEIGHT:-40%}} -- " || echo "fzf"
}

__fzf_select_dir__() {
  local dirs len max height
  dirs="$(fd -t d)"
  len=$(echo -e "$dirs" | wc -l)
  max=$(( 4 * $COLUMNS / 10 ))
  # I wish this was working :'(
  # height=$(( [[ $len -lt $max ]] ? $(( $len + 4 )) : $max ))
  if [[ $len -lt $max ]]
  then
          height=$(( $len + 4 ))
  else
          height=$max
  fi
  echo -e "$dirs" | $(__fzfcmd) --height $height -m "$@" | while read -r item; do
    printf '%q ' "$item"
  done
  echo
}

__fzf-dir-widget() {
  local selected="$(__fzf_select_dir__)"
  READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}$selected${READLINE_LINE:$READLINE_POINT}"
  READLINE_POINT=$(( READLINE_POINT + ${#selected} ))
}

# CTRL-F - Paste the selected directory path into the command line
bind -m emacs-standard -x '"\C-f": __fzf-dir-widget'
bind -m vi-command -x '"\C-f": __fzf-dir-widget'
bind -m vi-insert -x '"\C-f": __fzf-dir-widget'
