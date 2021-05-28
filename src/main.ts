import { createApp } from "vue";
import App from "./App.vue";
import "./assets/main.css";

import Icon from "./plugins/icons";
import Router from "./plugins/router";
import Logger from "./plugins/logger";

const app = createApp(App);

app.component("Icon", Icon);

app.use(Router);

app.config.globalProperties.$logger = new Logger();

app.mount("#app");

declare global {
    const app_platform: string;
    const app_version: string;

    interface Window {
        PlatformBridge?: any;
    }
}

declare module "@vue/runtime-core" {
    export interface ComponentCustomProperties {
        $logger: Logger;
    }
}
