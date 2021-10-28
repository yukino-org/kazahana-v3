import { join } from "path";
import chalk from "chalk";
import { readFile, writeFile } from "fs-extra";
import semver from "semver";
import { prompt } from "inquirer";
import { spawn } from "../../../spawn";
import { config } from "../../../config";
import { Logger } from "../../../logger";
import { matchRegex } from "../print";

const logger = new Logger("version:bump");

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

    const result = await spawn(
        "npx",
        [
            "semver",
            "-s",
            "--",
            previousVersion.version,
            ...process.argv.slice(2),
        ],
        { cwd: config.base }
    );

    const newVersion = semver.parse(semver.clean(result.stdout.trim()))!;
    if (newVersion.compare(previousVersion) != 1) {
        throw new Error("Cannot bump to same version");
    }

    const { confirmed }: { confirmed: boolean } = await prompt({
        name: "confirmed",
        message: `Do you want to bump version from v${previousVersion.version} to v${newVersion.version}?`,
        type: "confirm",
    });

    if (confirmed) {
        pubspec = pubspec.replace(matchRegex, `version: ${newVersion}`);
        await writeFile(path, pubspec);

        logger.log(
            `Bumped from ${chalk.cyanBright(
                previousVersion.version
            )} to ${chalk.cyanBright(newVersion.version)}`
        );
    }
};
