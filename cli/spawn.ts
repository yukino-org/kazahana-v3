import { spawn as crossSpawn } from "cross-spawn";

export const spawn = async (cmd: string, args: string[], cwd: string) => {
    return crossSpawn(cmd, args, {
        stdio: "inherit",
        env: process.env,
        cwd: cwd,
    });
}