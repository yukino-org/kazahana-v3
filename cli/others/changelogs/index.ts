import got from "got";
import { getOctokit } from "@actions/github";
import { config } from "../../config";
import { Logger } from "../../logger";
import { capitalizeString } from "../../utils";

const logger = new Logger("actions:update-changelogs");

interface Commits {
    feat: string[];
    refactor: string[];
    fix: string[];
    perf: string[];
}

class Changelogs {
    commits: Commits = {
        feat: [],
        refactor: [],
        fix: [],
        perf: [],
    };

    constructor(
        public readonly downloadURL: string,
        public readonly releaseURL: string
    ) {}

    getDiscordMessageBody() {
        return `**Download**: ${this.downloadURL}\n**Release**: ${this.releaseURL}`;
    }

    getGithubReleaseBody(body: string) {
        const bodyRegex = /(## Links[\s\S]+)/;
        const bodyContent = `${this.getLinks()}\n\n${this.getChangelogs()}`;

        if (bodyRegex.test(body)) {
            body = body.replace(bodyRegex, bodyContent);
        } else {
            body += `\n${bodyContent}`;
        }
    }

    getLinks() {
        return `## Links\n  - Download: ${this.downloadURL}\n   - Release: ${this.releaseURL}`;
    }

    getChangelogs() {
        const logs = [`## Changelogs\n`];

        for (const [k, v] of Object.entries(this.commits) as [
            keyof Commits,
            string[]
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
                    `- ${head}\n`,
                    this.commits[k].map((x) => `   - ${x}`).join("\n")
                );
            }
        }

        return logs.join("\n");
    }
}

export const updateChangelogs = async (
    githubToken: string,
    discordWebhookURL: string
) => {
    logger.log("Generating changelogs");

    const github = getOctokit(githubToken, {});
    const repo = { owner: config.github.username, repo: config.github.repo };

    const res = await github.request("GET /repos/{owner}/{repo}/releases", {
        ...repo,
        per_page: 2,
    });

    const [previous, latest] = res.data.sort(
        (a, b) =>
            new Date(a.created_at).getTime() - new Date(b.created_at).getTime()
    );

    const diff = await github.request(
        "GET /repos/{owner}/{repo}/compare/{base}...{head}",
        {
            ...repo,
            base: previous.tag_name,
            head: latest.tag_name,
        }
    );

    const changelogs = new Changelogs(
        `${config.url}/download/${latest.tag_name}`,
        latest.html_url
    );

    for (const x of diff.data.commits) {
        const match =
            /^(feat|fix|perf|refactor){1}(\(([\w-\.]+)\))?(!)?: (.*)/.exec(
                x.commit.message
            );

        if (match) {
            const chunks = [`[\`${x.sha.slice(0, 6)}\`](${x.html_url})`];
            if (match[3]) {
                chunks.push(
                    `**${capitalizeString(
                        match[3].replace(/_[a-z]/, (str) =>
                            str.slice(1).toUpperCase()
                        )
                    )}**:`
                );
            }
            chunks.push(capitalizeString(match[5]));
            if (x.stats?.additions || x.stats?.deletions) {
                chunks.push(
                    `+${x.stats.additions || 0} -${x.stats.deletions || 0}`
                );
            }

            const msg = chunks.join(" ");
            const key = match[1] as keyof Commits;
            if (!changelogs.commits[key].includes(msg)) {
                changelogs.commits[key].push(msg);
            }
        }
    }

    await github.request("POST /repos/{owner}/{repo}/releases/{release_id}", {
        ...repo,
        release_id: latest.id,
        body: changelogs.getGithubReleaseBody(latest.body || ""),
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
