import { defineConfig } from "vite";
import vue from "@vitejs/plugin-vue";

const isElectronBuild = process.env.BUILD_MODE === "electron";

export default defineConfig({
    base: isElectronBuild ? "./" : "/",
    plugins: [vue()],
    build: {
        outDir: "dist/vite",
    },
});
