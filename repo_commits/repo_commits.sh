#!/usr/bin/env nix-shell
#!nix-shell --keep GITHUB_TOKEN --pure -i bash

npx ts-node index.ts "$@"
