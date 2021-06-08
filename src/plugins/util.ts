export type Await<T> = T extends Promise<infer U> ? U : T;

export type StateStates = "waiting" | "resolving" | "resolved" | "failed";

export interface StateController<T> {
    state: StateStates;
    data: T | null;
}

export interface StateControllerNoNull<T> {
    state: StateStates;
    data: T;
}

export const constants = {
    storeKeys: {
        recentlyBrowsed: "recently_browsed",
        recentlyViewed: "recently_viewed",
        settings: "settings",
        lastWatchedLeft: "last_watched_left",
    },
    assets: {
        images: {
            lightPlaceholder: "/images/light-placeholder-image.png",
            darkPlaceholder: "/images/dark-placeholder-image.png",
        },
    },
};

export const util = {
    getHighResMALImage(url: string) {
        return url.replace(
            /(https:\/\/cdn\.myanimelist\.net\/).*(images.*)\?.*/g,
            "$1$2"
        );
    },
    getValidImageUrl(url: string) {
        if (url.startsWith("//")) url = `https:${url}`;
        if (url.startsWith("http:")) url = url.replace("http:", "https:");
        return url;
    },
    createStateController<T>() {
        return <StateController<T>>{
            state: "waiting",
            data: null,
        };
    },
    createStateControllerNoNull<T>(data: T) {
        return <StateControllerNoNull<T>>{
            state: "waiting",
            data,
        };
    },
    parseMs: (ms: number) => {
        let secs = ms / 1000;
        const days = secs / (24 * 60 * 60);
        secs %= 24 * 60 * 60;
        const hours = secs / (60 * 60);
        secs %= 60 * 60;
        const mins = secs / 60;
        secs %= 60;
        return {
            days: Math.trunc(days),
            hours: Math.trunc(hours),
            mins: Math.trunc(mins),
            secs: Math.trunc(secs),
        };
    },
    isDarkTheme() {
        return document.documentElement.classList.contains("dark");
    },
};
