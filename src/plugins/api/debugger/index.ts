import { debugger_ as webDebug } from "./web";

export type DebuggerLogMethod = (proc: string, text: string) => Promise<void>;
export interface DebuggerEntity {
    debug: DebuggerLogMethod;
    warn: DebuggerLogMethod;
    error: DebuggerLogMethod;
}

export const Debugger = {
    __debugger: <DebuggerEntity | null>null,
    async getClient() {
        if (!this.__debugger) {
            let dbug: DebuggerEntity | undefined;

            switch (app_platform) {
                case "electron":
                    dbug = (await import("./electron")).debugger_;
                    break;

                case "capacitor":
                    dbug = (await import("./capacitor")).debugger_;
                    break;

                default:
                    break;
            }

            this.__debugger = {
                async debug(...args: Parameters<DebuggerLogMethod>) {
                    await webDebug.debug(...args);
                    await dbug?.debug(...args);
                },
                async warn(...args: Parameters<DebuggerLogMethod>) {
                    await webDebug.warn(...args);
                    await dbug?.warn(...args);
                },
                async error(...args: Parameters<DebuggerLogMethod>) {
                    await webDebug.error(...args);
                    await dbug?.error(...args);
                },
            };

            if (app_platform === "electron") {
                window.PlatformBridge.setDebuggerListener(webDebug);
            }
        }

        return this.__debugger;
    },
};
