import got from "got";
import { getOctokit } from "@actions/github";
import { config } from "../../config";
import { Logger } from "../../logger";

const logger = new Logger("actions:update-changelogs");

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

    const commits = {
        feat: [] as string[],
        fix: [] as string[],
        refactor: [] as string[],
        perf: [] as string[],
    };

    for (const x of diff.data.commits) {
        const match =
            /^(feat|fix|perf|refactor){1}(\(([\w-\.]+)\))?(!)?: (.*)/.exec(
                x.commit.message
            );

        if (match) {
            const chunks = [`[\`${x.sha.slice(0, 6)}\`](${x.html_url})`];
            if (match[3]) {
                chunks.push(`**${match[3]}**:`);
            }
            chunks.push(match[5]);
            const msg = chunks.join(" ");

            const key = match[1] as keyof typeof commits;
            if (!commits[key].includes(msg)) {
                commits[key].push(msg);
            }
        }
    }

    const changelogs = [`## Changelogs\n`];
    for (const [k, v] of Object.entries(commits)) {
        if (v.length) {
            let head: string;

            switch (k as keyof typeof commits) {
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

            changelogs.push(
                `- ${head}\n`,
                commits.feat.map((x) => `   - ${x}`).join("\n")
            );
        }
    }

    const links = [
        "## Links\n",
        `   - Download: ${config.url}/download/${latest.tag_name}/`,
        `   - Release: ${latest.html_url}/`,
    ].join("\n");
    const notes = changelogs.join("\n");

    let body = latest.body || "";
    const bodyRegex = /(## Links[\s\S]+)/;
    const bodyContent = `${links}\n${notes}`;

    if (bodyRegex.test(body)) {
        body = body.replace(bodyRegex, bodyContent);
    } else {
        body += `\n${bodyContent}`;
    }

    await github.request("POST /repos/{owner}/{repo}/releases/{release_id}", {
        ...repo,
        release_id: latest.id,
        body,
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
                    description: links,
                    timestamp: new Date().toISOString(),
                },
            ],
        }),
    });

    logger.log("Posted webhook");
};
