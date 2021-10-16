import { join } from "path";
import { readFile, writeFile } from "fs-extra";
import semver from "semver";
import { sync as spawn } from "cross-spawn";
import { prompt } from "inquirer";
import { config } from "../../config";
import { Logger } from "../../logger";
import { matchRegex } from "../../helpers/version";

const logger = new Logger("version");

export const increment = async () => {
    const path = join(config.base, "pubspec.yaml");
    logger.log(`Path: ${path}`);

    let pubspec = (await readFile(path)).toString();

    const parsedVersion = pubspec.match(matchRegex)?.[1];
    if (!parsedVersion) {
        return logger.error(`Missing 'version' in 'pubspec.yaml'`);
    }

    const previousVersion = semver.parse(semver.clean(parsedVersion));
    if (!previousVersion) {
        return logger.error(`Invalid 'version' in 'pubspec.yaml'`);
    }

    const result = spawn(
        "npx",
        [
            "semver",
            "-s",
            "--",
            previousVersion.version,
            ...process.argv.slice(2),
        ],
        {
            env: process.env,
            shell: true,
        }
    );
    if (result.status != 0) {
        throw new Error(result.stderr.toString());
    }

    const newVersion = semver.parse(
        semver.clean(result.stdout.toString().trim())
    )!;
    if (newVersion.compare(previousVersion) != 1) {
        throw new Error("Cannot bump to same version");
    }

    console.log(" ");
    const { confirmed }: { confirmed: boolean } = await prompt({
        name: "confirmed",
        message: `Do you want to bump version from ${previousVersion.version} to v${newVersion.version}?`,
        type: "confirm",
    });

    if (confirmed) {
        pubspec = pubspec.replace(matchRegex, `version: ${newVersion}`);
        await writeFile(path, pubspec);

        logger.log(
            `Bumped from ${previousVersion.version} to ${newVersion.version}`
        );
    }

    console.log(" ");
};
