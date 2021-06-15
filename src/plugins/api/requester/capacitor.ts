import qs from "qs";
import { Http } from "@capacitor-community/http";
import { Requester } from "anime-ext/dist/types";

const getUrl = (url: URL) => url.origin + url.pathname;

const getParams = (url: URL) =>
    [...url.searchParams.entries()].reduce<Record<string, string>>(
        (pv, [k, v]) => {
            pv[k] = v;
            return pv;
        },
        {}
    );

const getContentType = (headers: Record<string, any>) => {
    const contentTypeKey = Object.keys(headers).find(
        (x) => x.toLowerCase() === "content-type"
    );
    return <string | null>(contentTypeKey ? headers[contentTypeKey] : null);
};

const getBody = (body: any, contentType: ReturnType<typeof getContentType>) => {
    if (contentType?.includes("application/x-www-form-urlencoded")) {
        try {
            body = qs.parse(body);
        } catch (err) {}
    }

    return body;
};

const getData = (data: any) => {
    if (typeof data === "object") {
        try {
            data = JSON.stringify(data);
        } catch (err) {}
    }

    return <string>data;
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
        return getData(res.data);
    },
    async post(url, body, options) {
        const parsed = new URL(url);
        const res = await Http.request({
            method: "POST",
            url: getUrl(parsed),
            params: getParams(parsed),
            data: getBody(body, getContentType(options.headers)),
            headers: options.headers,
            responseType: "text",
            connectTimeout: options.timeout,
        });
        return getData(res.data);
    },
};
