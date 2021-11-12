import { StdioOptions } from "child_process";
import { spawn as crossSpawn } from "cross-spawn";

export class SpawnResult {
    constructor(
        public readonly command: string,
        public readonly code: number | null,
        public readonly stdout: string,
        public readonly stderr: string
    ) {}
}

export class SpawnError extends Error {
    constructor(
        public readonly result: SpawnResult,
        public readonly err?: Error
    ) {
        super();

        if (err) {
            Object.assign(this, err);
        }

        this.message = `Spawn failed with code ${result.code}\nCommand: ${
            result.command || "-"
        }\nOutput: ${result.stdout || "-"}\nError: ${err || "-"}`;
    }
}

export interface SpawnOptions {
    cwd: string;
    stdio?: StdioOptions;
}

export const spawn = async (
    cmd: string,
    args: string[],
    { cwd, stdio }: SpawnOptions
) =>
    new Promise<SpawnResult>(async (resolve, reject) => {
        const cp = crossSpawn(cmd, args, {
            stdio: stdio ?? (isVerbose() ? "inherit" : undefined),
            env: process.env,
            cwd: cwd,
        });

        let stdout = "";
        let stderr = "";

        const getResult = (code: number | null) =>
            new SpawnResult(cp.spawnargs.join(" "), code, stdout, stderr);

        const getError = (code: number | null, err?: Error) =>
            new SpawnError(getResult(code), err);

        cp.stdout?.on("data", (data) => {
            stdout += data.toString();
        });

        cp.stdout?.on("data", (data) => {
            stderr += data.toString();
        });

        cp.once("close", (code) => {
            if (code === 0) {
                resolve(getResult(code));
            } else {
                reject(getError(code));
            }
        });
    });

export const defaultArgs = {
    verbose: ["--verbose", "-v"],
    force: ["--force", "-f"],
};

export const getArgsInfo = () => ({
    args: getArgs(),
    verbose: isVerbose(),
    force: isForce(),
});

export const isVerbose = () =>
    process.argv.slice(2).some((x) => defaultArgs.verbose.includes(x));

export const isForce = () =>
    process.argv.slice(2).some((x) => defaultArgs.force.includes(x));

export const getArgs = () =>
    process.argv
        .slice(2)
        .filter((x) => !Object.values(defaultArgs).flat().includes(x));
