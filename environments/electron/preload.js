const { contextBridge, ipcRenderer } = require("electron");

let deepLinkListener, debuggerReceiver;

const PlatformBridge = {
    rpc: (act) => ipcRenderer.invoke("Rpc-Set", act),
    store: {
        get: (key) => ipcRenderer.invoke("Store-Get", key),
        set: (key, data) => ipcRenderer.invoke("Store-Set", key, data),
        clear: () => ipcRenderer.invoke("Store-Clear"),
    },
    http: {
        get: (url, options) => ipcRenderer.invoke("Request-get", url, options),
        post: (url, body, options) =>
            ipcRenderer.invoke("Request-post", url, body, options),
        patch: (url, body, options) =>
            ipcRenderer.invoke("Request-patch", url, body, options),
        put: (url, body, options) =>
            ipcRenderer.invoke("Request-put", url, body, options),
    },
    openExternalLink: (url) => ipcRenderer.invoke("Open-Externally", url),
    debugger: {
        debug: (proc, txt) => ipcRenderer.invoke("Log", "debug", proc, txt),
        warn: (proc, txt) => ipcRenderer.invoke("Log", "warn", proc, txt),
        error: (proc, txt) => ipcRenderer.invoke("Log", "error", proc, txt),
    },
    setDeepLinkListener(fn) {
        deepLinkListener = fn;
    },
    setDebuggerListener(dbug) {
        debuggerReceiver = dbug;
    },
    minimizeWindow: (url) => ipcRenderer.invoke("Minimize-Window", url),
    maximizeWindow: (url) => ipcRenderer.invoke("Maximize-Window", url),
    closeWindow: (url) => ipcRenderer.invoke("Close-Window", url),
    reloadWindow: (url) => ipcRenderer.invoke("Reload-Window", url),
    platform: process.platform,
};

contextBridge.exposeInMainWorld("PlatformBridge", PlatformBridge);

ipcRenderer.on("deeplink", (e, url) => {
    let emitted = false;
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
