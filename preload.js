const { contextBridge, ipcRenderer } = require("electron");

const api = {
    versions: {
        chrome: process.versions.chrome,
        node: process.versions.node,
        electron: process.versions.electron,
    },
    animeExt: {
        async search(terms) {
            return await ipcRenderer.invoke("MAL-Search", terms);
        },
        async getAnimeInfo(url) {
            return ipcRenderer.invoke("MAL-AnimeInfo", url);
        },
    },
    openExternalLink(url) {
        return ipcRenderer.invoke("Open-Externally", url);
    },
};

contextBridge.exposeInMainWorld("api", api);
