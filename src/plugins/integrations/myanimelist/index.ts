import qs from "qs";
import secrets from "../../../secrets/myanimelist";
import { http, RequesterOptions, Store } from "../../api";
import { Auth, AuthClient, TokenInfo } from "./auth";
import Logger from "../../logger";
import { StoreKeys } from "../../types";

export interface MyAnimeListOptions {
    client: AuthClient;
}

export interface UserInfoEntity {
    id: number;
    name: string;
    location: string;
    joined_at: string;
}

export interface AnimeListEntity {
    data: {
        node: {
            id: number;
            title: string;
            main_picture: {
                medium: string;
                large: string;
            };
        };
        list_status: {
            status: string;
            score: number;
            num_episodes_watched: number;
            is_rewatching: boolean;
            updated_at: string;
        };
    }[];
    paging: {
        next: string;
    };
}

export interface AnimeEntity {
    id: number;
    title: string;
    my_list_status?: {
        status: string;
        score: number;
        num_episodes_watched: number;
        is_rewatching: boolean;
        updated_at: string;
    };
    num_episodes: number;
}

export interface AnimeUpdateBody {
    status: AnimeStatusType;
    score: number;
    num_watched_episodes: number;
}

export interface AnimeUpdateResultEntity {
    status: string;
    score: number;
    num_episodes_watched: number;
    is_rewatching: boolean;
    updated_at: string;
    priority: number;
    num_times_rewatched: number;
    rewatch_value: number;
}

export const AnimeStatus = [
    "watching",
    "completed",
    "on_hold",
    "dropped",
    "plan_to_watch",
] as const;
export type AnimeStatusType = typeof AnimeStatus[number];

export interface MangaListEntity {
    data: {
        node: {
            id: number;
            title: string;
            main_picture: {
                medium: string;
                large: string;
            };
        };
        list_status: {
            status: string;
            is_rereading: boolean;
            num_volumes_read: number;
            num_chapters_read: number;
            score: number;
            updated_at: string;
        };
    }[];
    paging: {
        next: string;
    };
}

export interface MangaEntity {
    id: number;
    title: string;
    my_list_status?: {
        status: string;
        score: number;
        num_chapters_read: number;
        num_volumes_read: number;
        is_rereading: boolean;
        updated_at: string;
    };
    num_volumes: number;
    num_chapters: number;
}

export interface MangaUpdateBody {
    status: MangaStatusType;
    score: number;
    num_volumes_read: number;
    num_chapters_read: number;
}

export interface MangaUpdateResultEntity {
    status: string;
    score: number;
    num_volumes_read: number;
    num_chapters_read: number;
    is_rereading: boolean;
    updated_at: string;
    priority: number;
    num_times_reread: number;
    reread_value: number;
}

export const MangaStatus = [
    "reading",
    "completed",
    "on_hold",
    "dropped",
    "plan_to_read",
] as const;
export type MangaStatusType = typeof MangaStatus[number];

export class MyAnimeListManager {
    webURL = "https://myanimelist.net";
    baseURL = "https://api.myanimelist.net/v2";

    auth: Auth;

    constructor() {
        this.auth = new Auth({
            id: secrets.client_id,
            redirect: secrets.callback,
        });
    }

    async initialize() {
        const store = await Store.getClient();
        const token: TokenInfo | null = await store.get(
            StoreKeys.myAnimeListToken
        );

        if (token) {
            this.auth.setToken(token);
            if (!this.auth.isValidToken()) {
                const res = await this.auth.refreshToken();
                if (!res.success && res.error?.includes("401")) {
                    Logger.emit("warn", "MyAnimeList session has expired");
                    await this.removeToken();
                }
            }
        }
    }

    isLoggedIn() {
        return this.auth.isValidToken();
    }

    async authenticate(code: string) {
        const res = await this.auth.getToken(code);
        if (this.auth.token) await this.storeToken();
        return res;
    }

