import { join } from "path";
import jimp from "jimp";
import { Logger } from "../../../logger";
import { config } from "../../../config";
import { buildDir } from "../build";

export const path = join(
    buildDir,
    `usr/share/icons/hicolor/256x256/apps/${config.code}.png`
);

const logger = new Logger("linux:icons");
const size = 256;

export const generate = async () => {
    const img = await jimp.read(config.linux.icon);

    img.quality(100);
    img.resize(size, size);

    await img.writeAsync(path);
    logger.log(`Generated ${path}`);
};
