#!/usr/bin/env nix-shell
#!nix-shell ./python-env.nix --pure --keep GITHUB_TOKEN -i python3

import os
from typing import Any, Mapping

import click
import requests


def auth_request(endpoint: str, params=None) -> Mapping[str, Any]:
    token = os.environ.get("GITHUB_TOKEN")
    return requests.get(
        endpoint,
        params=params,
        headers={
            "Accept": "application/vnd.github.v3+json",
            "Authorization": f"token {token}",
        },
    ).json()


@click.command()
@click.argument("owner_repo")
@click.argument("begin")
@click.argument("end")
@click.option("-p", "--per-page", type=int, default=100)
@click.option("--translate/--no-translate", default=True)
def main(owner_repo: str, begin: str, end: str, per_page: int, translate: bool) -> None:
    page = 1
    per_page = 100
    endpoint = f"https://api.github.com/repos/{owner_repo}/compare/{begin}...{end}"
    commits_remaining = auth_request(endpoint)["ahead_by"]

    header = ["sha", "message", "date"]
    header_line = f"|{'|'.join(header)}|"
    header_sep = f"|{'|'.join(['---'] * len(header))}|"

    lines = [header_line, header_sep]

    while commits_remaining:
        resp = auth_request(endpoint, params={"per_page": per_page, "page": page})

        num_commits_on_page = len(resp["commits"])

        # skip merge commits
        commits = [commit for commit in resp["commits"] if len(commit["parents"]) < 2]

        for commit in commits:
            sha256 = commit["sha"][:8]
            sha_url = commit["html_url"]
            commit_message = commit["commit"]["message"].splitlines()[0]
            date = commit["commit"]["committer"]["date"]

            fields = f"[`{sha256}`]({sha_url})", f"`{commit_message}`", f"`{date}`"
            lines.append(f"|{'|'.join(fields)}|")

        commits_remaining -= num_commits_on_page
        page += 1

    joined_result = "\n".join(lines)
    click.echo(
        joined_result.translate({ord("%"): "%25", ord("\r"): "%0D", ord("\n"): "%0A"})
        if translate
        else joined_result
    )


if __name__ == "__main__":
    main()
