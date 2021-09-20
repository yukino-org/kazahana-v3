import { join, relative } from "path";
import { rename, writeFile } from "fs-extra";
import readdirp from "readdirp";
import ejs from "ejs";
import { spawn, promisifyChildProcess } from "../../../../spawn";
import { getVersion } from "../../../../helpers/version";
import { Logger } from "../../../../logger";
import { config } from "../../../../config";

export const buildDir = join(config.base, "build/linux/x64/release/bundle");

const logger = new Logger("build:linux:builder");

const builderYml = join(__dirname, "builder.yml");
const builderGYml = join(__dirname, "builder.g.yml");

export const build = async () => {
    const version = await getVersion();

    const context: Record<string, string> = {
        rootDir: `./${relative(config.base, buildDir)}`,
        primaryExe: "yukino_app",
        appName: config.name,
        version: version,
    };

    const rendered = await ejs.renderFile(builderYml, context, {
        openDelimiter: "{",
        closeDelimiter: "}",
        delimiter: "%",
    });
    await writeFile(builderGYml, rendered);
    logger.log(`Rendered ${builderGYml}`);

    await promisifyChildProcess(await spawn("appimage-builder ", ["--recipe", `./${relative(config.base, builderGYml)}`, "--skip-tests"], config.base));
    const outPath = (await readdirp.promise(config.base)).find(x => x.basename.endsWith(".AppImage"));
    if (!outPath) {
        throw new Error("Failed to find generated appimage");
    }

    const finalPath = join(config.linux.packed, outPath.basename);
    await rename(outPath.fullPath, finalPath);
    logger.log(`AppImage created: ${finalPath}`);
}