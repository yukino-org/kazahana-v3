export class Logger {
    name: string;

    constructor(name: string) {
        this.name = name;
    }

    log(text: string) {
        console.log(`[${this.name}] ${text}`);
    }

    warn(text: string) {
        console.warn(`[${this.name}] ${text}`);
    }

    error(text: string) {
        console.error(`[${this.name}] ${text}`);
    }
}