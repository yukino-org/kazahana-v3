import { StoreStructure } from "../../types";

export interface StoreSkeleton {
    [s: string]: any;
}

export type StoreAllType<T> = {
    [P in keyof T]: T[P] | null;
};

export interface StoreEntity<T extends StoreSkeleton> {
    set<K extends keyof T>(key: K, value: T[K] | null): Promise<void>;
    get<K extends keyof T>(key: K): Promise<T[K] | null>;
    clear(): Promise<boolean>;
    all(): Promise<StoreAllType<T>>;
}

export const Store = {
    __store: <StoreEntity<StoreStructure> | null>null,
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

        return <StoreEntity<StoreStructure>>this.__store;
    }
};
