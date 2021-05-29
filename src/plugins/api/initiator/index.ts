export type InitiatorFn = () => Promise<void>;

const noop: InitiatorFn = async () => {};

export const Initiator = {
    async getClient() {
        switch (app_platform) {
            case "capacitor":
                return (await import("./capacitor")).initiator;

            default:
                return noop;
        }
    },
};
