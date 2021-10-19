import { promisifyChildProcess, spawn } from "../../../spawn";
import { config } from "../../../config";
import { Logger } from "../../../logger";

const logger = new Logger("build:android");

export const debug = async () => {
    logger.log("Running debug command...");

    await promisifyChildProcess(
        await spawn(
            "flutter",
            ["run", "-d", "windows", ...process.argv.slice(2)],
            config.base,
            "inherit"
        )
    );
};
