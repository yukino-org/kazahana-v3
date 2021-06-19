import MergeObject from "lodash.merge";
import { Settings } from "./types";

export type Await<T> = T extends Promise<infer U> ? U : T;

export type RecursivePartial<T> = {
    [P in keyof T]?: T[P] extends (infer U)[]
        ? RecursivePartial<U>[]
        : T[P] extends object
        ? RecursivePartial<T[P]>
        : T[P];
};

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
    defaults: {
        settings: <Settings>{
            updateChannel: "latest",
            sideBarPosition: "left",
            discordRpc: "enabled",
            discordRpcPrivacy: "disabled",
            autoDetectTheme: "enabled",
            darkMode: "disabled",
            autoPlay: "disabled",
            defaultPlayerWidth: 100,
            defaultPageWidth: 100,
        },
    },
    storeKeys: {
        recentlyBrowsed: "recently_browsed",
        recentlyViewed: "recently_viewed",
        settings: "settings",
        lastWatchedLeft: "last_watched_left",
        bookmarked: "bookmarked",
        favorite: "favorites",
        myAnimeListToken: "my_anime_list_token",
    },
    assets: {
        images: {
            lightPlaceholder: "/images/light-placeholder-image.png",
            darkPlaceholder: "/images/dark-placeholder-image.png",
            myAnimeListLogo: "/images/myanimelist-logo.png",
        },
    },
    links: {
        website: "https://zyrouge.github.io/yukino-app",
        discordInvite: "https://zyrouge.github.io/yukino-app/discord.html",
        patreon: "https://patreon.com/zyrouge",
        github: "https://github.com/zyrouge/yukino-app/",
        guides: "https://zyrouge.github.io/yukino-app/guides/index.html",
    },
    github: {
        owner: "zyrouge",
        repo: "yukino-app",
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
    shorten(text: string, length: number) {
        if (text.length < length) return text;
        return text.slice(0, length - 3) + "...";
    },
    BufferToBase64(buf: ArrayBuffer) {
        return window.btoa(
            new Uint8Array(buf).reduce(
                (data, byte) => data + String.fromCharCode(byte),
                ""
            )
        );
    },
    prettyDate(date: Date) {
        return date.toLocaleString(undefined, {
            weekday: "long",
            day: "numeric",
            month: "long",
            year: "numeric",
            hour: "numeric",
            minute: "numeric",
            timeZoneName: "short",
        });
    },
    async generatePkceChallenge() {
        const verifier = util.randomText(43);

        const sha = await window.crypto.subtle.digest(
            "SHA-256",
            new TextEncoder().encode(verifier)
        );
        const challenge = util
            .BufferToBase64(sha)
            .replace(/\+/g, "-")
            .replace(/\//g, "_")
            .replace(/=/g, "");

        return {
            code_verifier: verifier,
            code_challenge: challenge,
        };
    },
    randomText(length: number) {
        const allowed =
            "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789".split(
                ""
            );

        return Array(length)
            .fill("")
            .map(() => allowed[Math.floor(Math.random() * allowed.length)])
            .join("");
    },
    mergeObject: MergeObject,
};
