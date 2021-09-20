export const run = async (fn: () => Promise<void>) => {
    try {
        await fn();
    } catch (err) {
        console.error(err);
        process.exit(1);
    }
}