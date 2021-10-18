import { config } from "../../config";
import { Logger } from "../../logger";
import { promisifyChildProcess, spawn } from "../../spawn";

const logger = new Logger("push:main");

const next = "next";
const main = "main";

export const pushMain = async () => {
    await promisifyChildProcess(
        await spawn("git", ["checkout", main], config.base)
    );
    logger.log(`Checked out to ${main} `);

    await promisifyChildProcess(
        await spawn("git", ["merge", next], config.base)
    );
    logger.log(`Merged ${next}`);

    await promisifyChildProcess(
        await spawn("git", ["push", "origin", main], config.base)
    );
    logger.log(`Pushed ${main}`);

    await promisifyChildProcess(
        await spawn("git", ["checkout", next], config.base)
    );
    logger.log(`Checked out to ${next} `);

    logger.log(`Merged ${next} with ${main}`);
};
