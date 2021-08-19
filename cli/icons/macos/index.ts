import { join } from "path";
import jimp from "jimp";
import { config } from "../../config";
import { Logger } from "../../logger";

const logger = new Logger("macos:icons");
const sizes: number[] = [
    16,
    32,
    64,
    128,
    256,
    512,
    1024,
];

export const generate = async () => {
    const started = Date.now();

    logger.log(`Icon path: ${config.macos.icon}`);
    const img = await jimp.read(config.macos.icon);

    for (const size of sizes) {
        const path = join(config.macos.project, `/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_${size}.png`);
        img.resize(size, size);
        await img.writeAsync(path);
        logger.log(`Generated ${path}`);
    }

    logger.log(`Completed in ${Date.now() - started}ms`);
}