import { join } from "path";
import { spawn, promisifyChildProcess } from "../../../spawn";
import { config } from "../../../config";
import { Logger } from "../../../logger";

export const buildDir = join(config.base, "build/windows/runner/Release");

const logger = new Logger("build:linux");

export const build = async () => {
    await promisifyChildProcess(
        await spawn("flutter", ["build", "linux", "--obfuscate"], config.base)
    );
    logger.log(`Generated binaries at ${buildDir}`);
};
