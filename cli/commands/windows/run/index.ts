import { spawn } from "../../../spawn";
import { config } from "../../../config";
import { Logger } from "../../../logger";

const logger = new Logger("windows:run");

export const debug = async () => {
    logger.log("Running debug command...");

    await spawn("flutter", ["run", "-d", "windows", ...process.argv.slice(2)], {
        cwd: config.base,
        stdio: "inherit",
    });
};
