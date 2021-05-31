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
};
