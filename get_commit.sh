#!/usr/bin/env nix-shell
#!nix-shell --pure -p jq -i bash

set -eu
set -o pipefail
set -o errexit
set -o nounset

function get_commit() {
  local sources_json_path
  sources_json_path="$(dirname $(readlink -f "$0"))/nix/sources.json"
  jq \
    --exit-status \
    --raw-output \
    --compact-output \
    --monochrome-output \
    --arg dep "$1" \
    '.[$dep].rev // error("no niv-managed \"\($dep)\" dependency")' <"$sources_json_path"
}

get_commit "$@"
