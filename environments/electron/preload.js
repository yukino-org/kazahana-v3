const { contextBridge, ipcRenderer } = require("electron");

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
    },
    openExternalLink: (url) => ipcRenderer.invoke("Open-Externally", url),
};

contextBridge.exposeInMainWorld("PlatformBridge", PlatformBridge);

document.addEventListener("DOMContentLoaded", () => {
    const minimizeBtn = document.getElementById("titlebar-minimize");
    const maximizeBtn = document.getElementById("titlebar-maximize");
    const closeBtn = document.getElementById("titlebar-close");
    const reloadBtn = document.getElementById("titlebar-reload");

    if (minimizeBtn)
        minimizeBtn.addEventListener("click", () => {
            ipcRenderer.invoke("minimize-window");
        });

    if (maximizeBtn)
        maximizeBtn.addEventListener("click", () => {
            ipcRenderer.invoke("toggle-maximize-window");
        });

    if (closeBtn)
        closeBtn.addEventListener("click", () => {
            ipcRenderer.invoke("close-window");
        });

    if (reloadBtn)
        reloadBtn.addEventListener("click", () => {
            ipcRenderer.invoke("reload-window");
        });
});
