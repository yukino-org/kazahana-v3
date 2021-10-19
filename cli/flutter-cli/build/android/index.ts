import { dirname, join } from "path";
import { ensureDir, copyFile } from "fs-extra";
import { spawn, promisifyChildProcess } from "../../../spawn";
import { config } from "../../../config";
import { Logger } from "../../../logger";
import { getVersion } from "../../../helpers/version";

export const built = join(
    config.base,
    "build/app/outputs/flutter-apk/app-release.apk"
);

const logger = new Logger("android:build");

export const build = async () => {
    logger.log("Running build command...");
    await promisifyChildProcess(
        await spawn("flutter", ["build", "apk"], config.base)
    );
    logger.log("Finished running build command");

    const out = join(
        config.android.packed,
        `${config.name}_v${await getVersion()}-android.apk`
    );
    await ensureDir(dirname(out));
    await copyFile(built, out);

    logger.log(`Installer created: ${out}`);
};
