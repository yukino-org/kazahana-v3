import chalk from "chalk";

export class Logger {
    constructor(public readonly name: string) {}

    log(text: string) {
        console.log(chalk.whiteBright(`[${this.name}] INFO ${text}`));
    }

    warn(text: string) {
        console.warn(chalk.yellowBright(`[${this.name}] WARN ${text}`));
    }

    error(text: string) {
        console.error(chalk.redBright(`[${this.name}] ERR! ${text}`));
    }
}
