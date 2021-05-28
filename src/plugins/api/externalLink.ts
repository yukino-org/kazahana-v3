export type ExternalLinkEntity = (url: string) => Promise<void>;

export const ExternalLink = {
    __opener: <ExternalLinkEntity | null>null,
    async getClient() {
        if (!this.__opener) {
            switch (app_platform) {
                case "electron":
                    this.__opener = window.PlatformBridge.openExternalLink;
                    break;

                default:
                    break;
            }
        }

        return this.__opener;
    },
};
