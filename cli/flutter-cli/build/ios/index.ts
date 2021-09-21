import { basename, join } from "path";
import { promisify } from "util";
import AdmZip from "adm-zip";
import { spawn, promisifyChildProcess } from "../../../spawn";
import { config } from "../../../config";
import { Logger } from "../../../logger";
import { getVersion } from "../../../helpers/version";
import { lstatSync } from "fs";

export const built = join(config.base, "build/ios/iphoneos/Runner.app");

const logger = new Logger("build:ios");

export const build = async () => {
    await promisifyChildProcess(
        await spawn("flutter", ["build", "ios", "--no-codesign"], config.base)
    );

    const info = lstatSync(built);
    console.log(lstatSync(built));
    console.log(info.isDirectory());
    console.log(info.isFile());

    const zip = new AdmZip();
    zip.addLocalFolder(built, built.match(/[^\\/]+$/)![0]);

    const out = join(
        config.ios.packed,
        `${config.name} v${await getVersion()} Installer.ipa`
    );
    await promisify(zip.writeZip)(out);

    logger.log(`Installer created: ${out}`);
};
