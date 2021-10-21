import chalk from "chalk";
import logSymbols from "log-symbols";
import prettyMs from "pretty-ms";
import { executeHooksFor } from "./hooks";

export const run = async (fn: () => Promise<void>) => {
    const startedAt = Date.now();
    try {
        if (!process.env.npm_lifecycle_event) {
            throw new Error("Command must be triggered using npm scripts");
        }

        await executeHooksFor("prerun", process.env.npm_lifecycle_event);
        await fn();
        await executeHooksFor("postrun", process.env.npm_lifecycle_event);

        console.log(
            `\n${logSymbols.success} Finished in ${chalk.greenBright(
                prettyMs(Date.now() - startedAt)
            )}\n`
        );
    } catch (err) {
        console.error(chalk.redBright(err));
        console.log(
            `\n${logSymbols.error} Failed in ${chalk.redBright(
                prettyMs(Date.now() - startedAt)
            )}\n`
        );
        process.exit(1);
    }
};
