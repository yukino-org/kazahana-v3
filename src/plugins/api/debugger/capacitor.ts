import { Filesystem, Directory, Encoding } from "@capacitor/filesystem";
import { DebuggerEntity } from "./";

const logDir = "yukino-logs";
const logFile = `debug.log`;

let mkdird = false,
    fileexists = false;
const appendFile = async (txt: string) => {
    try {
        if (!mkdird) {
            await Filesystem.mkdir({
                path: logDir,
                directory: Directory.Documents,
            }).catch(() => {});
            mkdird = true;
        }

        if (!fileexists) {
            const { files } = await Filesystem.readdir({
                path: logDir,
                directory: Directory.Documents,
            });
            fileexists = files.includes(logFile);
            if (!fileexists) {
                await Filesystem.writeFile({
                    path: `${logDir}/${logFile}`,
                    directory: Directory.Documents,
                    data: "",
                    encoding: Encoding.UTF8,
                    recursive: true,
                });
            }
        }

        await Filesystem.appendFile({
            path: `${logDir}/${logFile}`,
            directory: Directory.Documents,
            data: `\n${txt}`,
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
