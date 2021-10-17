import got from "got";
import { getOctokit } from "@actions/github";
import { getChanges } from "./get-changes";
import { config } from "../../config";

export const updateChangelogs = async (
    githubToken: string,
    discordWebhookURL: string
) => {
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

    const { features, fixes, refactors } = await getChanges({
        repo: {
            author: config.github.username,
            repo: config.github.repo,
        },
        version: {
            previous: previous.tag_name,
            current: latest.tag_name,
        },
    });

    const donwloadURL = `${config.url}/download/${latest.tag_name}/`;
    const changes = [`🔥 [Click here to Download](${donwloadURL})\n`];

    if (features.length || fixes.length || refactors.length) {
        changes.push(`📝 **Changelogs**`);
        if (features.length) {
            changes.push("\n✨ Features:", ...features.map((x) => `- ${x}`));
        }
        if (fixes.length) {
            changes.push("\n🩹 Fixes:", ...fixes.map((x) => `- ${x}`));
        }
        if (refactors.length) {
            changes.push("\n♻️ Changes:", ...refactors.map((x) => `- ${x}`));
        }
    }

    const logs = changes.join("\n");
    await got.post(discordWebhookURL, {
        headers: {
            "Content-Type": "application/json",
        },
        body: JSON.stringify({
            username: "Yukino - Releases",
            avatar_url: `https://github.com/${config.github.username}/${config.github.repo}/blob/next/assets/images/yukino-icon.png?raw=true`,
            embeds: [
                {
                    title: latest.name,
                    url: donwloadURL,
                    color: 6514417,
                    description: logs,
                    timestamp: new Date().toISOString(),
                },
            ],
        }),
    });

    let body = latest.body || "";
    const changelogsRegex = /(\*\*\[Click here to Download\]\*\*[\s\S]+)/;

    if (changelogsRegex.test(body)) {
        if (!logs) {
            body = body.replace(changelogsRegex, "");
        } else {
            body = body.replace(changelogsRegex, logs);
        }
    } else {
        if (logs) {
            body += `\n\n${logs}`;
        }
    }

    await github.request("POST /repos/{owner}/{repo}/releases/{release_id}", {
        ...repo,
        release_id: latest.id,
        body,
    });
};
