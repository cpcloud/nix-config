#!/usr/bin/env nix-shell
#!nix-shell --keep GITHUB_TOKEN --pure -p coreutils -p jq -p curl -p cacert -i bash

set -euo pipefail

function auth_request() {
  set +u
  curl -LsS -H "Authorization: token $GITHUB_TOKEN" -H 'Accept: application/vnd.github.v3+json' "$@"
  set -u
}

function get_log_lines() {
  local owner_repo="$1"
  local begin="$2"
  local end="$3"

  local page=1
  local per_page=100

  local endpoint="https://api.github.com/repos/$owner_repo/compare/$begin...$end"

  local commits_remaining
  commits_remaining="$(auth_request "$endpoint" | jq -rcM '.ahead_by')"

  while true; do
    if ((commits_remaining == 0)); then
      break
    fi

    local resp
    resp="$(auth_request "${endpoint}?per_page=${per_page}&page=${page}")"

    local num_commits_on_page
    num_commits_on_page=$(jq -rcM '.commits | length' <<<"$resp")

    # skip merge commits
    local commits
    commits="$(jq 'del(.commits[] | select(.parents | length > 1)).commits' <<<"$resp")"

    local num_commits
    num_commits="$(jq length <<<"$commits")"

    local commit
    for commit in $(seq 0 $((num_commits - 1))); do
      local sha256
      sha256="$(jq -rcM '.[$commit].sha[:8]' --argjson commit "$commit" <<<"$commits")"

      local sha_url
      sha_url="$(jq -rcM '.[$commit].html_url' --argjson commit "$commit" <<<"$commits")"

      local commit_message
      commit_message="$(jq -rcM '.[$commit].commit.message | split("\n") | .[0]' --argjson commit "$commit" <<<"$commits")"

      local date
      date="$(jq -rcM '.[$commit].commit.committer.date' --argjson commit "$commit" <<<"$commits")"

      echo "- [\`$sha256\`]($sha_url) - \`$commit_message\` on \`$date\`"
    done
    ((commits_remaining -= num_commits_on_page))
    ((++page))
  done
}

get_log_lines "$@" | tac | jq -sRr "@uri"
