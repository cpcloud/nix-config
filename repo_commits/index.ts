import { parse } from "ts-command-line-args";
import * as process from "process";
import * as superagent from "superagent";

interface Params {
  page: number;
  ["per-page"]: number;
}

interface Request {
  endpoint: string;
  params: Params;
  token: string;
}

const authRequest = async (request: Request): Promise<any> => {
  const { page, ["per-page"]: perPage } = request.params;
  return (
    await superagent
      .get(request.endpoint)
      .query({ page, per_page: perPage })
      .accept("application/vnd.github.v3+json")
      .set("User-Agent", "node-superagent/6.1.0")
      .set("Authorization", `token ${request.token}`)
  ).body;
};

interface Args {
  owner: string;
  repo: string;
  begin: string;
  end: string;
  help?: boolean;
  ["per-page"]: number;
  ["no-translate"]: boolean;
  token: string;
  ["show-merge-commits"]: boolean;
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
      begin: {
        type: String,
        description: "Start of the commit range",
        alias: "b",
      },
      end: { type: String, description: "End of the commit range", alias: "e" },
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
            "Generate a Markdown table of changes for a given commit range",
        },
      ],
    }
  );

  let page = 1;

  const endpoint = `https://api.github.com/repos/${args.owner}/${args.repo}/compare/${args.begin}...${args.end}`;

  let commitsRemaining = (
    await authRequest({
      endpoint,
      params: { ["per-page"]: 0, page },
      token: args.token,
    })
  ).ahead_by;

  const header = ["SHA256", "Commit Message", "Timestamp"];
  const headerLine = `|${header.join("|")}|`;
  const headerSepLine = `|${new Array(header.length).fill("---").join("|")}|`;
  const headerLines = [headerLine, headerSepLine];

  let lines = [];

  while (commitsRemaining) {
    const resp = await authRequest({
      endpoint,
      params: { ["per-page"]: args["per-page"], page },
      token: args.token,
    });

    const commits = resp.commits;
    const numCommitsOnPage = commits.length;

    for (let commitData of commits.filter(
      (commit: any) => args["show-merge-commits"] || commit.parents.length < 2
    )) {
      const sha256 = commitData.sha.slice(0, 8);
      const shaUrl = commitData.html_url;
      const commit = commitData.commit;
      const commitMessage = commit.message.split("\n")[0];
      const date = commit.committer.date;

      const fields = [
        `[\`${sha256}\`](${shaUrl})`,
        `\`${commitMessage}\``,
        `\`${date.replace("T", " ")}\``,
      ];
      lines.push(`|${fields.join("|")}|`);
    }

    commitsRemaining -= numCommitsOnPage;
    ++page;
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
