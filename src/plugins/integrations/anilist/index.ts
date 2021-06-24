import secrets from "../../../secrets/anilist";
import { constants } from "../../util";
import { http, Store } from "../../api";
import { Auth, AuthClient, TokenInfo } from "./auth";

export interface MyAnimeListOptions {
    client: AuthClient;
}

export interface UserInfoEntity {
    id: number;
    name: string;
    avatar: {
        medium: string;
    };
}

export interface AnimeListEntity {
    userId: number;
    status: string;
    progress: number;
    media: {
        idMal: number;
        title: {
            userPreferred: string;
        };
        type: string;
        episodes: number;
        coverImage: {
            medium: string;
        };
        genres: string[];
        meanScore: number;
        updatedAt: number;
        siteUrl: string;
    };
}

export interface AnimeSearchEntity {
    id: number;
    idMal: number;
    title: {
        userPreferred: string;
    };
    coverImage: {
        medium: string;
    };
}

export interface AnimeUpdateBody {
    status: AnimeStatusType;
    progress: number;
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

export interface GetAnimeEntity {
    id: number;
    status: string;
    progress: number;
    media: {
        id: number;
        idMal: number;
        title: {
            userPreferred: string;
        };
        episodes: number;
    };
}

export interface GetAnimeGenericEntity {
    id: number;
    idMal: number;
    title: {
        userPreferred: string;
    };
    coverImage: {
        medium: string;
    };
    episodes: number;
    genres: string[];
}

export const AnimeStatus = [
    "CURRENT",
    "PLANNING",
    "COMPLETED",
    "DROPPED",
    "PAUSED",
    "REPEATING"
] as const;
export type AnimeStatusType = typeof AnimeStatus[number];

export class MyAnimeListManager {
    webURL = "https://anilist.co";
    baseURL = "https://graphql.anilist.co";

    auth: Auth;
    cachedUser?: UserInfoEntity;

    constructor() {
        this.auth = new Auth({
            id: secrets.client_id
        });
    }

    async initialize() {
        const store = await Store.getClient();
        const token: TokenInfo | null = await store.get(
            constants.storeKeys.aniListToken
        );

        if (token) {
            this.auth.setToken(token);
        }
    }

    isLoggedIn() {
        return this.auth.isValidToken();
    }

    async authenticate(token: TokenInfo) {
        const res = await this.auth.authorize(token);
        if (this.auth.token) await this.storeToken();
        return res;
    }

    async storeToken() {
        if (!this.auth.token) return false;

        const store = await Store.getClient();
        await store.set(constants.storeKeys.aniListToken, this.auth.token);
    }

    async removeToken() {
        const store = await Store.getClient();
        await store.set(constants.storeKeys.aniListToken, null);
    }

    async userInfo() {
        const res = await this.request({
            query: `
                {
                    Viewer {
                        id,
                        name,
                        avatar {
                            medium
                        }
                    }
                }
            `
        });
        const user: UserInfoEntity | undefined =
            res && JSON.parse(res)?.data?.Viewer;
        if (user) this.cachedUser = user;
        return user;
    }

    async getList(
        type: "ANIME" | "MANGA",
        status?: AnimeStatusType,
        page: number = 0
    ) {
        const perpage = 100;
        const res = await this.request({
            query: `
                query (
                    $userId: Int,
                    $type: MediaType,
                    $status: [MediaListStatus],
                    $page: Int,
                    $perpage: Int
                ) {
                    Page (page: $page, perPage: $perpage) {
                        mediaList (userId: $userId, type: $type, status_in: $status) {
                            userId,
                            status,
                            progress,
                            media {
                                idMal,
                                title {
                                    userPreferred
                                },
                                type,
                                episodes,
                                coverImage {
                                    medium
                                },
                                genres,
                                meanScore,
                                updatedAt,
                                siteUrl
                            }
                        }
                    }
                }
                `,
            variables: {
                userId: this.cachedUser?.id || (await this.userInfo())?.id,
                type,
                status: status || (type === "ANIME" ? AnimeStatus : []),
                page,
                perpage
            }
        });
        return <AnimeListEntity[]>(
            ((res && JSON.parse(res)?.data?.Page?.mediaList) || [])
        );
    }

    async getAnime(id: number) {
        const res = await this.request({
            query: `
                query ($mediaId: Int, $userId: Int) {
                    MediaList (mediaId: $mediaId, userId: $userId) {
                        id,
                        status,
                        progress,
                        media {
                            id,
                            idMal,
                            title {
                                userPreferred
                            },
                            episodes
                        }
                    }
                }
            `,
            variables: {
                userId: this.cachedUser?.id || (await this.userInfo())?.id,
                mediaId: id
            }
        });
        return <GetAnimeEntity | null>(
            ((res && JSON.parse(res)?.data?.MediaList) || null)
        );
    }

    async getAnimeGeneric(id: number) {
        const res = await this.request({
            query: `
                query ($mediaId: Int) {
                    Media (id: $mediaId) {
                        id,
                        idMal,
                        title {
                            userPreferred
                        }
                        coverImage {
                            medium
                        }
                        episodes
                        genres
                    }
                }
            `,
            variables: {
                mediaId: id
            }
        });
        return <GetAnimeGenericEntity | null>(
            ((res && JSON.parse(res)?.data?.Media) || null)
        );
    }

    async updateAnime(id: number, body: Partial<AnimeUpdateBody>) {
        const res = await this.request({
            query: `
                mutation ($mediaId: Int, $progress: Int) {
                    SaveMediaListEntry (mediaId: $mediaId, progress: $progress) {
                        id,
                        status,
                        progress,
                        media {
                            id,
                            idMal,
                            title {
                                userPreferred
                            },
                            episodes,
                            updatedAt
                        }
                    }
                }
            `,
            variables: {
                mediaId: id,
                ...body
            }
        });
        return <GetAnimeEntity | null>(
            ((res && JSON.parse(res)?.data?.SaveMediaListEntry) || null)
        );
    }

    async search(type: "ANIME" | "MANGA", title: string) {
        const res = await this.request({
            query: `
                query ($search: String, $type: MediaType, $page: Int, $perPage: Int) {
                    Page (page: $page, perPage: $perPage) {
                        media (search: $search, type: $type) {
                            id,
                            idMal,
                            title {
                                userPreferred
                            }
                            coverImage {
                                medium
                            }
                        }
                    }
                }
            `,
            variables: {
                search: title,
                type: type,
                page: 0,
                perPage: 20
            }
        });
        return <AnimeSearchEntity[]>(
            ((res && JSON.parse(res)?.data?.Page?.media) || [])
        );
    }

    async request(query?: any) {
        if (!this.auth.token) return false;

        try {
            const client = await http.getClient();
            const res = await client.post(this.baseURL, JSON.stringify(query), {
                headers: {
                    Authorization: `${this.auth.token.token_type} ${this.auth.token.access_token}`,
                    "Content-Type": "application/json",
                    Accept: "application/json"
                },
                responseType: "text"
            });

            const parsed = JSON.parse(res);
            if (
                parsed.errors?.some((x: any) => x.message === "Invalid token")
            ) {
                this.logout();
                throw new Error("Session expired");
            }

            return res;
        } catch (err) {
            console.log(err?.response);
            throw err;
        }
    }

    async logout() {
        this.auth.setToken(null);
        await this.removeToken();
    }
}

export default new MyAnimeListManager();
