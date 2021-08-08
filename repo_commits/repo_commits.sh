#!/usr/bin/env nix-shell
#!nix-shell --keep GITHUB_TOKEN --pure -i bash

set -euo pipefail

npx ts-node "$(dirname $(readlink -f "$0"))"/index.ts "$@"
