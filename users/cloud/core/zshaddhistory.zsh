#!/usr/bin/env zsh
#
zmodload zsh/pcre

pcre_compile -im "$HISTORY_EXCLUDE_PATTERN"
pcre_study

function zshaddhistory() {
  emulate -L zsh

  local input="${1%%$'\n'}"

  if ! pcre_match -b -- "$input"; then
    print -Sr -- "$input"
  else
    pcre_match -b -- "$input"
    while [[ $? -eq 0 ]]; do
      local b=($=ZPCRE_OP)
      local n="${MATCH##[\"\']}"
      input="${input/${n%%[\"\']}/…}"
      pcre_match -b -n "${b[2]}" -- "$input"
    done
    print -Sr -- "$input"
    unset MATCH
    return 1
  fi
}
