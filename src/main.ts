import { createApp } from "vue";
import App from "./App.vue";
import "./assets/main.css";

import Icon from "./plugins/icons";
import Router from "./plugins/router";
import Logger from "./plugins/logger";
import GlobalConstants, {
    GlobalConstantsProps,
} from "./plugins/api/globalConstants";
import { Initiator, Debugger, DeepLink } from "./plugins/api";
import { util } from "./plugins/util";

const app = createApp(App);
let redirect: string | undefined;

const start = async () => {
    beforeApp();

    const started = Date.now();
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

    const debug = await Debugger.getClient();
    const initiator = await Initiator.getClient();
    await initiator();

    debug.debug("main", `App initiated in ${Date.now() - started}ms`);

    if (redirect) {
        console.log(redirect);
    }
};

start();

declare global {
    const app_name: string;
    const app_platform: string;
    const app_version: string;
    const app_builtAt: number;

    interface Window {
        PlatformBridge?: any;
        deepLinkListener(url: string): boolean;
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

function beforeApp() {
    console.log("%cApp Information", "text-decoration: underline");
    console.log(`Name: ${app_name}`);
    console.log(`Platform: ${app_platform}`);
    console.log(`Version: ${app_version}`);
    console.log(`Built at: ${util.prettyDate(new Date(app_builtAt))}`);

    DeepLink.set((url) => {
        const queries = url.split("?").pop();
        if (queries) {
            const params = new URLSearchParams(queries);
            const route = params.get("goto");
            if (route) {
                redirect = route;
            }
        }
    });
}
