const api: any = platform === "electron" ? window.api : null;

export default {
    version: app_version,
    rpc: (act: {
        details?: string;
        state?: string;
        buttons?: {
            label: string;
            url: string;
        }[];
    }) => api.rpc?.(act),
    store: {
        set(key: string, data: any) {
            return api.store.set(key, data);
        },
        get(key: string) {
            return api.store.get(key);
        },
    },
    intergrations: {
        MyAnimeList: {
            search: api.animeExt.intergrations.MyAnimeList.search,
            info: api.animeExt.intergrations.MyAnimeList.getAnimeInfo,
            top: api.animeExt.intergrations.MyAnimeList.getTopAnime,
            topTypes: api.animeExt.intergrations.MyAnimeList.getTopAnimeType,
        },
    },
    anime: {
        extractors: {
            all() {
                return api.animeExt.extractors.anime.extractors.all();
            },
            search(plugin: string, terms: string) {
                return api.animeExt.extractors.anime.extractors.search(
                    plugin,
                    terms
                );
            },
            info(plugin: string, url: string) {
                return api.animeExt.extractors.anime.extractors.info(
                    plugin,
                    url
                );
            },
            links(plugin: string, url: string) {
                return api.animeExt.extractors.anime.extractors.links(
                    plugin,
                    url
                );
            },
        },
    },
    manga: {
        extractors: {
            all() {
                return api.animeExt.extractors.manga.extractors.all();
            },
            search(plugin: string, terms: string) {
                return api.animeExt.extractors.manga.extractors.search(
                    plugin,
                    terms
                );
            },
            info(plugin: string, url: string) {
                return api.animeExt.extractors.manga.extractors.info(
                    plugin,
                    url
                );
            },
            pages(plugin: string, url: string) {
                return api.animeExt.extractors.manga.extractors.pages(
                    plugin,
                    url
                );
            },
            pageImage(plugin: string, url: string) {
                return api.animeExt.extractors.manga.extractors.pageImage(
                    plugin,
                    url
                );
            },
        },
    },
    openExternalUrl(url: string) {
        switch (platform) {
            case "electron":
                window.api.openExternalLink(url);
                break;

            default:
                window.open(url, "_blank")?.focus();
                break;
        }
    },
};
