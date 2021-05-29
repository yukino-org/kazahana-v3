export type ExternalLinkEntity = (url: string) => Promise<void>;

export const ExternalLink = {
    __opener: <ExternalLinkEntity | null>null,
    async getClient() {
        if (!this.__opener) {
            switch (app_platform) {
                case "electron":
                    this.__opener = window.PlatformBridge.openExternalLink;
                    break;

                case "capacitor": {
                    const { Browser } = await import("@capacitor/browser");
                    this.__opener = (url: string) => Browser.open({ url });
                }

                default:
                    break;
            }
        }

        return this.__opener;
    },
};
