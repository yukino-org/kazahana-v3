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
        extractors: {
            anime: {
                extractors: {
                    all() {
                        return ipcRenderer.invoke("Anime-All-Sources");
                    },
                    search(plugin, terms) {
                        return ipcRenderer.invoke(
                            `Anime-${plugin}-Search`,
                            terms
                        );
                    },
                    info(plugin, url) {
                        return ipcRenderer.invoke(`Anime-${plugin}-Info`, url);
                    },
                    links(plugin, url) {
                        return ipcRenderer.invoke(
                            `Anime-${plugin}-DownloadLinks`,
                            url
                        );
                    },
                },
            },
            manga: {
                extractors: {
                    all() {
                        return ipcRenderer.invoke("Manga-All-Sources");
                    },
                    search(plugin, terms) {
                        return ipcRenderer.invoke(
                            `Manga-${plugin}-Search`,
                            terms
                        );
                    },
                    info(plugin, url) {
                        return ipcRenderer.invoke(`Manga-${plugin}-Info`, url);
                    },
                    pages(plugin, url) {
                        return ipcRenderer.invoke(`Manga-${plugin}-Pages`, url);
                    },
                },
            },
        },
    },
    openExternalLink(url) {
        return ipcRenderer.invoke("Open-Externally", url);
    },
};

contextBridge.exposeInMainWorld("api", api);
