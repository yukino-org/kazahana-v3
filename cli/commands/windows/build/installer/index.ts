import { join } from "path";
import { writeFile } from "fs-extra";
import ejs from "ejs";
import { spawn } from "../../../../spawn";
import { getVersion } from "../../../version/print";
import { path as iconPath } from "../../icons";
import { Logger } from "../../../../logger";
import { config } from "../../../../config";
import { buildDir } from "../";

const logger = new Logger("windows:build:installer");

const installerIss = join(__dirname, "installer.iss");
const installerGIss = join(__dirname, "installer.g.iss");

export const build = async () => {
    const version = await getVersion();

    const context: Record<string, string> = {
        rootDir: buildDir,
        primaryExe: `${config.code}.exe`,
        outputDir: config.windows.packed,
        setupName: `${config.name}_v${version}-windows`,
        appName: config.name,
        version: version,
        url: config.url,
        appIcon: iconPath,
    };

    const rendered = await ejs.renderFile(installerIss, context, {
        openDelimiter: "{",
        closeDelimiter: "}",
        delimiter: "%",
    });
    await writeFile(installerGIss, rendered);
    logger.log(`Rendered ${installerIss}`);

    logger.log("Running iscc command");
    await spawn("iscc", [installerGIss], config.base);
    logger.log("Finished running iscc command");

    logger.log(
        `Installer created: ${join(
            context.outputDir,
            `${context.setupName}.exe`
        )}`
    );
};
