export type Await<T> = T extends Promise<infer U> ? U : T;

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
};
