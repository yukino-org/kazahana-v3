import { Filesystem, Directory, Encoding } from "@capacitor/filesystem";
import { Debugger, DebuggerEntity } from "./";

const logDir = "yukino/logs";
const logFile = `${new Date()
    .toLocaleDateString()
    .replace(/[^A-Za-z0-9]/, "-")}.log`;

const appendFile = async (txt: string) => {
    try {
        await Filesystem.appendFile({
            path: `${logDir}/${logFile}`,
            data: `\n${txt}`,
            directory: Directory.Documents,
            encoding: Encoding.UTF8,
        });
    } catch (err) {}
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
