import MergeObject from "lodash.merge";
import { Settings } from "./types";

export type Await<T> = T extends Promise<infer U> ? U : T;

export type NotNull<T> = Exclude<T, null>;

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

const publicBase =
    import.meta.env.PROD && ["electron"].includes(app_platform) ? "." : "";
export const constants = {
    defaults: {
        settings: <Settings>{
            updateChannel: "latest",
            incognito: "disabled",
            sideBarPosition: "left",
            discordRpc: "enabled",
            discordRpcPrivacy: "disabled",
            autoDetectTheme: "enabled",
            darkMode: "disabled",
            autoPlay: "disabled",
            autoNext: "disabled",
            defaultPlayerWidth: 100,
            defaultPageWidth: 100,
            hideBottomBarText: "disabled",
            compactBottomBar: "disabled",
            bottomBarItemsCount: 3,
            skipIntroLength: 85,
            defaultSeekLength: 10,
            defaultVolume: 100,
            videoPlayerGestures: "enabled",
        },
    },
    assets: {
        images: {
            lightPlaceholder: `${publicBase}/images/light-placeholder-image.png`,
            darkPlaceholder: `${publicBase}/images/dark-placeholder-image.png`,
            myAnimeListLogo: `${publicBase}/images/myanimelist-logo.png`,
            aniListLogo: `${publicBase}/images/anilist-logo.png`,
        },
    },
    links: {
        website: "https://yukino-app.github.io",
        discordInvite: "https://yukino-app.github.io/discord.html",
        patreon: "https://patreon.com/zyrouge",
        github: "https://github.com/yukino-app/yukino/",
        guides: "https://yukino-app.github.io/guides/index.html",
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
    tryArrange<T extends Record<any, any>>(arr: T[], key: keyof T) {
        if (arr.length < 2) return arr;

        const [, i] = arr.reduce(
            (pv, cv, ci) => {
                const n = +cv[key];
                return n < pv[0] ? [n, ci] : pv;
            },
            [Infinity, -1]
        );

        return i < arr.length && i > Math.floor(arr.length / 2)
            ? arr.reverse()
            : arr;
    },
    shrinkedText(txt: string, max: number) {
        if (txt.length < max) return txt;
        const mid = Math.floor(max / 2) - 3;
        return `${txt.slice(0, mid)}...${txt.slice(-mid)}`;
    },
    async copyToClipboard(text: string) {
        return navigator.clipboard
            .writeText(text)
            .then(() => true)
            .catch(() => false);
    },
    padNumber(num: number | string, len: number) {
        const str = typeof num === "number" ? num.toString() : num;
        return str.padStart(len, "0");
    },
    isFiniteNumber(num: number) {
        return num >= 0 && num < Infinity;
    },
    getTouchOffset(event: TouchEvent) {
        const target = event.target as HTMLElement;
        const { x, y, width, height } = target.getBoundingClientRect();

        return {
            offsetX:
                ((event.touches[0].clientX - x) / width) * target.offsetWidth,
            offsetY:
                ((event.touches[0].clientY - y) / height) * target.offsetHeight,
        };
    },
    mergeObject: MergeObject,
};
