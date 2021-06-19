export interface StoreEntity {
    set(key: string, value: any): Promise<void>;
    get(key: string): Promise<any>;
    all(): Promise<Record<string, any>>;
    clear(): Promise<boolean>;
}

export const Store = {
    __store: <StoreEntity | null>null,
    async getClient() {
        if (!this.__store) {
            switch (app_platform) {
                case "electron":
                    this.__store = window.PlatformBridge.store;
                    break;

                case "capacitor":
                    this.__store = (await import("./capacitor")).Store;
                    break;

                default:
                    break;
            }
        }

        return <StoreEntity>this.__store;
    },
};
