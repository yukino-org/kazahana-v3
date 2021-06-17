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

    emit(type: LoggerTypes, msg: string) {
        this.listeners.forEach((handler) => {
            try {
                handler(type, msg);
            } catch (err) {}
        });
    }
}

export default new Logger();
