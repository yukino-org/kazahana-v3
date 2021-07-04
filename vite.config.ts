import { defineConfig } from "vite";
import vue from "@vitejs/plugin-vue";
import { name as productCode, productName, version } from "./package.json";

const platform = process.env.YUKINO_PLATFORM || "unknown",
    os = process.env.YUKINO_OS || process.platform || "unknown";

export default defineConfig({
    base: getBase(platform),
    plugins: [vue()],
    build: {
        outDir: "dist/vite"
    },
    define: {
        app_name: `"${productName}"`,
        app_code: `"${productCode}"`,
        app_platform: `"${platform}"`,
        app_os: `"${os}"`,
        app_version: `"${version}"`,
        app_builtAt: Date.now()
    }
});

function getBase(platform: string) {
    switch (platform) {
        case "electron":
            return "./";

        default:
            return "/";
    }
}
