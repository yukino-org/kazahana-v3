import { join } from "path";
import jimp from "jimp";
import { getModifiedIcon } from "../../../utils";
import { config } from "../../../config";
import { Logger } from "../../../logger";

const logger = new Logger("ios:icons");
const sizes: [number, number][] = [
    [20, 1],
    [20, 2],
    [20, 3],
    [29, 1],
    [29, 2],
    [29, 3],
    [40, 1],
    [40, 2],
    [40, 3],
    [60, 2],
    [60, 3],
    [76, 1],
    [76, 2],
    [83.5, 2],
    [1024, 1],
];

export const generate = async () => {
    const started = Date.now();

    logger.log(`Icon path: ${config.ios.icon}`);
    const original = await jimp.read(
        await getModifiedIcon(config.android.icon)
    );

    for (const size of sizes) {
        const path = join(
            config.ios.project,
            `/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-${size[0]}x${size[0]}@${size[1]}x.png`
        );
        const px = size[0] * size[1];

        const img = original.clone();
        img.quality(100);
        img.resize(px, px);
        await img.writeAsync(path);
        logger.log(`Generated ${path}`);
    }

    logger.log(`Completed in ${Date.now() - started}ms`);
};
