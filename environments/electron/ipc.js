const { shell, dialog } = require("electron");
const got = require("got").default;
const Store = require("./store");
const Logger = require("./logger");
const RPC = require("./rpc");

const http = {
    async get(url, options) {
        const res = await got.get(url, {
            headers: options.headers,
            timeout: options.timeout,
            responseType: "text",
        });

        return res.body;
    },
    async post(url, body, options) {
        const res = await got.post(url, {
            body,
            headers: options.headers,
            timeout: options.timeout,
            responseType: "text",
        });

        return res.body;
    },
};

/**
 * @param {import("electron").ipcMain} ipc
 */
module.exports = (ipc) => {
    ipc.handle("Store-Get", (e, key) => {
        return Store.store.get(key);
    });

    ipc.handle("Store-Set", (e, key, data) => {
        Store.store.set(key, data);
    });

    ipc.handle("Store-Clear", (e) => {
        Store.store.clear();
        return true;
    });

    ipc.handle("Rpc-Set", (e, act) => {
        RPC.setActivity(act);
    });

    Object.entries(http).forEach(([method, fn]) => {
        ipc.handle(`Request-${method}`, (e, ...args) => {
            return fn(...args);
        });
    });

    ipc.handle("Open-Externally", async (e, url) => {
        Logger.info(`Open external url: ${url}`);

        const resp = await dialog.showMessageBox(null, {
            title: "External Link",
            message: `Do you want to visit ${url} in your browser?`,
            type: "warning",
            buttons: ["Yes", "No"],
            defaultId: 1,
        });

        if (resp.response === 0) {
            Logger.info(`Opening external url: ${url}`);
            shell.openExternal(url);
        } else {
            Logger.info(`User aborted opening external url: ${url}`);
        }
    });
};
