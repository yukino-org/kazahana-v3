import got, { RequestError as GotRequestError } from "got";
import commandLineArgs from "command-line-args";
import { config } from "../../config";
import { Logger } from "../../logger";
import { getVersion } from "../version";

const logger = new Logger("check-release");

const argsOpts: commandLineArgs.OptionDefinition[] = [
    {
        name: "ends",
        alias: "e",
        type: String,
        multiple: true,
    },
];

export const checkRelease = async () => {
    const args = commandLineArgs(argsOpts);

    if (!Array.isArray(args.ends) || !args.ends.length) {
        throw new Error("Missing argument '-e'");
    }

    const ends = args.ends.map((x) => {
        let y: string = x;
        if (y.startsWith("'")) y = y.slice(1);
        if (y.endsWith("'")) y = y.slice(0, -1);
        return y;
    });

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
