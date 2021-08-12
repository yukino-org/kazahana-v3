import { Debugger } from "./api/debugger";

export type LoggerTypes = "info" | "error" | "warn" | "success";

export type EventListener = (type: LoggerTypes, msg: string) => any;

class Logger {
    listeners: EventListener[];

    constructor() {
        this.listeners = [];
    }

    on(handler: EventListener) {
        this.listeners.push(handler);
    }

    async emit(type: LoggerTypes, msg: string) {
        this.listeners.forEach((handler) => {
            try {
                handler(type, msg);
            } catch (err: any) {}
        });

        const dbug = await Debugger.getClient();
        const fn =
            type === "info" || type === "success" ? dbug.debug : dbug[type];
        fn("app", msg);
    }
}

export default new Logger();
