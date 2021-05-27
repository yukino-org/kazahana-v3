import { defineConfig } from "vite";
import vue from "@vitejs/plugin-vue";
import html from "vite-plugin-html";
import { version } from "./package.json";

const platform = process.env.YUKINO_PLATFORM || "unknown";

export default defineConfig({
    base: getBase(platform),
    plugins: [
        vue(),
        html({
            inject: {
                injectData: {
                    scripts: getScripts(platform),
                },
            },
            minify: true,
        }),
    ],
    build: {
        outDir: "dist/vite",
    },
    define: {
        platform: `"${platform}"`,
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

function getScripts(platform: string) {
    let scripts: string[] = [];

    if (platform === "capacitor") {
        // scripts.push();
    }

    return scripts.join("\n");
}
