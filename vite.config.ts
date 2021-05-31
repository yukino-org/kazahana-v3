import { defineConfig } from "vite";
import vue from "@vitejs/plugin-vue";
import { version } from "./package.json";

const platform = process.env.YUKINO_PLATFORM || "unknown";

export default defineConfig({
    base: getBase(platform),
    plugins: [
        vue(),
        {
            name: "transform-html",
            enforce: "pre",
            transformIndexHtml(html) {
                html = html.replace("{{ head }}", getHead(platform));
                return html;
            },
        },
    ],
    build: {
        outDir: "dist/vite",
    },
    define: {
        app_platform: `"${platform}"`,
        app_version: `"${version}"`,
        app_builtAt: Date.now(),
    },
});

function getBase(platform: string) {
    switch (platform) {
        case "electron":
            return "./";

        default:
            return "/";
    }
}

function getHead(platform: string) {
    const head: string[] = [];

    return head.join("\n");
}
