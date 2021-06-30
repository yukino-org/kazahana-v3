export interface FullScreenEntity {
    set(setFullScreen: boolean): Promise<void>;
    isFullscreened(): Promise<boolean>;
}

export const FullScreen = {
    __fullscreen: <FullScreenEntity | null>null,
    async getClient() {
        if (!this.__fullscreen) {
            switch (app_platform) {
                case "capacitor": {
                    const { StatusBar } = await import("@capacitor/status-bar");

                    this.__fullscreen = {
                        async set(setFullScreen) {
                            if (setFullScreen) {
                                await StatusBar.hide();
                            } else {
                                await StatusBar.show();
                            }
                        },
                        async isFullscreened() {
                            const stat = await StatusBar.getInfo();
                            return !stat.visible;
                        }
                    };
                }

                default:
                    break;
            }
        }

        return this.__fullscreen;
    }
};
