import { basename, dirname, join } from "path";
import { ensureDir, readFile, writeFile, readdir, rename } from "fs-extra";
import * as png2icons from "png2icons";
import { spawn, promisifyChildProcess } from "../../../../spawn";
import { getVersion } from "../../../../helpers/version";
import { Logger } from "../../../../logger";
import { config } from "../../../../config";

const icns = join(config.base, "build/macos/icon.icns");
export const buildDir = join(config.base, "build/macos/Build/Products/Release");

const logger = new Logger("build:macos:dmg");

export const build = async () => {
    const version = await getVersion();

    await ensureDir(dirname(icns));
    await writeFile(
        icns,
        png2icons.createICNS(
            await readFile(config.macos.icon),
            png2icons.BEZIER,
            256
        )
    );
    logger.log(`Generated ${icns}`);

    const outName = `${config.name} v${version} Installer.dmg`;
    await promisifyChildProcess(
        await spawn(
            "create-dmg",
            [
                "--volname",
                `"${config.name} v${version} Installer"`,
                "--volicon",
                `"${icns}"`,
                // "--background",
                // `"installer_background.jpg"`,
                "--window-pos",
                "200",
                "120",
                "--window-size",
                "800",
                "529",
                "--icon-size",
                "130",
                "--text-size",
                "14",
                "--icon",
                `"${config.name}.app"`,
                "260",
                "260",
                "--hide-extension",
                `"${config.name}.app"`,
                "--app-drop-link 540 250",
                "--hdiutil-quiet",
                `"${outName}"`,
                `"${buildDir}"`,
            ],
            config.base
        )
    );

    console.log((await readdir(config.base)).join(","));

    const finalPath = join(config.macos.packed, outName);
    await ensureDir(dirname(finalPath));
    await rename(join(config.base, outName), finalPath);
    logger.log(`Dmg created: ${finalPath}`);
};
