export interface RequesterOptions {
    headers: Record<string, any>;
    timeout?: number;
    credentials?: boolean;
    responseType: "buffer" | "text";
}

export interface Requester {
    get(url: string, options: RequesterOptions): Promise<any>;
    post(url: string, body: any, options: RequesterOptions): Promise<any>;
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
    },
};
