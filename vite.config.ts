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
        outDir: getOutDir(platform),
    },
    define: {
        app_platform: `"${platform}"`,
        app_version: `"${version}"`,
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

function getOutDir(platform: string) {
    switch (platform) {
        case "capacitor":
            return "dist/capacitor/web";

        default:
            return "dist/vite";
    }
}

function getHead(platform: string) {
    const head: string[] = [];

    return head.join("\n");
}
