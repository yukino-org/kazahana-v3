import { join } from "path";
import jimp from "jimp";
import { config } from "../../config";
import { Logger } from "../../logger";

const logger = new Logger("android:icons");
const sizes: [number, string][] = [
    [48, "mdpi"],
    [72, "hdpi"],
    [96, "xhdpi"],
    [144, "xxhdpi"],
    [192, "xxxhdpi"],
];

export const generate = async () => {
    const started = Date.now();

    logger.log(`Icon path: ${config.android.icon}`);
    const img = await jimp.read(config.android.icon);

    for (const size of sizes) {
        const path = join(config.android.project, `/app/src/main/res/mipmap-${size[1]}/ic_launcher.png`);
        img.resize(size[0], size[0]);
        await img.writeAsync(path);
        logger.log(`Generated ${path}`);
    }

    logger.log(`Completed in ${Date.now() - started}ms`);
}