import { spawn } from "../../../spawn";
import { config } from "../../../config";
import { Logger } from "../../../logger";

const logger = new Logger("build:android");

export const debug = async () => {
    logger.log("Running debug command...");

    await spawn("flutter", ["run", "-d", "linux", ...process.argv.slice(2)], {
        cwd: config.base,
        stdio: "inherit",
    });
};
