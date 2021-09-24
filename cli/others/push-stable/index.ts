import { config } from "../../config";
import { Logger } from "../../logger";
import { promisifyChildProcess, spawn } from "../../spawn";

const logger = new Logger("push-stable");

const next = "next";
const main = "stable";

export const pushStable = async () => {
    await promisifyChildProcess(
        await spawn("git", ["checkout", main], config.base)
    );

    await promisifyChildProcess(
        await spawn("git", ["merge", next], config.base)
    );

    await promisifyChildProcess(
        await spawn("git", ["push", "origin", main], config.base)
    );

    await promisifyChildProcess(
        await spawn("git", ["checkout", next], config.base)
    );

    logger.log(`Merged ${next} with ${main}`);
};
