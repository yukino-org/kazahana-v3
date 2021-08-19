import { join } from "path";
import { existsSync } from "fs";
import { spawn } from "../../spawn";
import { config } from "../../config";
import { Logger } from "../../logger";

const logger = new Logger("test:sources:anime");

const start = () => {
    const [plugin, method] = process.argv.slice(2);
    
    if (!plugin) {
        return logger.error(`Missing arg: plugin`);
    }

    if (!method) {
        return logger.error(`Missing arg: method`);
    }

    logger.log(`Plugin: ${plugin}`);
    logger.log(`Method: ${method}`);

    const path = join(config.base, `/test/extractors/anime/${plugin}/${method}.dart`);
    logger.log(`Path: ${path}`);

    const exists = existsSync(path);
    if (!exists) {
        return logger.error(`Missing file: ${path}`);
    }

    logger.log(" ");
    spawn("flutter", ["test", "-r", "expanded", path], config.base);
}

start();