import { initiator as common } from "./common";

export type InitiatorFn = () => Promise<void>;

export const Initiator = {
    async getClient() {
        let platformfn: InitiatorFn | undefined;
        switch (app_platform) {
            case "capacitor":
                platformfn = (await import("./capacitor")).initiator;
        }

        return async () => {
            if (platformfn) await platformfn();
            await common();
        };
    },
};
