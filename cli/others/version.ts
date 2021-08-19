import { join } from "path";
import { readFile, writeFile } from "fs/promises";
import commandLineArgs from "command-line-args";
import semver from "semver";
import { config } from "../config";
import { Logger } from "../logger";

const logger = new Logger("version");

const argsOpts: commandLineArgs.OptionDefinition[] = [
    {
        name: "increment",
        alias: "i",
        defaultOption: true,
        type: String,
        multiple: false,
    },
    {
        name: "preid",
        alias: "p",
        type: String,
        multiple: false,
    },
];

const matchRegex = /version:(.*)/;

const start = async () => {
    const { increment, preid } = commandLineArgs(argsOpts);

    if (!increment) {
        return logger.error(`Missing arg: increment`);
    }

    const path = join(config.base, "pubspec.yaml");
    logger.log(`Path: ${path}`);
    
    let pubspec = (await readFile(path)).toString();

    const parsedVersion = pubspec.match(matchRegex)?.[1];
    if (!parsedVersion) {
        return logger.error(`Missing 'version' in 'pubspec.yaml'`);
    }

    const previousVersion = semver.clean(parsedVersion);
    if (!previousVersion) {
        return logger.error(`Invalid 'version' in 'pubspec.yaml'`);
    }

    logger.log(`Increment: ${increment}`);
    logger.log(`Pre-id: ${preid || "-"}`);

    const newVersion = semver.inc(previousVersion, increment, preid);
    if (!newVersion) {
        return logger.error(`Invalid arguments where provided`);
    }

    pubspec = pubspec.replace(matchRegex, `version: ${newVersion}`);
    await writeFile(path, pubspec);

    logger.log(`Bumped from ${previousVersion} to ${newVersion}`);
}

start();