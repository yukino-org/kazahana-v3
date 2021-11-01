import { dirname, join } from "path";
import chalk from "chalk";
import { ensureDir, readFile, writeFile } from "fs-extra";
import { parse as yaml } from "yaml";
import { config } from "../../../../config";
import { Logger } from "../../../../logger";

const logger = new Logger("generator:run:meta");

const metaFile = join(config.base, "assets/data/meta.json");

export const generateMeta = async () => {
    const pubspecPath = join(config.base, "pubspec.yaml");
    logger.log(`Reading pubspec.yaml from ${pubspecPath}`);

    const pubspec = yaml((await readFile(pubspecPath)).toString());

    await ensureDir(dirname(metaFile));
    await writeFile(
        metaFile,
        JSON.stringify({
            name: pubspec.description,
            code: pubspec.name,
            version: pubspec.version,
        })
    );

    logger.log(`Generated ${chalk.cyanBright(metaFile)}`);
};
