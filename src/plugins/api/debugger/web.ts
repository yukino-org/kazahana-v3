import { DebuggerEntity } from "./";

const time = () => new Date().toLocaleTimeString();

export const debugger_: DebuggerEntity = {
    async debug(proc, txt) {
        console.log(
            `%c${time()} ` + `%cDBUG ` + `%c${proc}: ` + `%c${txt}`,
            "color: rgba(255, 255, 255, 0.5)",
            "color: #00ffbf",
            "color: #6366f1",
            "color: currentColor"
        );
    },
    async warn(proc, txt) {
        console.log(
            `%c${time()} ` + `%cWARN ` + `%c${proc}: ` + `%c${txt}`,
            "color: rgba(255, 255, 255, 0.5)",
            "color: #f6ff00",
            "color: #6366f1",
            "color: currentColor"
        );
    },
    async error(proc, txt) {
        console.log(
            `%c${time()} ` + `%cERR! ` + `%c${proc}: ` + `%c${txt}`,
            "color: rgba(255, 255, 255, 0.5)",
            "color: #ff0000",
            "color: #6366f1",
            "color: currentColor"
        );
    },
};
