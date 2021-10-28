import { join } from "path";
import { spawn } from "../../../spawn";
import { config } from "../../../config";
import { Logger } from "../../../logger";

export const buildDir = join(config.base, "build/linux/x64/release/bundle");

const logger = new Logger("linux:build");

export const build = async () => {
    logger.log("Running build command...");
    await spawn("flutter", ["build", "linux"], config.base);
    logger.log("Finished running build command");

    logger.log(`Generated binaries at ${buildDir}`);
};
