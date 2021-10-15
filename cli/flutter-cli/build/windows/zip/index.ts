import { join } from "path";
import { promisify } from "util";
import Zip from "adm-zip";
import { getVersion } from "../../../../helpers/version";
import { Logger } from "../../../../logger";
import { config } from "../../../../config";
import { buildDir } from "../";

const logger = new Logger("build:windows:zip");

export const zip = async () => {
    const version = await getVersion();
    const out = join(
        config.windows.packed,
        `${config.name}_v${version}-windows.zip`
    );

    const file = new Zip();
    file.addLocalFolder(buildDir);
    await promisify(file.writeZip)(out);

    logger.log(`Zip created: ${out}`);
};
