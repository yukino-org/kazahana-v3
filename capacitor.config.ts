import { CapacitorConfig } from "@capacitor/cli";

const config: CapacitorConfig = {
    appId: "io.github.zyrouge.yukino",
    appName: "Yukino",
    webDir: "dist/capacitor/web",
    android: {
        path: "environments/capacitor/android",
    },
};

export default config;
