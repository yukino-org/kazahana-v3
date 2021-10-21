import { dirname, join, relative } from "path";
import { ensureDir, readdir, readFile, rename, writeFile } from "fs-extra";
import { spawn } from "../../../../spawn";
import { getVersion } from "../../../../helpers/version";
import { Logger } from "../../../../logger";
import { config } from "../../../../config";
import { buildDir } from "../";

const logger = new Logger("linux:build:appimage");

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

    logger.log("Running appimage-builder command");
    await spawn(
        "appimage-builder",
        ["--recipe", `./${relative(config.base, builderGYml)}`, "--skip-tests"],
        config.base
    );
    logger.log("Finished running appimage-builder command");

    const outPath = (await readdir(config.base)).find((x) =>
        x.endsWith(".AppImage")
    );
    if (!outPath) {
        throw new Error("Failed to find generated appimage");
    }

    const finalPath = join(
        config.linux.packed,
        `${config.name}_v${version}-linux.AppImage`
    );
    await ensureDir(dirname(finalPath));
    await rename(outPath, finalPath);
    logger.log(`AppImage created: ${finalPath}`);
};
