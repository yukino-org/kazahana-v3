const path = require("path");
const { execSync: exec } = require("child_process");

const RESOURCES = path.resolve(__dirname, "..", "resources");

const start = async () => {
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
    exec(
        `electron-icon-builder --flatten --input=${base}/icon.png --output=${RESOURCES}/electron`
    );
};

start();
