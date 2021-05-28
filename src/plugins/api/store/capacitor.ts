import { SecureStoragePlugin } from "capacitor-secure-storage-plugin";
import { StoreEntity } from "./";

export const Store: StoreEntity = {
    async get(key) {
        try {
            const { value } = await SecureStoragePlugin.get({
                key,
            });
            return JSON.parse(value);
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
};
