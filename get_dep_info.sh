#!/usr/bin/env nix-shell
#!nix-shell --pure -p jq -i bash

set -eu
set -o pipefail
set -o errexit
set -o nounset

jq \
  --exit-status \
  --raw-output \
  --monochrome-output \
  --compact-output \
  --arg dep "$1" \
  --arg prop "$2" \
  '(.[$dep] // error("invalid dependency \"\($dep)\""))[$prop] // error("invalid property \"\($prop)\" of dependency \"\($dep)\"")' \
  <"$(dirname "$(readlink -f "$0")")/nix/sources.json"
