export const RequesterResponseTypes = ["text", "buffer"] as const;
export type RequesterResponseTypesType = typeof RequesterResponseTypes[number];

export interface RequesterOptions {
    headers: Record<string, any>;
    timeout?: number;
    credentials?: boolean;
    responseType: RequesterResponseTypesType;
}

export interface Requester {
    get(
        url: string,
        options: RequesterOptions & {
            responseType: "text";
        }
    ): Promise<string>;
    get(
        url: string,
        options: RequesterOptions & {
            responseType: "buffer";
        }
    ): Promise<ArrayBuffer>;

    post(
        url: string,
        body: any,
        options: RequesterOptions & {
            responseType: "text";
        }
    ): Promise<string>;
    post(
        url: string,
        body: any,
        options: RequesterOptions & {
            responseType: "buffer";
        }
    ): Promise<ArrayBuffer>;

    patch: Requester["post"];
    put: Requester["post"];
}

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
    }
};
