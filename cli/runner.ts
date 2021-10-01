import { executeHooksFor } from "./hooks";

export const run = async (fn: () => Promise<void>) => {
    try {
        if (!process.env.npm_lifecycle_event) {
            throw new Error("Command must be triggered using npm scripts");
        }

        await executeHooksFor("prerun", process.env.npm_lifecycle_event);
        await fn();
        await executeHooksFor("postrun", process.env.npm_lifecycle_event);
    } catch (err) {
        console.error(err);
        process.exit(1);
    }
};
