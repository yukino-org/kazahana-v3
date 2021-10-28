import { run } from "../../../runner";
import { updateChangelogs } from "./";

run(async () => {
    if (!process.env.GITHUB_TOKEN) {
        throw new Error("Missing 'process.env.GITHUB_TOKEN'");
    }

    if (!process.env.DISCORD_RELEASE_HOOK) {
        throw new Error("Missing 'process.env.DISCORD_RELEASE_HOOK'");
    }

    await updateChangelogs(
        process.env.GITHUB_TOKEN,
        process.env.DISCORD_RELEASE_HOOK
    );
});
