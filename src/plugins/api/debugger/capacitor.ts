import { Filesystem, Directory, Encoding } from "@capacitor/filesystem";
import { DebuggerEntity } from "./";

const logFile = "yukino-debug.log";

const appendFile = async (txt: string) => {
    try {
        await Filesystem.appendFile({
            path: logFile,
            directory: Directory.Data,
            data: `\n${txt}`,
            encoding: Encoding.UTF8,
        });
    } catch (err: any) {}
};

export const debugger_: DebuggerEntity = {
    async debug(proc, txt) {
        await appendFile(
            `[${new Date().toLocaleTimeString()} DBUG] ${proc}: ${txt}`
        );
    },
    async warn(proc, txt) {
        await appendFile(
            `[${new Date().toLocaleTimeString()} WARN] ${proc}: ${txt}`
        );
    },
    async error(proc, txt) {
        await appendFile(
            `[${new Date().toLocaleTimeString()} ERR!] ${proc}: ${txt}`
        );
    },
};
