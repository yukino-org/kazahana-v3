const path = require("path");
const fs = require("fs");
const glob = require("./utils/glob");

const RESOURCES = path.resolve(__dirname, "..", "resources");
const ICONS_OUTPUT = path.join(RESOURCES, "icons");
const MAC_ICONS = path.join(RESOURCES, "mac");

const start = async () => {
    const files = glob(MAC_ICONS);
    files.forEach((file) => {
        const dest = file.replace(MAC_ICONS, ICONS_OUTPUT);
        fs.copyFileSync(file, dest);
        console.log(`Copied ${file} => ${dest}`);
    });
};

start();
