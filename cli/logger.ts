import logSymbols from "log-symbols";
import chalk from "chalk";

export class Logger {
    constructor(public readonly name: string) {}

    log(text: string) {
        console.log(`[${this.name}] ${chalk.cyanBright("INFO")} ${text}`);
    }

    warn(text: string) {
        console.warn(`[${this.name}] ${chalk.yellowBright("WARN")} ${text}`);
    }

    error(text: string) {
        console.error(`[${this.name}] ${chalk.redBright("ERR!")} ${text}`);
    }

    static s = logSymbols;
}
