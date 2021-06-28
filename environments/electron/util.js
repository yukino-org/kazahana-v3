const path = require("path");
const fs = require("fs");
const cp = require("child_process");
const util = require("util");
const mergeObj = require("lodash.merge");

const exec = util.promisify(cp.exec);

async function registerLinuxProtocol(name, code, execPath) {
    const desktopContent = [
        "[Desktop Entry]",
        `Name=${name}`,
        `Exec=${execPath} %u`,
        "Type=Application",
        "Terminal=false",
        `MimeType=application/${code};`
    ].join("\n");

    const desktopFileDir = "/usr/share/applications",
        desktopFileName = `${code}.desktop`,
        desktopFilePath = path.join(desktopFileDir, desktopFileName);

    await fs.promises.mkdir(desktopFileDir, {
        recursive: true
    });

    await fs.promises.writeFile(desktopFilePath, desktopContent);

    await exec(`xdg-mime default ${desktopFileName} x-scheme-handler/${code}`);
}

module.exports = {
    mergeObj,
    registerLinuxProtocol
};
