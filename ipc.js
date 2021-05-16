const { shell } = require("electron");
const MALSearchAnime =
    require("anime-ext/lib/integrations/myanimelist/search-anime").default;
const MALAnimeInfo =
    require("anime-ext/lib/integrations/myanimelist/anime-info").default;

const allowedOrigins = ["https://myanimelist.net"];

const isDev = process.env.NODE_ENV === "development";

/**
 * @type {import("anime-ext/lib/types").Logger | null}
 */
const logger = isDev
    ? {
          info: console.log,
          debug: console.log,
          error: console.error,
      }
    : null;

const options = { logger };

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
    ipc.handle("MAL-Search", (e, terms) => {
        return getResultOrError(() => MALSearchAnime(terms, options));
    });

    ipc.handle("MAL-AnimeInfo", (e, url) => {
        return getResultOrError(() => MALAnimeInfo(url, options));
    });

    ipc.handle("Open-Externally", (e, url) => {
        if (allowedOrigins.some((x) => url.indexOf(x) === 0)) {
            shell.openExternal(url);
        }
    });
};
