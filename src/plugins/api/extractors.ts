import { http } from "./requester";
import { Requester } from "anime-ext/dist/types";

import MALSearchAnime, {
    SearchResult as MALSearchAnimeSearchResult,
} from "anime-ext/dist/integrations/myanimelist/search-anime";
import MALAnimeInfo, {
    InfoResult as MALAnimeInfoInfoResult,
} from "anime-ext/dist/integrations/myanimelist/anime-info";
import * as MALTopAnimes from "anime-ext/dist/integrations/myanimelist/top";
import * as MALSchedule from "anime-ext/dist/integrations/myanimelist/schedule";
import * as MALSeason from "anime-ext/dist/integrations/myanimelist/season";

import { AnimeExtractorModel } from "anime-ext/dist/extractors/anime/model";
import FourAnime from "anime-ext/dist/extractors/anime/4anime";
import GogoAnime from "anime-ext/dist/extractors/anime/gogoanime";
import GogoStreamAnime from "anime-ext/dist/extractors/anime/gogostream";
import SimplyMoeAnime from "anime-ext/dist/extractors/anime/simplydotmoe";
import TwistDotMoeAnime from "anime-ext/dist/extractors/anime/twistdotmoe";
import KawaiifuAnime from "anime-ext/dist/extractors/anime/kawaiifu";
import TenshiDotMoeAnime from "anime-ext/dist/extractors/anime/tenshidotmoe";
import AnimeParadise from "anime-ext/dist/extractors/anime/animeparadise";

import { MangaExtractorModel } from "anime-ext/dist/extractors/manga/model";
import FanFoxManga from "anime-ext/dist/extractors/manga/fanfox";
import MangaDexManga from "anime-ext/dist/extractors/manga/mangadex";
import MangaInnManga from "anime-ext/dist/extractors/manga/mangainn";
import ReadM from "anime-ext/dist/extractors/manga/readm";

export interface ExtractorsEntity {
    integrations: {
        MyAnimeList: {
            search(term: string): Promise<MALSearchAnimeSearchResult[]>;
            getAnimeInfo(url: string): Promise<MALAnimeInfoInfoResult>;
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
                http: await http.getClient(),
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
                        async search(terms) {
                            return MALSearchAnime(terms, options);
                        },
                        async getAnimeInfo(url) {
                            return MALAnimeInfo(url, options);
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
                        },
                    },
                },
                anime: {
                    "4Anime": new FourAnime(options),
                    GogoAnime: new GogoAnime(options),
                    GogoStream: new GogoStreamAnime(options),
                    SimplyMoe: new SimplyMoeAnime(options),
                    TwistMoe: new TwistDotMoeAnime(options),
                    Kawaiifu: new KawaiifuAnime(options),
                    TenshiMoe: new TenshiDotMoeAnime(options),
                    AnimeParadise: new AnimeParadise(options),
                },
                manga: {
                    FanFox: new FanFoxManga(options),
                    MangaDex: new MangaDexManga(options),
                    MangaInn: new MangaInnManga(options),
                    // ReadM: new ReadM(options),
                },
            };
        }

        return this.__extractor;
    },
};
