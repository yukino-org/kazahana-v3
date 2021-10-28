import { Endpoints } from "@octokit/types";
import { config } from "../../../config";
import { capitalizeString } from "../../../utils";

export type GitHubRelease =
    Endpoints["GET /repos/{owner}/{repo}/releases/latest"]["response"]["data"];
export type GitHubRefCompare =
    Endpoints["GET /repos/{owner}/{repo}/compare/{base}...{head}"]["response"]["data"];

export type CommitType = "feat" | "refactor" | "fix" | "perf";

export class CommitMessage {
    constructor(
        public readonly commit: {
            type: CommitType;
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

export class Changelogs {
    commits: Record<CommitType, CommitMessage[]> = {
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
                    type: match[1] as CommitType,
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
            CommitType,
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
