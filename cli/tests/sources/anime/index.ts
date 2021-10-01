import { join } from "path";
import { stat } from "fs-extra";
import { spawn, promisifyChildProcess } from "../../../spawn";
import { config } from "../../../config";
import { Logger } from "../../../logger";

const logger = new Logger("test:sources:anime");

export const test = async () => {
    const [plugin, method] = process.argv.slice(2);

    if (!plugin) {
        return logger.error(`Missing arg: plugin`);
    }

    if (!method) {
        return logger.error(`Missing arg: method`);
    }

    logger.log(`Plugin: ${plugin}`);
    logger.log(`Method: ${method}`);

    const path = join(
        config.base,
        `/test/extractors/anime/${plugin}/${method}.dart`
    );
    logger.log(`Path: ${path}`);

    const exists = await stat(path)
        .then(() => true)
        .catch(() => false);
    if (!exists) {
        return logger.error(`Missing file: ${path}`);
    }

    logger.log(" ");
    await promisifyChildProcess(
        await spawn("flutter", ["test", "-r", "expanded", path], config.base)
    );
};
