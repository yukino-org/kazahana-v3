import { defineConfig } from "vite";
import vue from "@vitejs/plugin-vue";

const platform = process.env.YUKINO_PLATFORM || "unknown";

export default defineConfig({
    base: ["electron"].includes(platform) ? "./" : "/",
    plugins: [vue()],
    build: {
        outDir: "dist/vite",
    },
    define: {
        platform: `"${platform}"`,
    },
});
