import { join } from "path";
import { copyFile } from "fs-extra";
import readdirp from "readdirp";
import { spawn, promisifyChildProcess } from "../../../spawn";
import { config } from "../../../config";
import { Logger } from "../../../logger";

export const buildDir = join(config.base, "build/windows/runner/Release");

const logger = new Logger("build:windows");

export const build = async () => {
  await promisifyChildProcess(
    await spawn("flutter", ["build", "windows"], config.base)
  );
  logger.log(`Generated binaries at ${buildDir}`);

  const dllDir = join(__dirname, "dlls");
  for await (const file of readdirp(dllDir)) {
    const out = file.fullPath.replace(dllDir, buildDir);
    await copyFile(file.fullPath, out);
    logger.log(
      `Copied ${file.fullPath.replace(process.cwd(), "")} to ${out.replace(
        process.cwd(),
        ""
      )}`
    );
  }
};
