import { ChildProcess, StdioOptions } from "child_process";
import { spawn as crossSpawn } from "cross-spawn";

export class PromisifyChildProcessResult {
    constructor(
        public readonly command: string,
        public readonly code: number | null,
        public readonly stdout: string,
        public readonly stderr: string
    ) {}
}

export const promisifyChildProcess = (cp: ChildProcess) =>
    new Promise<PromisifyChildProcessResult>((resolve, reject) => {
        let stdout = "";
        let stderr = "";

        const getResult = (code: number | null) =>
            new PromisifyChildProcessResult(
                cp.spawnargs.join(" "),
                code,
                stdout,
                stderr
            );

        cp.on("message", (data) => {
            stdout += data.toString();
        })
            .on("error", (err) => {
                stderr += err.toString();
            })
            .on("close", (code) => {
                const result = getResult(code);
                code === 0 ? resolve(result) : reject(result);
            });
    });

export const spawn = async (
    cmd: string,
    args: string[],
    cwd: string,
    stdio?: StdioOptions
) => {
    return crossSpawn(cmd, args, {
        stdio: stdio,
        env: process.env,
        cwd: cwd,
        shell: true,
    });
};
