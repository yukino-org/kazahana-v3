import { createApp } from "vue";
import App from "./App.vue";
import "./assets/main.css";

import Icon from "./plugins/icons";
import Router from "./plugins/router";

const app = createApp(App);

app.component("Icon", Icon);

app.use(Router);

app.mount("#app");

declare global {
    interface Window {
        api: {
            animeExt: any;
            [s: string]: any;
        };
    }
}
