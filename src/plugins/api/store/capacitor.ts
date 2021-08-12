import { SecureStoragePlugin } from "capacitor-secure-storage-plugin";
import { StoreEntity, StoreAllType } from "./";
import { StoreKeys, StoreStructure } from "../../types";

export const Store: StoreEntity<StoreStructure> = {
    async get(key) {
        try {
            const { value } = await SecureStoragePlugin.get({
                key,
            });
            return value ? JSON.parse(value) : null;
        } catch (err: any) {
            return null;
        }
    },
    async set(key, value) {
        try {
            await SecureStoragePlugin.set({
                key,
                value: JSON.stringify(value),
            });
        } catch (err: any) {}
    },
    async clear() {
        try {
            const { value } = await SecureStoragePlugin.clear();
            return value;
        } catch (err: any) {
            return false;
        }
    },
    async all() {
        const keys: (keyof StoreStructure)[] = Object.keys(StoreKeys) as any;

        const all: Partial<StoreAllType<StoreStructure>> = {};
        for (const key of keys) {
            // @ts-ignore
            all[key] = await this.get(key);
        }

        return <StoreAllType<StoreStructure>>all;
    },
};
