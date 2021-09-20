import { join } from "path";
import { copyFile } from "fs-extra";
import { filesIn } from "../../../helpers/filesIn";
import { spawn, promisifyChildProcess } from "../../../spawn";
import { config } from "../../../config";
import { Logger } from "../../../logger";

export const buildDir = join(config.base, "build/windows/runner/Release");

const logger = new Logger("build:windows");

export const build = async () => {
    await promisifyChildProcess(await spawn("flutter", ["build", "windows"], config.base));
    logger.log(`Generated binaries at ${buildDir}`);

    const dllDir = join(__dirname, "dlls");
    for (const file of await filesIn(dllDir)) {
        const out = file.replace(dllDir, buildDir);
        await copyFile(file, out);
        logger.log(`Copied ${file.replace(process.cwd(), "")} to ${out.replace(process.cwd(), "")}`);
    }
}