import { join } from "path";
import { spawn, promisifyChildProcess } from "../../../spawn";
import { config } from "../../../config";
import { Logger } from "../../../logger";

export const buildDir = join(config.base, "build/macos/Build/Products/Release");

const logger = new Logger("build:macos");

export const build = async () => {
    logger.log("Running build command...");
    await promisifyChildProcess(
        await spawn("flutter", ["build", "macos"], config.base)
    );
    logger.log("Finished running build command");

    logger.log(`Generated binaries at ${buildDir}`);
};