    async storeToken() {
        if (!this.auth.token) return false;

        const store = await Store.getClient();
        await store.set(StoreKeys.myAnimeListToken, this.auth.token);
    }

    async removeToken() {
        const store = await Store.getClient();
        await store.set(StoreKeys.myAnimeListToken, null);
    }

    async userInfo() {
        const res = await this.request("get", "/users/@me");
        return <UserInfoEntity | null>((res && JSON.parse(res)) || null);
    }

    async animelist(status?: AnimeStatusType, page: number = 0) {
        const perpage = 100;
        const res = await this.request(
            "get",
            `/users/@me/animelist?fields=list_status&sort=list_updated_at&limit=${perpage}&offset=${
                perpage * page
            }${status ? `&status=${status}` : ""}`
        );
        return <AnimeListEntity | null>((res && JSON.parse(res)) || null);
    }

    async getAnime(id: string) {
        const res = await this.request(
            "get",
            `/anime/${id}?fields=id,title,my_list_status,num_episodes`
        );
        return <AnimeEntity | null>(res && JSON.parse(res));
    }

    async updateAnime(id: string, body: Partial<AnimeUpdateBody>) {
        const res = await this.request(
            "put",
            `/anime/${id}/my_list_status`,
            body
        );
        return <AnimeUpdateResultEntity | null>(
            ((res && JSON.parse(res)) || null)
        );
    }

    async searchAnime(title: string) {
        const res = await this.request("get", `/anime?q=${title}&limit=10`);
        return <AnimeListEntity | null>(res && JSON.parse(res));
    }

    async mangalist(status?: MangaStatusType, page: number = 0) {
        const perpage = 100;
        const res = await this.request(
            "get",
            `/users/@me/mangalist?fields=list_status&sort=list_updated_at&limit=${perpage}&offset=${
                perpage * page
            }${status ? `&status=${status}` : ""}`
        );
        return <MangaListEntity | null>((res && JSON.parse(res)) || null);
    }

    async getManga(id: string) {
        const res = await this.request(
            "get",
            `/manga/${id}?fields=id,title,my_list_status,num_volumes,num_chapters`
        );
        return <MangaEntity | null>(res && JSON.parse(res));
    }

    async updateManga(id: string, body: Partial<MangaUpdateBody>) {
        const res = await this.request(
            "put",
            `/manga/${id}/my_list_status`,
            body
        );
        return <MangaUpdateResultEntity | null>(
            ((res && JSON.parse(res)) || null)
        );
    }

    async searchManga(title: string) {
        const res = await this.request("get", `/manga?q=${title}&limit=10`);
        return <MangaListEntity | null>(res && JSON.parse(res));
    }

    request(type: "get", url: string): Promise<false | string>;
    request(
        type: "post" | "patch" | "put",
        url: string,
        body: any
    ): Promise<false | string>;
    async request(
        type: "get" | "post" | "patch" | "put",
        url: string,
        body?: any
    ) {
        if (!this.auth.token) return false;

        url = encodeURI(`${this.baseURL}${url}`);
        const options: RequesterOptions & {
            responseType: "text";
        } = {
            headers: {
                Authorization: `${this.auth.token.token_type} ${this.auth.token.access_token}`,
            },
            responseType: "text",
        };
        if (body) {
            options.headers["Content-Type"] =
                "application/x-www-form-urlencoded";
            body = qs.stringify(body);
        }

        const client = await http.getClient();
        let res: string;
        try {
            switch (type) {
                case "get":
                    res = await client[type](url, options);
                    break;

                case "post":
                case "patch":
                case "put":
                    res = await client[type](url, body, options);
                    break;
            }
        } catch (err: any) {
            if (
                typeof err?.message === "string" &&
                (<string>err.message).includes("401")
            ) {
                this.auth.refreshToken();
                // @ts-ignore
                return this.request(type, url, body);
            }

            throw err;
        }

        return res;
    }

    async logout() {
        this.auth.setToken(null);
        await this.removeToken();
    }
}

export default new MyAnimeListManager();
