const { shell, dialog } = require("electron");
const Store = require("./store");
const Logger = require("./logger");
const RPC = require("./rpc");
const { version } = require("../../package.json");

const MALSearchAnime =
    require("anime-ext/dist/integrations/myanimelist/search-anime").default;
const MALAnimeInfo =
    require("anime-ext/dist/integrations/myanimelist/anime-info").default;
const {
    default: MALTopAnimes,
    TopAnimeTypes: MALTopAnimeTypes,
} = require("anime-ext/dist/integrations/myanimelist/top");

const FourAnime = require("anime-ext/dist/extractors/anime/4anime").default;
const GogoAnime = require("anime-ext/dist/extractors/anime/gogoanime").default;
const GogoStreamAnime =
    require("anime-ext/dist/extractors/anime/gogostream").default;
const SimplyMoeAnime =
    require("anime-ext/dist/extractors/anime/simplydotmoe").default;
const TwistDotMoeAnime =
    require("anime-ext/dist/extractors/anime/twistdotmoe").default;

const FanFoxManga = require("anime-ext/dist/extractors/manga/fanfox").default;

const options = {
    logger: Logger,
};

/**
 * @param {(...args: any[]) => any} fn
 * @returns {any}
 */
const getResultOrError = async (fn) => {
    try {
        const data = await fn();
        return {
            data,
        };
    } catch (err) {
        return {
            err: err.toString(),
        };
    }
};

/**
 * @param {import("electron").ipcMain} ipc
 */
module.exports = (ipc) => {
    ipc.handle("Yukino-Version", (e) => {
        return version || "0.0.0";
    });

    ipc.handle("Store-Get", (e, key) => {
        return Store.store.get(key);
    });

    ipc.handle("Store-Set", (e, key, data) => {
        Store.store.set(key, data);
    });

    ipc.handle("Rpc-Set", (e, act) => {
        RPC.setActivity(act);
    });

    const extractors = {
        anime: {
            "4Anime": new FourAnime(options),
            GogoAnime: new GogoAnime(options),
            GogoStream: new GogoStreamAnime(options),
            SimplyMoe: new SimplyMoeAnime(options),
            TwistMoe: new TwistDotMoeAnime(options),
        },
        manga: {
            FanFoxManga: new FanFoxManga(options),
        },
    };

    ipc.handle("MAL-Search", (e, terms) => {
        return getResultOrError(() => MALSearchAnime(terms, options));
    });

    ipc.handle("MAL-AnimeInfo", (e, url) => {
        return getResultOrError(() => MALAnimeInfo(url, options));
    });

    ipc.handle("MAL-TopAnimes", (e, type) => {
        return getResultOrError(() => MALTopAnimes(type, options));
    });

    ipc.handle("MAL-TopAnimesTypes", (e) => {
        return ["all", ...MALTopAnimeTypes];
    });

    ipc.handle("Anime-All-Sources", (e) => {
        return Object.keys(extractors.anime);
    });

    Object.entries(extractors.anime).forEach(([plugin, client]) => {
        ipc.handle(`Anime-${plugin}-Search`, (e, terms) => {
            return getResultOrError(() => client.search(terms));
        });

        ipc.handle(`Anime-${plugin}-Info`, (e, url) => {
            return getResultOrError(() => client.getInfo(url));
        });

        ipc.handle(`Anime-${plugin}-DownloadLinks`, (e, url) => {
            return getResultOrError(() => client.getDownloadLinks(url));
        });
    });

    ipc.handle("Manga-All-Sources", (e) => {
        return Object.keys(extractors.manga);
    });

    Object.entries(extractors.manga).forEach(([plugin, client]) => {
        ipc.handle(`Manga-${plugin}-Search`, (e, terms) => {
            return getResultOrError(() => client.search(terms));
        });

        ipc.handle(`Manga-${plugin}-Info`, (e, url) => {
            return getResultOrError(() => client.getInfo(url));
        });

        ipc.handle(`Manga-${plugin}-Pages`, (e, url) => {
            return getResultOrError(() => client.getChapterPageImages(url));
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
