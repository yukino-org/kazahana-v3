export type DeepLinkHandler = (url: string) => void;

let handler: DeepLinkHandler | undefined;

export const DeepLink = {
    get() {
        return handler;
    },
    set(fn: DeepLinkHandler) {
        handler = fn;
    },
    remove() {
        handler = undefined;
    },
};

window.deepLinkListener = (url) => {
    if (!handler) return false;
    handler(url);
    return true;
};

if (app_platform === "electron") {
    window.PlatformBridge.setDeepLinkListener((url: string) => {
        return window.deepLinkListener(url);
    });
}
