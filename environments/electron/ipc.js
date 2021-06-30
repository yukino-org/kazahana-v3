const { shell, dialog } = require("electron");
const got = require("got").default;
const Store = require("./store");
const Logger = require("./logger");
const Rpc = require("./rpc");

/**
 * @type {import("../../src/plugins/api/requester/").Requester}
 */
const http = {
    async get(url, options) {
        const res = await got.get(url, {
            headers: options.headers,
            timeout: options.timeout,
            responseType: options.responseType
        });

        return res.body;
    },
    async post(url, body, options) {
        const res = await got.post(url, {
            body,
            headers: options.headers,
            timeout: options.timeout,
            responseType: options.responseType
        });

        return res.body;
    },
    async patch(url, body, options) {
        const res = await got.patch(url, {
            body,
            headers: options.headers,
            timeout: options.timeout,
            responseType: options.responseType
        });

        return res.body;
    },
    async put(url, body, options) {
        const res = await got.put(url, {
            body,
            headers: options.headers,
            timeout: options.timeout,
            responseType: options.responseType
        });

        return res.body;
    }
};

/**
 * @param {import("electron").ipcMain} ipc
 * @return {void}
 */
module.exports = ipc => {
    ipc.handle("Store-Get", (e, key) => {
        return Store.store.get(key) || null;
    });

    ipc.handle("Store-Set", (e, key, data) => {
        Store.store.set(key, data);
    });

    ipc.handle("Store-Clear", () => {
        Store.store.clear();
        return true;
    });

    ipc.handle("Store-All", () => {
        return Store.store.all();
    });

    ipc.handle("Rpc-Set", (e, act) => {
        Rpc.setActivity(act);
    });

    Object.entries(http).forEach(([method, fn]) => {
        ipc.handle(`Request-${method}`, (e, ...args) => {
            return fn(...args);
        });
    });

    ipc.handle("Open-Externally", async (e, url) => {
        Logger.debug("main", `Open external url: ${url}`);

        const resp = await dialog.showMessageBox(null, {
            title: "External Link",
            message: `Do you want to visit ${url} in your browser?`,
            type: "warning",
            buttons: ["Yes", "No"],
            defaultId: 1
        });

        if (resp.response === 0) {
            Logger.debug("main", `Opening external url: ${url}`);
            shell.openExternal(url);
        } else {
            Logger.debug("main", `User aborted opening external url: ${url}`);
        }
    });

    ipc.handle("Log", async (e, type, proc, txt) => {
        switch (type) {
            case "debug":
                Logger.debug(proc, txt, true);
                break;

            case "warn":
                Logger.warn(proc, txt, true);
                break;

            case "error":
                Logger.error(proc, txt, true);
                break;

            default:
                break;
        }
    });
};
