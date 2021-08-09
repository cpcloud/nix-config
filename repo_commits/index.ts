import { parse } from "ts-command-line-args";
import { Octokit } from "@octokit/rest";
import * as process from "process";

interface Args {
  owner: string;
  repo: string;
  basehead: string;
  ["per-page"]: number;
  ["no-translate"]: boolean;
  token: string;
  ["show-merge-commits"]: boolean;
  ["sha-length"]: number;
  help?: boolean;
}

const main = async (): Promise<void> => {
  const args = parse<Args>(
    {
      owner: {
        type: String,
        description: "The owner of the GitHub repository",
        alias: "o",
      },
      repo: {
        type: String,
        description: "The name of the GitHub repository",
        alias: "r",
      },
      basehead: {
        type: String,
        description: "Commit range",
        alias: "b",
      },
      ["per-page"]: {
        type: Number,
        defaultValue: 100,
        description: "The number of commits per GitHub API response",
        alias: "p",
      },
      ["no-translate"]: {
        type: Boolean,
        defaultValue: false,
        description:
          "Turn off translating characters for use in a pull request body",
        alias: "n",
      },
      token: {
        type: String,
        defaultValue: process.env.GITHUB_TOKEN,
        description: "GitHub authentication token",
        alias: "t",
      },
      ["show-merge-commits"]: {
        type: Boolean,
        defaultValue: false,
        alias: "m",
        description: "Show merge commits when passed",
      },
      ["sha-length"]: {
        type: Number,
        defaultValue: 8,
        alias: "s",
        description: "The length of the commit hash to show",
      },
      help: {
        type: Boolean,
        optional: true,
        alias: "h",
        description: "Print this usage guide",
      },
    },
    {
      helpArg: "help",
      headerContentSections: [
        {
          header: "repo_commits",
          content:
            "Generate a Markdown table of changes for a given owner, repo and commit range",
        },
      ],
    }
  );

  const octokit = new Octokit({
    auth: args.token,
  });

  const { owner, repo, basehead } = args;

  const header = ["SHA256", "Commit Message", "Timestamp"];
  const headerLine = `|${header.join("|")}|`;
  const headerSepLine = `|${new Array(header.length).fill("---").join("|")}|`;
  const headerLines = [headerLine, headerSepLine];
  const shaLength = args["sha-length"];
  const showMergeCommits = args["show-merge-commits"];

  const lines = [];

  for await (const {
    data: { commits },
  } of octokit.paginate.iterator(
    octokit.rest.repos.compareCommitsWithBasehead, // eslint-disable-line indent
    { owner, repo, basehead } // eslint-disable-line indent
  )) /* eslint-disable-line indent */ {
    for (const {
      sha,
      html_url: shaUrl,
      commit: { message, committer },
    } of commits.filter(c => showMergeCommits || c.parents.length < 2)) {
      const sha256 = sha.slice(0, shaLength);
      const commitMessage = message.split("\n")[0];
      const date = committer?.date ?? "unknown";

      const fields = [
        `[\`${sha256}\`](${shaUrl})`,
        `\`${commitMessage}\``,
        `\`${date.replace("T", " ")}\``,
      ];
      lines.push(`|${fields.join("|")}|`);
    }
  }

  const joinedResult = headerLines.concat(lines.reverse()).join("\n");

  if (args["no-translate"]) {
    console.log(joinedResult);
  } else {
    console.log(
      joinedResult
        .replace(/%/g, "%25")
        .replace(/\r/g, "%0D")
        .replace(/\n/g, "%0A")
    );
  }
};

main().catch(err => {
  throw err;
});
