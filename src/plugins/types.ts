export interface LastWatchedEntity {
    title: string;
    episode: string;
    watched: number;
    total: number;
    updatedAt: number;
    route: {
        route: string;
        queries: Record<string, string>;
    };
    showPopup: boolean;
}
