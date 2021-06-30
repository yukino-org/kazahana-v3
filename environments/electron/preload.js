const { contextBridge, ipcRenderer } = require("electron");

/**
 * @callback DeepLinkListener
 * @param {string} url
 * @returns {boolean}
 */

/**
 * @type {DeepLinkListener | undefined}
 */
let deepLinkListener,
    /**
     * @type {import("../../src/plugins/api/debugger").DebuggerEntity | undefined}
     */
    debuggerReceiver;

const PlatformBridge = {
    /**
     * @param {import("./rpc").Activity} act
     * @returns {void}
     */
    rpc(act) {
        return ipcRenderer.invoke("Rpc-Set", act);
    },

    /**
     * @type {import("../../src/plugins/api/store").StoreEntity}
     */
    store: {
        get(key) {
            return ipcRenderer.invoke("Store-Get", key);
        },
        set(key, data) {
            return ipcRenderer.invoke("Store-Set", key, data);
        },
        clear() {
            return ipcRenderer.invoke("Store-Clear");
        },
        all() {
            return ipcRenderer.invoke("Store-All");
        }
    },

    /**
     * @type {import("../../src/plugins/api/requester").Requester}
     */
    http: {
        get(url, options) {
            return ipcRenderer.invoke("Request-get", url, options);
        },
        post(url, body, options) {
            return ipcRenderer.invoke("Request-post", url, body, options);
        },
        patch(url, body, options) {
            return ipcRenderer.invoke("Request-patch", url, body, options);
        },
        put(url, body, options) {
            return ipcRenderer.invoke("Request-put", url, body, options);
        }
    },

    /**
     * @param {string} url
     * @returns {void}
     */
    openExternalLink(url) {
        return ipcRenderer.invoke("Open-Externally", url);
    },

    /**
     * @type {import("../../src/plugins/api/debugger").DebuggerEntity}
     */
    debugger: {
        debug(proc, txt) {
            return ipcRenderer.invoke("Log", "debug", proc, txt);
        },
        warn(proc, txt) {
            return ipcRenderer.invoke("Log", "warn", proc, txt);
        },
        error(proc, txt) {
            return ipcRenderer.invoke("Log", "error", proc, txt);
        }
    },

    /**
     * @param {DeepLinkListener | undefined} fn
     * @returns {void}
     */
    setDeepLinkListener(fn) {
        deepLinkListener = fn;
    },

    /**
     * @param {import("../../src/plugins/api/debugger").DebuggerEntity | undefined} dbug
     * @returns {void}
     */
    setDebuggerListener(dbug) {
        debuggerReceiver = dbug;
    },

    /**
     * @returns {void}
     */
    minimizeWindow() {
        return ipcRenderer.invoke("Minimize-Window");
    },

    /**
     * @returns {void}
     */
    maximizeWindow() {
        return ipcRenderer.invoke("Maximize-Window");
    },

    /**
     * @returns {void}
     */
    closeWindow() {
        return ipcRenderer.invoke("Close-Window");
    },

    /**
     * @returns {void}
     */
    reloadWindow() {
        return ipcRenderer.invoke("Reload-Window");
    }
};

contextBridge.exposeInMainWorld("PlatformBridge", PlatformBridge);

ipcRenderer.on("deeplink", (e, url) => {
    let emitted = false;

    /**
     * @returns {boolean}
     */
    const emit = () => {
        if (emitted) return true;
        if (!deepLinkListener) return false;

        const success = deepLinkListener(url);
        return success;
    };

    emitted = emit();
    if (!emitted) {
        const retrier = setInterval(() => {
            emitted = emit();
            if (emitted) clearInterval(retrier);
        }, 1000);
    }
});

ipcRenderer.on("Electron-Log", (e, type, proc, txt) => {
    if (debuggerReceiver && debuggerReceiver[type]) {
        debuggerReceiver[type](proc, txt);
    }
});
