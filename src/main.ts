import { createApp } from "vue";
import App from "./App.vue";
import "./assets/main.css";
import "swiper/swiper-bundle.min.css";

import Icon from "./plugins/icons";
import Router from "./plugins/router";
import Logger from "./plugins/logger";
import {
    Initiator,
    Debugger,
    DeepLink,
    Emitter,
    State,
    Store,
    StateUpdateState
} from "./plugins/api";
import { constants, util } from "./plugins/util";
import { GlobalStateProps, EventBus, StoreKeys } from "./plugins/types";

const app = createApp(App);

const start = async () => {
    beforeApp();

    const started = Date.now();
    document.title = app_name;

    app.component("Icon", Icon);
    app.use(Router);

    app.config.globalProperties.$logger = Logger;
    app.config.globalProperties.$state = await createGlobalState();
    app.config.globalProperties.$bus = new Emitter<EventBus>();

    app.config.globalProperties.$state.setDispatcher(
        (state: StateUpdateState<GlobalStateProps>) =>
            app.config.globalProperties.$bus.dispatch("state-update", state)
    );
    app.config.globalProperties.$bus.subscribe("state-update", stateSubscriber);
    configureTheme(
        app.config.globalProperties.$state.props.autoDetectTheme,
        app.config.globalProperties.$state.props.isDarkTheme
    );

    const debug = await Debugger.getClient();
    const initiator = await Initiator.getClient();
    await initiator();

    app.mount("#app");
    debug.debug("main", `App initiated in ${Date.now() - started}ms`);
};

start();

declare global {
    const app_name: string;
    const app_code: string;
    const app_platform: string;
    const app_os: string;
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
        $state: State<GlobalStateProps>;
        $bus: Emitter<EventBus>;
    }
}

async function createGlobalState() {
    const store = await Store.getClient();

    const settings = await store.get(StoreKeys.settings);

    const state = new State<GlobalStateProps>({
        autoDetectTheme:
            (settings?.autoDetectTheme ||
                constants.defaults.settings.autoDetectTheme) === "enabled",
        isDarkTheme:
            (settings?.darkMode || constants.defaults.settings.darkMode) ===
            "enabled",
        incognito:
            (settings?.incognito || constants.defaults.settings.incognito) ===
            "enabled",
        sideBar:
            settings?.sideBarPosition ||
            constants.defaults.settings.sideBarPosition,
        hideBottomBarText:
            (settings?.hideBottomBarText ||
                constants.defaults.settings.hideBottomBarText) === "enabled",
        compactBottomBar:
            (settings?.compactBottomBar ||
                constants.defaults.settings.compactBottomBar) === "enabled",
        bottomBarItemsCount:
            settings?.bottomBarItemsCount ||
            constants.defaults.settings.bottomBarItemsCount,
        runtime: Object.freeze({
            isAndroid: app_os === "android",
            isMac: app_os === "darwin",
            isWindows: app_os === "win32",
            isLinux: app_os === "linux",
            isElectron: app_platform === "electron",
            isCapacitor: app_platform === "capacitor"
        })
    });

    return state;
}

function stateSubscriber({
    previous,
    current
}: StateUpdateState<GlobalStateProps>) {
    if (
        current.autoDetectTheme !== previous.autoDetectTheme ||
        current.isDarkTheme !== previous.isDarkTheme
    ) {
        configureTheme(current.autoDetectTheme, current.isDarkTheme);
    }
}

function configureTheme(autoDetect: boolean, isDark: boolean) {
    const addDark = autoDetect
        ? window.matchMedia("(prefers-color-scheme: dark)").matches ||
          window.navigator.userAgent.includes("ExclusiveDarkUI")
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

    DeepLink.set(async url => {
        const dbug = await Debugger.getClient();
        dbug.debug("info", `Deeplink received: ${url}`);

        const exists = Router.resolve(`/${url}`);
        if (exists.matched.length > 0) {
            Router.push(`/${url}`);
        }
    });
}
