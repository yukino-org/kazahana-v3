const path = require("path");
const fs = require("fs");
const spawn = require("cross-spawn");

const RESOURCES = path.resolve(__dirname, "..", "resources"),
    OUTPUT = path.join(RESOURCES, "electron");

const start = async () => {
    fs.rmSync(OUTPUT, {
        recursive: true,
        force: true
    });

    let base;

    const platform = process.env.BUILD_PLATFORM || process.platform;
    console.log(`Platform: ${platform}`);
    switch (platform) {
        case "darwin":
            base = path.join(RESOURCES, "mac");
            break;

        default:
            base = path.join(RESOURCES, "default");
            break;
    }

    console.log(`Icons path: ${base}`);
    spawn("electron-icon-builder", [
        "--flatten",
        `--input=${base}/icon.png`,
        `--output=${OUTPUT}`
    ]);
};

start();
