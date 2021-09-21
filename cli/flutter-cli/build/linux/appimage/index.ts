import { dirname, join, relative } from "path";
import { ensureDir, readFile, rename, writeFile } from "fs-extra";
import readdirp from "readdirp";
import { spawn, promisifyChildProcess } from "../../../../spawn";
import { getVersion } from "../../../../helpers/version";
import { Logger } from "../../../../logger";
import { config } from "../../../../config";

export const buildDir = join(config.base, "build/linux/x64/release/bundle");

const logger = new Logger("build:linux:appimage");

const builderYml = join(__dirname, "builder.yml");
const builderGYml = join(__dirname, "builder.g.yml");

export const build = async () => {
    const version = await getVersion();

    const context: Record<string, string> = {
        rootDir: `./${relative(config.base, buildDir)}`,
        primaryExe: config.code,
        appName: config.name,
        version: version,
    };

    const template = (await readFile(builderYml)).toString();
    const rendered = template.replace(/{{{.*?}}}/g, (match) => {
        const key = match.slice(3, -3).trim();
        return context[key];
    });

    await writeFile(builderGYml, rendered);
    logger.log(`Rendered ${builderGYml}`);

    await promisifyChildProcess(
        await spawn(
            "appimage-builder ",
            [
                "--recipe",
                `./${relative(config.base, builderGYml)}`,
                "--skip-tests",
            ],
            config.base
        )
    );
    const outPath = (await readdirp.promise(config.base)).find((x) =>
        x.basename.endsWith(".AppImage")
    );
    if (!outPath) {
        throw new Error("Failed to find generated appimage");
    }

    const finalPath = join(config.linux.packed, outPath.basename);
    await ensureDir(dirname(finalPath));
    await rename(outPath.fullPath, finalPath);
    logger.log(`AppImage created: ${finalPath}`);
};
