import { http, RequesterOptions } from "./requester";
import { util } from "../util";
import { Requester } from "anime-ext/dist/types";

import MALAnimeSearch, {
    SearchResult as MALSearchAnimeSearchResult
} from "anime-ext/dist/integrations/myanimelist/anime-search";
import MALMangaSearch, {
    SearchResult as MALSearchMangaSearchResult
} from "anime-ext/dist/integrations/myanimelist/manga-search";
import MALAnimeInfo, {
    InfoResult as MALAnimeInfoInfoResult
} from "anime-ext/dist/integrations/myanimelist/anime-info";
import MALMangaInfo, {
    InfoResult as MALMangaInfoInfoResult
} from "anime-ext/dist/integrations/myanimelist/manga-info";
import * as MALTopAnimes from "anime-ext/dist/integrations/myanimelist/top";
import * as MALSchedule from "anime-ext/dist/integrations/myanimelist/schedule";
import * as MALSeason from "anime-ext/dist/integrations/myanimelist/season";

import { AnimeExtractorModel } from "anime-ext/dist/extractors/anime/model";
import FourAnime from "anime-ext/dist/extractors/anime/4anime";
import GogoAnime from "anime-ext/dist/extractors/anime/gogoanime";
import SimplyMoeAnime from "anime-ext/dist/extractors/anime/simplydotmoe";
import TwistDotMoeAnime from "anime-ext/dist/extractors/anime/twistdotmoe";
import KawaiifuAnime from "anime-ext/dist/extractors/anime/kawaiifu";
import AnimeParadise from "anime-ext/dist/extractors/anime/animeparadise";
import TenshiMoe from "anime-ext/dist/extractors/anime/tenshidotmoe";

import {
    MangaExtractorConstructorOptions,
    MangaExtractorModel,
    MangaExtractorPageImageResult
} from "anime-ext/dist/extractors/manga/model";
import FanFoxManga from "anime-ext/dist/extractors/manga/fanfox";
import MangaDexManga from "anime-ext/dist/extractors/manga/mangadex";
import MangaInnManga from "anime-ext/dist/extractors/manga/mangainn";
import ReadM from "anime-ext/dist/extractors/manga/readm";
import MangaNato from "anime-ext/dist/extractors/manga/manganato";
import ManhwaTop from "anime-ext/dist/extractors/manga/manhwatop";

export interface ExtractorsEntity {
    integrations: {
        MyAnimeList: {
            searchAnime(term: string): Promise<MALSearchAnimeSearchResult[]>;
            searchManga(term: string): Promise<MALSearchMangaSearchResult[]>;
            getAnimeInfo(url: string): Promise<MALAnimeInfoInfoResult>;
            getMangaInfo(url: string): Promise<MALMangaInfoInfoResult>;
            getTopAnime(type: string): Promise<MALTopAnimes.TopResult[]>;
            getTopAnimeTypes(): Promise<string[]>;
            schedule(): Promise<MALSchedule.ScheduleResult[]>;
            season(): Promise<MALSeason.SeasonResult>;
        };
    };
    anime: Record<string, AnimeExtractorModel>;
    manga: Record<string, MangaExtractorModel>;
}

export interface OptionsEntity {
    http: Requester;
}

export const Extractors = {
    __extractor: <ExtractorsEntity | null>null,
    __options: <OptionsEntity | null>null,
    async getOptions() {
        if (!this.__options) {
            this.__options = {
                http: await http.getClient()
            };
        }

        return this.__options;
    },
    async getClient() {
        if (!this.__extractor) {
            const options = await this.getOptions();

            this.__extractor = {
                integrations: {
                    MyAnimeList: {
                        async searchAnime(terms) {
                            return MALAnimeSearch(terms, options);
                        },
                        async searchManga(terms) {
                            return MALMangaSearch(terms, options);
                        },
                        async getAnimeInfo(url) {
                            return MALAnimeInfo(url, options);
                        },
                        async getMangaInfo(url) {
                            return MALMangaInfo(url, options);
                        },
                        async getTopAnime(type) {
                            return MALTopAnimes.default(<any>type, options);
                        },
                        async getTopAnimeTypes() {
                            return ["all", ...MALTopAnimes.TopAnimeTypes];
                        },
                        async schedule() {
                            return MALSchedule.default(options);
                        },
                        async season() {
                            return MALSeason.default(options);
                        }
                    }
                },
                anime: {
                    "4Anime": new FourAnime(options),
                    GogoAnime: new GogoAnime(options),
                    SimplyMoe: new SimplyMoeAnime(options),
                    TwistMoe: new TwistDotMoeAnime(options),
                    Kawaiifu: new KawaiifuAnime(options),
                    AnimeParadise: new AnimeParadise(options),
                    TenshiMoe: new TenshiMoe(options)
                },
                manga: {
                    FanFox: new FanFoxManga(options),
                    MangaDex: new MangaDexManga(options),
                    MangaInn: new MangaInnManga(options),
                    ReadM: new (Mangab64Chapters(Mangab64Search(ReadM)))(
                        options
                    ),
                    MangaNato: new (Mangab64Chapters(MangaNato))(options),
                    ManhwaTop: new (Mangab64Chapters(
                        Mangab64Search(ManhwaTop)
                    ))(options)
                }
            };
        }

        return this.__extractor;
    }
};

type MangaModelClass = new (
    options: MangaExtractorConstructorOptions
) => MangaExtractorModel;
function Mangab64Search(cls: MangaModelClass) {
    return class extends cls {
        async search(url: string) {
            const res = await super.search(url);
            for (const key in res) {
                if (res.hasOwnProperty(key)) {
                    const img = res[key].thumbnail;
                    if (img && img.startsWith("http")) {
                        res[key].thumbnail = await getBase64Image(img, {
                            headers: {}
                        });
                    }
                }
            }
            return res;
        }
    };
}

function Mangab64Chapters(cls: MangaModelClass) {
    return class extends cls {
        async getChapterPages(url: string) {
            const res = await super.getChapterPages(url);
            res.type = "page_urls";
            return res;
        }

        async getPageImage(url: string, headers?: Record<string, string>) {
            return <MangaExtractorPageImageResult>{
                page: "-",
                image: await getBase64Image(url, {
                    headers: headers || {}
                })
            };
        }
    };
}

async function getBase64Image(
    url: string,
    options: Omit<RequesterOptions, "responseType">
) {
    try {
        const client = await http.getClient();
        const res = await client.get(url, {
            ...options,
            responseType: "buffer"
        });
        return `data:image/png;base64,${util.BufferToBase64(res)}`;
    } catch (err) {
        throw err;
    }
}
