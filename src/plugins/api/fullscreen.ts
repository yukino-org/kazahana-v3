export type FullScreenEntity = (immersive: boolean) => Promise<void>;

export const FullScreen = {
    __fullscreen: <FullScreenEntity | null>null,
    async getClient() {
        if (!this.__fullscreen) {
            switch (app_platform) {
                case "capacitor": {
                    const { StatusBar } = await import("@capacitor/status-bar");

                    this.__fullscreen = async (immersive) => {
                        if (immersive) {
                            await StatusBar.hide();
                        } else {
                            await StatusBar.show();
                        }
                    };
                }

                default:
                    break;
            }
        }

        return this.__fullscreen;
    },
};
