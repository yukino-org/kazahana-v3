import { SecureStoragePlugin } from "capacitor-secure-storage-plugin";
import { StoreEntity } from "./";

export const Store: StoreEntity = {
    async get(key) {
        try {
            const { value } = await SecureStoragePlugin.get({
                key,
            });
            return value ? JSON.parse(value) : null;
        } catch (err) {
            return null;
        }
    },
    async set(key, value) {
        try {
            await SecureStoragePlugin.set({
                key,
                value: JSON.stringify(value),
            });
        } catch (err) {}
    },
    async clear() {
        try {
            const { value } = await SecureStoragePlugin.clear();
            return value;
        } catch (err) {
            return false;
        }
    },
    async all() {
        const { value: keys } = await SecureStoragePlugin.keys();
        const all: Record<string, any> = {};
        for (const key of keys) {
            all[key] = await this.get(key);
        }
        return all;
    },
};
