import { Requester } from "anime-ext/dist/types";

export const http = {
    __http: <Requester | null>null,
    async getClient() {
        if (!this.__http) {
            switch (app_platform) {
                case "electron":
                    this.__http = window.PlatformBridge.http;
                    break;

                case "capacitor":
                    this.__http = (await import("./capacitor")).requester;
                    break;

                default:
                    break;
            }
        }

        return <Requester>this.__http;
    },
};
