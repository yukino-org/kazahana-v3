export interface LastLeftEntity {
    title: string;
    episode?: {
        episode: string;
        watched: number;
        total: number;
    };
    reading?: {
        volume: string;
        chapter: string;
        read: string;
        total: string;
    };
    updatedAt: number;
    route: {
        route: string;
        queries: Record<string, string>;
    };
    showPopup: boolean;
}

export interface RecentlyBrowsedEntity {
    terms: string;
    searchedAt: number;
    resultsFound: number;
    route: {
        route: string;
        queries: Record<string, string | string[]>;
    };
}

export interface RecentlyViewedEntity {
    title: string;
    image: string;
    plugin: string;
    viewedAt: number;
    route: {
        route: string;
        queries: Record<string, string>;
    };
}

export interface BookmarkedEntity {
    title: string;
    image: string;
    plugin: string;
    bookmarkedAt: number;
    route: {
        route: string;
        queries: Record<string, string | string[]>;
    };
}
