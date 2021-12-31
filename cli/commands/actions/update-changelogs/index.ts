import got from "got";
import { getOctokit } from "@actions/github";
import { config } from "../../../config";
import { Logger } from "../../../logger";
import { Changelogs } from "./changelogs";

const logger = new Logger("actions:update-changelogs");

const repo = { owner: config.github.username, repo: config.github.repo };

export const updateChangelogs = async (
    githubToken: string,
    discordWebhookURL: string
) => {
    logger.log("Generating changelogs");

    const github = getOctokit(githubToken, {});

    const { data } = await github.request(
        "GET /repos/{owner}/{repo}/releases",
        {
            ...repo,
            per_page: 2,
        }
    );
    const [latest, previous] = data.filter((x) => !x.draft);
    console.log(data.filter((x) => !x.draft).map((x) => x.url));
    logger.log(`Comparing ${previous.tag_name} & ${latest.tag_name}`);

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
