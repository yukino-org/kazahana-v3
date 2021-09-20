import { spawn, promisifyChildProcess } from "../../../spawn";
import { config } from "../../../config";

export const debug = async () => {
    await promisifyChildProcess(
        await spawn(
            "flutter",
            ["run", "-d", "linux", ...process.argv.slice(2)],
            config.base
        )
    );
};
