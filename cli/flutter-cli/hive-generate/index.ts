import { promisifyChildProcess, spawn } from "../../spawn";
import { config } from "../../config";

export const generate = async () => {
    await promisifyChildProcess(
        await spawn(
            "flutter",
            [
                "packages",
                "pub",
                "run",
                "build_runner",
                "build",
                "--delete-conflicting-outputs",
            ],
            config.base
        )
    );
};
