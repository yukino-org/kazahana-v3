import { join } from "path";
import { promisify } from "util";
import AdmZip from "adm-zip";
import { spawn } from "../../../spawn";
import { config } from "../../../config";
import { Logger } from "../../../logger";
import { getVersion } from "../../../others/version/print";

export const built = join(config.base, "build/ios/iphoneos/Runner.app");

const logger = new Logger("ios:build");

export const build = async () => {
    logger.log("Running build command...");
    await spawn("flutter", ["build", "ios", "--no-codesign"], config.base);
    logger.log("Finished running build command");

    const zip = new AdmZip();
    zip.addLocalFolder(built, join("Payload", built.match(/[^\\/]+$/)![0]));

    const out = join(
        config.ios.packed,
        `${config.name}_v${await getVersion()}-ios.ipa`
    );
    await promisify(zip.writeZip)(out);

    logger.log(`Installer created: ${out}`);
};
