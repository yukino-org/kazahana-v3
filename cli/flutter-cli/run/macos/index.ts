import { promisifyChildProcess, spawn } from "../../../spawn";
import { config } from "../../../config";

export const debug = async () => {
    await promisifyChildProcess(
        await spawn(
            "flutter",
            ["run", "-d", "macos", ...process.argv.slice(2)],
            config.base
        )
    );
};
