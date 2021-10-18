import { promisifyChildProcess, spawn } from "../../spawn";
import { config } from "../../config";
import { Logger } from "../../logger";

const logger = new Logger("hive:generate");

const execute = async (force: boolean) => {
    const flags: string[] = [];

    if (force) {
        flags.push("--delete-conflicting-outputs");
    }

    await promisifyChildProcess(
        await spawn(
            "flutter",
            ["packages", "pub", "run", "build_runner", "build", ...flags],
            config.base
        )
    );
};

export const generate = async () => {
    logger.log("Running build_runner command...");

    try {
        await execute(process.argv.includes("-f"));
    } catch (err: any) {
        if (typeof err?.code === "number" && err.code === 78) {
            logger.warn(
                'Found conflicting outputs, retrying with "--delete-conflicting-outputs" flag'
            );

            await execute(true);
        }

        throw err;
    }

    logger.log("Finished running build_runner command");
};
