import { Http } from "@capacitor-community/http";
import { Requester } from "anime-ext/dist/types";

const getUrl = (url: URL) => url.origin + url.pathname;

// @ts-ignore
const getParams = (url: URL) => Object.fromEntries(url.searchParams);

export const requester: Requester = {
    async get(url, options) {
        const parsed = new URL(url);
        const res = await Http.request({
            method: "GET",
            url: getUrl(parsed),
            params: getParams(parsed),
            headers: options.headers,
            responseType: "text",
            connectTimeout: options.timeout,
        });
        return res.data;
    },
    async post(url, body, options) {
        const parsed = new URL(url);
        const res = await Http.request({
            method: "POST",
            url: getUrl(parsed),
            params: getParams(parsed),
            data: body,
            headers: options.headers,
            responseType: "text",
            connectTimeout: options.timeout,
        });
        return res.data;
    },
};
