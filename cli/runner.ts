import logSymbols from "log-symbols";
import prettyMs from "pretty-ms";
import { executeHooksFor } from "./hooks";
import { PromisifyChildProcessResult } from "./spawn";

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
            `\n${logSymbols.success} Finished in ${prettyMs(
                Date.now() - startedAt
            )}\n`
        );
    } catch (err) {
        if (err instanceof PromisifyChildProcessResult) {
            console.error(
                `Spawn failed with code ${err.code}\n\ncmd: ${err.command}\n\nstdout:\n${err.stdout}\n\nstderr:${err.stderr}`
            );
        } else {
            console.error(err);
        }

        console.log(
            `\n${logSymbols.error} Failed in ${prettyMs(
                Date.now() - startedAt
            )}\n`
        );
        process.exit(1);
    }
};
