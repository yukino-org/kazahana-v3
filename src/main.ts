import { createApp } from "vue";
import App from "./App.vue";
import "./assets/main.css";

import Icon from "./plugins/icons";
import Router from "./plugins/router";
import Logger from "./plugins/logger";
import GlobalConstants, {
    GlobalConstantsProps,
} from "./plugins/api/globalConstants";
import { Initiator } from "./plugins/api/initiator";

const app = createApp(App);

const start = async () => {
    document.title = app_name;

    app.component("Icon", Icon);
    app.use(Router);

    app.config.globalProperties.$logger = Logger;
    app.config.globalProperties.$constants = await GlobalConstants.get();
    GlobalConstants.listen(handleGlobalConstantsChange);
    configureTheme(
        GlobalConstants.props.autoDetectTheme,
        GlobalConstants.props.isDarkTheme
    );

    app.mount("#app");

    const initiator = await Initiator.getClient();
    await initiator();
};

start();

declare global {
    const app_name: string;
    const app_platform: string;
    const app_version: string;
    const app_builtAt: number;

    interface Window {
        PlatformBridge?: any;
    }
}

declare module "@vue/runtime-core" {
    export interface ComponentCustomProperties {
        $logger: typeof Logger;
        $constants: typeof GlobalConstants;
    }
}

function handleGlobalConstantsChange(
    previous: GlobalConstantsProps,
    current: GlobalConstantsProps
) {
    if (
        current.autoDetectTheme !== previous.autoDetectTheme ||
        current.isDarkTheme !== previous.isDarkTheme
    ) {
        configureTheme(current.autoDetectTheme, current.isDarkTheme);
    }
}

function configureTheme(autoDetect: boolean, isDark: boolean) {
    const addDark = autoDetect
        ? window.matchMedia("(prefers-color-scheme: dark)").matches
        : isDark;

    if (addDark) {
        document.documentElement.classList.add("dark");
    } else {
        document.documentElement.classList.remove("dark");
    }
}
