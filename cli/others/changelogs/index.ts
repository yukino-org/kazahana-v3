import { join } from "path";
import { ensureDir, writeFile } from "fs-extra";
import got from "got";
import { getOctokit } from "@actions/github";
import { Endpoints } from "@octokit/types";
import { config } from "../../config";
import { Logger } from "../../logger";
import { capitalizeString } from "../../utils";

const logger = new Logger("actions:update-changelogs");

type GitHubRelease =
    Endpoints["GET /repos/{owner}/{repo}/releases/latest"]["response"]["data"];
type GitHubRefCompare =
    Endpoints["GET /repos/{owner}/{repo}/compare/{base}...{head}"]["response"]["data"];

class CommitMessage {
    constructor(
        public readonly commit: {
            type: "feat" | "refactor" | "fix" | "perf";
            cat?: string;
            msg: string;
            stats: {
                additions: number;
                deletions: number;
            };
            sha: string;
            url: string;
        }
    ) {}

    isSame(other: CommitMessage) {
        return (
            this.commit.type === other.commit.type &&
            this.commit.cat === other.commit.cat &&
            this.commit.msg === other.commit.msg
        );
    }

    toString() {
        const chunks = [
            `[\`${this.commit.sha.slice(0, 6)}\`](${this.commit.url})`,
        ];
        if (this.commit.cat) {
            chunks.push(`**${this.commit.cat}**:`);
        }
        chunks.push(capitalizeString(this.commit.msg));
        if (this.commit.stats.additions || this.commit.stats.deletions) {
            chunks.push(
                `(+${this.commit.stats.additions} -${this.commit.stats.deletions})`
            );
        }

        return chunks.join(" ");
    }
}

type Commits = {
    [k in CommitMessage["commit"]["type"]]: CommitMessage[];
};

class Changelogs {
    commits: Commits = {
        feat: [],
        refactor: [],
        fix: [],
        perf: [],
    };

    constructor(
        public readonly release: GitHubRelease,
        public readonly diff: GitHubRefCompare
    ) {
        for (const x of this.diff.commits) {
            const match =
                /^(feat|fix|perf|refactor){1}(\(([\w-\.]+)\))?(!)?: (.*)/.exec(
                    x.commit.message
                );

            if (match) {
                const msg = new CommitMessage({
                    type: match[1] as keyof Commits,
                    cat: match[3]
                        ? capitalizeString(
                              match[3].replace(/_[a-z]/g, (str) =>
                                  str.slice(1).toUpperCase()
                              )
                          )
                        : undefined,
                    msg: capitalizeString(match[5]),
                    sha: x.sha.slice(0, 6),
                    url: x.html_url,
                    stats: {
                        additions: x.stats?.additions ?? 0,
                        deletions: x.stats?.deletions ?? 0,
                    },
                });

                if (!this.commits[msg.commit.type].some((x) => x.isSame(msg))) {
                    this.commits[msg.commit.type].push(msg);
                }
            }
        }
    }

    getDiscordMessageBody() {
        return `**Download**: ${this.downloadURL}\n**Release**: ${this.release.html_url}`;
    }

    getGithubReleaseBody(body: string) {
        const bodyRegex = /(<!-- generated -->[\s\S]+)/;
        const bodyContent = `<!-- generated -->\n${this.getLinks()}\n\n${this.getChangelogs()}`;

        if (bodyRegex.test(body)) {
            body = body.replace(bodyRegex, bodyContent);
        } else {
            body += `\n${bodyContent}`;
        }

        return body;
    }

    getLinks() {
        return `## Links\n  - Download: ${this.downloadURL}\n   - Release: ${this.release.html_url}`;
    }

    getChangelogs() {
        const logs = [`## Changelogs\n`];

        for (const [k, v] of Object.entries(this.commits) as [
            keyof Commits,
            CommitMessage[]
        ][]) {
            if (v.length) {
                let head: string;

                switch (k) {
                    case "feat":
                        head = "✨ Features";
                        break;

                    case "fix":
                        head = "🐛 Bug fixes";
                        break;

                    case "refactor":
                        head = "♻️ Changes";
                        break;

                    case "perf":
                        head = "⚡️ Performance";
                        break;
                }

                logs.push(
                    `<!-- {${k}} -->`,
                    `- ${head}`,
                    this.commits[k].map((x) => `   - ${x}`).join("\n"),
                    `<!-- {/${k}} -->`
                );
            }
        }

        return logs.join("\n");
    }

    get downloadURL() {
        return `${config.url}/download/${this.release.tag_name}`;
    }
}

const repo = { owner: config.github.username, repo: config.github.repo };

export const updateChangelogs = async (
    githubToken: string,
    discordWebhookURL: string
) => {
    logger.log("Generating changelogs");

    const github = getOctokit(githubToken, {});

    const {
        data: [latest, previous],
    } = await github.request("GET /repos/{owner}/{repo}/releases", {
        ...repo,
        per_page: 2,
    });

    const { data: diff } = await github.request(
        "GET /repos/{owner}/{repo}/compare/{base}...{head}",
        {
            ...repo,
            base: previous.tag_name,
            head: latest.tag_name,
        }
    );

    const changelogs = new Changelogs(latest, diff);

    await github.request("POST /repos/{owner}/{repo}/releases/{release_id}", {
        ...repo,
        release_id: latest.id,
        body: changelogs.getGithubReleaseBody(latest.body ?? ""),
    });
    logger.log("Updated release");

    await got.post(discordWebhookURL, {
        headers: {
            "Content-Type": "application/json",
        },
        body: JSON.stringify({
            username: "Yukino - Releases",
            avatar_url: `https://github.com/${config.github.username}/${config.github.repo}/blob/next/assets/images/yukino-icon.png?raw=true`,
            embeds: [
                {
                    title: `${latest.name}${
                        latest.name != latest.tag_name
                            ? ` (${latest.tag_name})`
                            : ""
                    }`,
                    url: latest.html_url,
                    color: 6514417,
                    description: changelogs.getDiscordMessageBody(),
                    timestamp: new Date().toISOString(),
                },
            ],
        }),
    });
    logger.log("Posted webhook");
};
