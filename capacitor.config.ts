/// <reference types="@capacitor/splash-screen" />

import { CapacitorConfig } from "@capacitor/cli";

const config: CapacitorConfig = {
    appId: "io.github.zyrouge.yukino",
    appName: "Yukino",
    webDir: "dist/capacitor/web",
    android: {
        path: "environments/capacitor/android",
    },
    plugins: {
        SplashScreen: {
            androidScaleType: "CENTER_CROP",
            launchAutoHide: false,
            splashImmersive: false,
            splashFullScreen: false,
            backgroundColor: "#ffffffff",
            showSpinner: false,
        },
    },
};

export default config;
