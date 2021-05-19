const api: any = import.meta.env.VITE_PLATFORM === "electron" ? window.api : {};

export default {
    platform: import.meta.env.VITE_PLATFORM || "unknown",
    anime: {
        search: api.animeExt.search,
        info: api.animeExt.getAnimeInfo,
        top: api.animeExt.getTopAnime,
        topTypes: api.animeExt.getTopAnimeType,
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
        },
    },
};
