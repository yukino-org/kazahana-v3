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

    const allChanges = await getChanges({
        repo: {
            author: config.github.username,
            repo: config.github.repo,
        },
        version: {
            previous: previous.tag_name,
            current: latest.tag_name,
        },
    });

    await github.request({
        method: "POST",
        url: latest.upload_url,
        headers: {
            "content-type": "text/plain",
        },
        data: JSON.stringify(allChanges),
        name: "changelogs.json",
    });

    const { features, fixes, refactors } = allChanges;
    const changes = [];
    if (features.length || fixes.length || refactors.length) {
        changes.push(`**Changelogs**`);
        if (features.length) {
            changes.push("\nFeatures:", ...features.map((x) => `- ${x}`));
        }
        if (fixes.length) {
            changes.push("\nFixes:", ...fixes.map((x) => `- ${x}`));
        }
        if (refactors.length) {
            changes.push("\nChanges:", ...refactors.map((x) => `- ${x}`));
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
                    url: latest.html_url,
                    color: 6514417,
                    description: logs,
                    timestamp: new Date().toISOString(),
                },
            ],
        }),
    });

    let body = latest.body || "";
    const changelogsRegex = /(\*\*Changelogs\*\*[\s\S]+)/;

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
