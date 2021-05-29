import qs from "qs";
import { Http } from "@capacitor-community/http";
import { Requester } from "anime-ext/dist/types";

console.log("hello");

const getUrl = (url: URL) => url.origin + url.pathname;
// @ts-ignore
const getParams = (url: URL) => Object.fromEntries(url.searchParams);

const getBody = (headers: Record<string, any>, body: any) => {
    const contentTypeKey = Object.keys(headers).find(
            (x) => x.toLowerCase() === "content-type"
        ),
        contentType = contentTypeKey ? headers[contentTypeKey] : null;

    if (contentType?.includes("application/x-www-form-urlencoded")) {
        try {
            body = qs.parse(body);
        } catch (err) {}
    }

    return body;
};

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
            data: getBody(options.headers || {}, body),
            headers: options.headers,
            responseType: "text",
            connectTimeout: options.timeout,
        });
        return res.data;
    },
};
