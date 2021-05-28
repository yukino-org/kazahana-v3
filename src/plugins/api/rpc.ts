export type RpcEntity = (act: any) => void;

export const Rpc = {
    __rpc: <RpcEntity | null>null,
    async getClient() {
        if (!this.__rpc) {
            switch (app_platform) {
                case "electron":
                    this.__rpc = window.PlatformBridge.rpc;
                    break;

                default:
                    break;
            }
        }

        return this.__rpc;
    },
};
