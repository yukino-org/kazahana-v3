import secrets from "../../../secrets/anilist";
import { http, Store } from "../../api";
import { Auth, AuthClient, TokenInfo } from "./auth";
import { StoreKeys } from "../../types";

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

export interface FuzzyDate {
    day: number;
    month: number;
    year: number;
}

export interface AnimeListEntity {
    userId: number;
    status: string;
    progress: number;
    startedAt: FuzzyDate;
    completedAt: FuzzyDate;
    media: {
        id: number;
        idMal: number;
        title: {
            userPreferred: string;
        };
        type: string;
        episodes: number | null;
        coverImage: {
            medium: string;
        };
        genres: string[];
        meanScore: number;
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
    status: StatusType;
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
    status: StatusType;
    progress: number;
    media: {
        id: number;
        idMal: number;
        title: {
            userPreferred: string;
        };
        episodes: number | null;
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
    episodes: number | null;
    genres: string[];
}

export interface MangaListEntity {
    userId: number;
    status: string;
    progress: number | null;
    progressVolumes: number | null;
    startedAt: FuzzyDate;
    completedAt: FuzzyDate;
    media: {
        id: number;
        idMal: number;
        title: {
            userPreferred: string;
        };
        type: string;
        chapters: number | null;
        volumes: number | null;
        coverImage: {
            medium: string;
        };
        genres: string[];
        meanScore: number;
        siteUrl: string;
    };
}

export interface MangaSearchEntity {
    id: number;
    idMal: number;
    title: {
        userPreferred: string;
    };
    coverImage: {
        medium: string;
    };
}

export interface MangaUpdateBody {
    status: StatusType;
    progress: number;
    progressVolumes: number;
}

export interface MangaUpdateResultEntity {
    status: string;
    score: number;
    num_episodes_watched: number;
    is_rewatching: boolean;
    updated_at: string;
    priority: number;
    num_times_rewatched: number;
    rewatch_value: number;
}

export interface GetMangaEntity {
    id: number;
    status: StatusType;
    progress: number | null;
    progressVolumes: number | null;
    media: {
        id: number;
        idMal: number;
        title: {
            userPreferred: string;
        };
        volumes: number | null;
        chapters: number | null;
    };
}

export interface GetMangaGenericEntity {
    id: number;
    idMal: number;
    title: {
        userPreferred: string;
    };
    coverImage: {
        medium: string;
    };
    chapters: number | null;
    volumes: number | null;
    genres: string[];
}

export const Status = [
    "CURRENT",
    "PLANNING",
    "COMPLETED",
    "DROPPED",
    "PAUSED",
    "REPEATING",
] as const;
export type StatusType = typeof Status[number];

export class MyAnimeListManager {
    webURL = "https://anilist.co";
    baseURL = "https://graphql.anilist.co";

    auth: Auth;
    cachedUser?: UserInfoEntity;

    constructor() {
        this.auth = new Auth({
            id: secrets.client_id,
        });
    }

    async initialize() {
        const store = await Store.getClient();
        const token: TokenInfo | null = await store.get(StoreKeys.aniListToken);

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
        await store.set(StoreKeys.aniListToken, this.auth.token);
    }

    async removeToken() {
        const store = await Store.getClient();
        await store.set(StoreKeys.aniListToken, null);
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
            `,
        });
        const user: UserInfoEntity | null =
            (res && JSON.parse(res)?.data?.Viewer) || null;
        if (user) this.cachedUser = user;
        return user;
    }

    async animelist(status?: StatusType, page: number = 0) {
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
                            startedAt {
                                day,
                                month,
                                year
                            },
                            completedAt {
                                day,
                                month,
                                year
                            },
                            media {
                                id,
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
                                siteUrl
                            }
                        }
                    }
                }
                `,
            variables: {
                userId: this.cachedUser?.id || (await this.userInfo())?.id,
                type: "ANIME",
                status: status || Status,
                page,
                perpage,
            },
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
                mediaId: id,
            },
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
                        episodes,
                        genres
                    }
                }
            `,
            variables: {
                mediaId: id,
            },
        });
        return <GetAnimeGenericEntity | null>(
            ((res && JSON.parse(res)?.data?.Media) || null)
        );
    }

    async updateAnime(id: number, body: Partial<AnimeUpdateBody>) {
        const res = await this.request({
            query: `
                mutation ($mediaId: Int, $progress: Int, $status: MediaListStatus) {
                    SaveMediaListEntry (mediaId: $mediaId, progress: $progress, status: $status) {
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
                mediaId: id,
                ...body,
            },
        });
        return <GetAnimeEntity | null>(
            ((res && JSON.parse(res)?.data?.SaveMediaListEntry) || null)
        );
    }

    async searchAnime(title: string) {
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
                type: "ANIME",
                page: 0,
                perPage: 20,
            },
        });
        return <AnimeSearchEntity[]>(
            ((res && JSON.parse(res)?.data?.Page?.media) || [])
        );
    }

    async mangalist(status?: StatusType, page: number = 0) {
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
                            progressVolumes,
                            startedAt {
                                day,
                                month,
                                year
                            },
                            completedAt {
                                day,
                                month,
                                year
                            },
                            media {
                                id,
                                idMal,
                                title {
                                    userPreferred
                                },
                                type,
                                chapters,
                                volumes,
                                coverImage {
                                    medium
                                },
                                genres,
                                meanScore,
                                siteUrl
                            }
                        }
                    }
                }
                `,
            variables: {
                userId: this.cachedUser?.id || (await this.userInfo())?.id,
                type: "MANGA",
                status: status || Status,
                page,
                perpage,
            },
        });
        return <MangaListEntity[]>(
            ((res && JSON.parse(res)?.data?.Page?.mediaList) || [])
        );
    }

    async getManga(id: number) {
        const res = await this.request({
            query: `
                query ($mediaId: Int, $userId: Int) {
                    MediaList (mediaId: $mediaId, userId: $userId) {
                        id,
                        status,
                        progress,
                        progressVolumes,
                        media {
                            id,
                            idMal,
                            title {
                                userPreferred
                            },
                            chapters,
                            volumes
                        }
                    }
                }
            `,
            variables: {
                userId: this.cachedUser?.id || (await this.userInfo())?.id,
                mediaId: id,
            },
        });
        return <GetMangaEntity | null>(
            ((res && JSON.parse(res)?.data?.MediaList) || null)
        );
    }

    async getMangaGeneric(id: number) {
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
                        chapters,
                        volumes,
                        genres
                    }
                }
            `,
            variables: {
                mediaId: id,
            },
        });
        return <GetMangaGenericEntity | null>(
            ((res && JSON.parse(res)?.data?.Media) || null)
        );
    }

    async updateManga(id: number, body: Partial<MangaUpdateBody>) {
        const res = await this.request({
            query: `
                mutation ($mediaId: Int, $progress: Int, $progressVolumes: Int, $status: MediaListStatus) {
                    SaveMediaListEntry (mediaId: $mediaId, progress: $progress, progressVolumes: $progressVolumes, status: $status) {
                        id,
                        status,
                        progress,
                        progressVolumes,
                        media {
                            id,
                            idMal,
                            title {
                                userPreferred
                            }
                        }
                    }
                }
            `,
            variables: {
                mediaId: id,
                ...body,
            },
        });
        return <GetMangaEntity | null>(
            ((res && JSON.parse(res)?.data?.SaveMediaListEntry) || null)
        );
    }

    async searchManga(title: string) {
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
                type: "MANGA",
                page: 0,
                perPage: 20,
            },
        });
        return <MangaSearchEntity[]>(
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
                    Accept: "application/json",
                },
                responseType: "text",
            });

            const parsed = JSON.parse(res);
            if (
                parsed.errors?.some((x: any) => x.message === "Invalid token")
            ) {
                this.logout();
                throw new Error("Session expired");
            }

            return res;
        } catch (err: any) {
            throw err;
        }
    }

    async logout() {
        this.auth.setToken(null);
        await this.removeToken();
    }
}

export default new MyAnimeListManager();
