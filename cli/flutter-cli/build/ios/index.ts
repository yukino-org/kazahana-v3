import { dirname, join } from "path";
import { ensureDir, copyFile } from "fs-extra";
import { spawn, promisifyChildProcess } from "../../../spawn";
import { config } from "../../../config";
import { Logger } from "../../../logger";
import { getVersion } from "../../../helpers/version";

export const built = join(config.base, "build/ios/ipa/yukino_app.ipa");

const logger = new Logger("build:ios");

export const build = async () => {
    await promisifyChildProcess(
        await spawn("flutter", ["build", "ipa", "--no-codesign"], config.base)
    );

    const out = join(
        config.ios.packed,
        `${config.name} v${await getVersion()} Installer.ipa`
    );
    await ensureDir(dirname(out));
    await copyFile(built, out);

    logger.log(`Installer created: ${out}`);
};
