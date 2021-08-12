import qs from "qs";
import { Http, HttpOptions } from "@capacitor-community/http";
import { Requester, RequesterOptions } from "./";

const getUrl = (url: URL) => `https://${url.host}${url.pathname}`;

const getParams = (url: URL) => Object.fromEntries(url.searchParams);

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
        } catch (err: any) {}
    }

    return body;
};

const getData = (responseType: RequesterOptions["responseType"], data: any) => {
    if (responseType === "text" && typeof data === "object") {
        try {
            data = JSON.stringify(data);
        } catch (err: any) {}
    }

    return data;
};

export const requester: Requester = {
    async get(url, options) {
        const parsed = new URL(url);
        const res = await Http.request({
            method: "GET",
            url: getUrl(parsed),
            params: getParams(parsed),
            headers: options.headers,
            responseType: getValidResponseType(options.responseType),
            connectTimeout: options.timeout,
        });
        return getData(options.responseType, res.data);
    },
    async post(url, body, options) {
        const parsed = new URL(url);
        const res = await Http.request({
            method: "POST",
            url: getUrl(parsed),
            params: getParams(parsed),
            data: getBody(body, getContentType(options.headers)),
            headers: options.headers,
            responseType: getValidResponseType(options.responseType),
            connectTimeout: options.timeout,
        });
        return getData(options.responseType, res.data);
    },
    async patch(url, body, options) {
        const parsed = new URL(url);
        const res = await Http.request({
            method: "PATCH",
            url: getUrl(parsed),
            params: getParams(parsed),
            data: getBody(body, getContentType(options.headers)),
            headers: options.headers,
            responseType: getValidResponseType(options.responseType),
            connectTimeout: options.timeout,
        });
        return getData(options.responseType, res.data);
    },
    async put(url, body, options) {
        const parsed = new URL(url);
        const res = await Http.request({
            method: "PUT",
            url: getUrl(parsed),
            params: getParams(parsed),
            data: getBody(body, getContentType(options.headers)),
            headers: options.headers,
            responseType: getValidResponseType(options.responseType),
            connectTimeout: options.timeout,
        });
        return getData(options.responseType, res.data);
    },
};

function getValidResponseType(
    type: RequesterOptions["responseType"]
): HttpOptions["responseType"] {
    switch (type) {
        case "buffer":
            return "arraybuffer";

        default:
            return type;
    }
}
