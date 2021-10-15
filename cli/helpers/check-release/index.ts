import got, { RequestError as GotRequestError } from "got";
import { config } from "../../config";
import { Logger } from "../../logger";
import { getVersion } from "../version";

const logger = new Logger("check-release");

export const checkRelease = async () => {
    const ends = process.argv.slice(2);

    if (!Array.isArray(ends) || !ends.length) {
        throw new Error("Missing argument '-e'");
    }

    const version = await getVersion();
    const res = await got
        .get(
            `https://api.github.com/repos/${config.github.username}/${config.github.repo}/releases/tags/v${version}`
        )
        .catch((e) => (e as GotRequestError).response);

    if (res?.statusCode == 200) {
        const parsed = JSON.parse(res.body as string);
        const matches = (parsed.assets as any[]).some((x) =>
            (ends as string[]).some((y: string) => (<string>x.name).endsWith(y))
        );

        if (matches) {
            throw new Error(
                `Matches in tag v${version} were found. Please remove them before building.`
            );
        }
    }

    logger.log(`Tag v${version} does not exist, proceeding...`);
};
