#!/bin/bash
function fzfalias() {
  local cmd height
  height=20
  cmd=$(alias |
	  sed 's/[^ ]* //' |
	  sed 's/=/?/' |
	  column -t -s? -N alias,command -T command -c $COLUMNS -d |
	  fzf --reverse --border=rounded --height=$height --info=hidden|
	  awk -F '[[:space:]][[:space:]]+' '{print $2}' |
	  sed "s/'//" |
	  sed "s/\(.*\)'/\1 /")
  echo $cmd
  $($cmd)
}
