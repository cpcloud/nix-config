#!/usr/bin/env nix-shell
#!nix-shell ./python-env.nix --pure --keep GITHUB_TOKEN -i python3

import itertools
import os
from typing import Any, Mapping, Optional

import requests


def auth_request(
    endpoint: str, params: Optional[Mapping[str, int]] = None
) -> Mapping[str, Any]:
    token = os.environ.get("GITHUB_TOKEN")
    return requests.get(
        endpoint,
        headers={
            "Accept": "application/vnd.github.v3+json",
            "Authorization": f"token {token}",
        },
        params=params,
    ).json()


CREATE_PULL_REQUEST_TRANSLATION_TABLE = {
    ord("%"): "%25",
    ord("\r"): "%0D",
    ord("\n"): "%0A",
}


def main(
    *,
    owner_repo: str,
    begin: str,
    end: str,
    per_page: int,
    translate: bool,
) -> None:
    page = 1
    endpoint = f"https://api.github.com/repos/{owner_repo}/compare/{begin}...{end}"
    commits_remaining = auth_request(endpoint, params={"per_page": 0})["ahead_by"]

    header = ["SHA256", "Commit Message", "Timestamp"]
    header_line = f"|{'|'.join(header)}|"
    header_sep = f"|{'|'.join(['---'] * len(header))}|"

    header_lines = [header_line, header_sep]

    lines = []

    while commits_remaining:
        resp = auth_request(endpoint, params={"per_page": per_page, "page": page})

        commits = resp["commits"]
        num_commits_on_page = len(commits)

        # skip merge commits
        for commit_data in (commit for commit in commits if len(commit["parents"]) < 2):
            sha256 = commit_data["sha"][:8]
            sha_url = commit_data["html_url"]

            commit = commit_data["commit"]
            commit_message = commit["message"].splitlines()[0]
            date = commit["committer"]["date"]

            fields = f"[`{sha256}`]({sha_url})", f"`{commit_message}`", f"`{date}`"
            lines.append(f"|{'|'.join(fields)}|")

        commits_remaining -= num_commits_on_page
        page += 1

    joined_result = "\n".join(itertools.chain(header_lines, reversed(lines)))

    print(
        joined_result.translate(CREATE_PULL_REQUEST_TRANSLATION_TABLE)
        if translate
        else joined_result
    )


if __name__ == "__main__":
    import argparse

    p = argparse.ArgumentParser(
        description="Generate a Markdown table of changes in a commit range"
    )

    p.add_argument("owner_repo", type=str, help="The owner of the GitHub repository")
    p.add_argument("begin", type=str, help="Start of the commit range")
    p.add_argument("end", type=str, help="End of the commit range")
    p.add_argument(
        "-p",
        "--per-page",
        type=int,
        default=100,
        help="The number of commits per GitHub API response",
    )
    p.add_argument(
        "-n",
        "--no-translate",
        action="store_false",
        help="Whether to translate characters for use in creating a pull request",
    )

    args = p.parse_args()

    main(
        owner_repo=args.owner_repo,
        begin=args.begin,
        end=args.end,
        per_page=args.per_page,
        translate=args.no_translate,
    )
