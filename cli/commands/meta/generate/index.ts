import { dirname, join } from "path";
import { ensureDir, readFile, writeFile } from "fs-extra";
import { parse as yaml } from "yaml";
import { config } from "../../../config";
import { Logger } from "../../../logger";

const logger = new Logger("meta:generate");

export const generate = async () => {
    const pubspecPath = join(config.base, "pubspec.yaml");
    logger.log(`Reading pubspec.yaml from ${pubspecPath}`);

    const pubspec = yaml((await readFile(pubspecPath)).toString());

    const outPath = join(config.base, "assets/data/meta.json");
    await ensureDir(dirname(outPath));
    await writeFile(
        outPath,
        JSON.stringify({
            name: pubspec.description,
            code: pubspec.name,
            version: pubspec.version,
        })
    );

    logger.log(`Generated ${outPath}`);
};
