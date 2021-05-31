import { createApp } from "vue";
import App from "./App.vue";
import "./assets/main.css";

import Icon from "./plugins/icons";
import Router from "./plugins/router";
import Logger from "./plugins/logger";
import { Initiator } from "./plugins/api/initiator";

const app = createApp(App);

const start = async () => {
    document.title = app_name;

    app.component("Icon", Icon);
    app.use(Router);
    app.config.globalProperties.$logger = new Logger();
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
        $logger: Logger;
    }
}
