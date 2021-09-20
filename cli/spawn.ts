import { ChildProcess } from "child_process";
import { spawn as crossSpawn } from "cross-spawn";

export interface PromisifyChildProcessResult {
    code: number | null;
    stdout: string;
    stderr: string;
}

export const promisifyChildProcess = (cp: ChildProcess) => new Promise<PromisifyChildProcessResult>((resolve, reject) => {
    const result: PromisifyChildProcessResult = {
        code: null,
        stdout: "",
        stderr: "",
    };
    
    cp
        .on("message", (data) => {
            result.stdout += data.toString();
        })
        .on("error", (err) => {
            result.stdout += err.toString();
        })
        .on("exit", (code) => {
            result.code = code;
            result.code === 0 ? resolve(result) : reject(result);
        });
});

export const spawnMultiple = async (...processes: Parameters<typeof spawn>[]) => {
    for (const proc of processes) {
        await promisifyChildProcess(await spawn(...proc));
    }
};

export const spawn = async (cmd: string, args: string[], cwd: string) => {
    return crossSpawn(cmd, args, {
        stdio: "inherit",
        env: process.env,
        cwd: cwd,
        shell: true
    });
}