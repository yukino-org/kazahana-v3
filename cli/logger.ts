import logSymbols from "log-symbols";
import chalk from "chalk";

export class Logger {
    constructor(public readonly _name: string) {}

    log(text: string) {
        console.log(`${this.name} ${chalk.cyanBright("INFO")} ${text}`);
    }

    warn(text: string) {
        console.warn(`${this.name} ${chalk.yellowBright("WARN")} ${text}`);
    }

    error(text: string) {
        console.error(`${this.name} ${chalk.redBright("ERR!")} ${text}`);
    }

    get name() {
        return chalk.gray(`[${this._name}]`);
    }

    static s = logSymbols;
}
