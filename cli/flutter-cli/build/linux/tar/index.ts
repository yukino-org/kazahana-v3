import { dirname, join } from "path";
import { ensureDir, readdir, createWriteStream } from "fs-extra";
import tar from "tar";
import { getVersion } from "../../../../others/version/print";
import { Logger } from "../../../../logger";
import { config } from "../../../../config";
import { buildDir } from "../";

const logger = new Logger("linux:build:tar.gz");

export const build = async () => {
    const version = await getVersion();

    const finalPath = join(
        config.linux.packed,
        `${config.name}_v${version}-linux.tar.gz`
    );

    await ensureDir(dirname(finalPath));

    const stream = createWriteStream(finalPath);
    tar.create(
        {
            gzip: true,
            cwd: buildDir,
        },
        await readdir(buildDir)
    ).pipe(stream);
    await new Promise((resolve) => stream.once("close", resolve));

    logger.log(`Tarball created: ${finalPath}`);
};
