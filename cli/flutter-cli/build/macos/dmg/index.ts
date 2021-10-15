import { dirname, join } from "path";
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

    const outName = `${config.name}_v${version}-macos.dmg`;
    await promisifyChildProcess(
        await spawn(
            "create-dmg",
            [
                "--volname",
                `"${config.code}"`,
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
                `"${config.name}.app"`,
            ],
            buildDir
        )
    );

    const finalPath = join(config.macos.packed, outName);
    await ensureDir(dirname(finalPath));
    await rename(join(buildDir, outName), finalPath);
    logger.log(`Dmg created: ${finalPath}`);
};
