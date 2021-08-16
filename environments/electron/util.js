const os = require("os");
const path = require("path");
const fs = require("fs");
const cp = require("child_process");
const util = require("util");
const mergeObj = require("lodash.merge");

const exec = util.promisify(cp.exec);

/**
 * @param {string} name
 * @param {string} code
 * @param {string} execPath
 * @returns {Promise<void>}
 */
async function registerLinuxProtocol(name, code, execPath) {
    const desktopContent = [
        "[Desktop Entry]",
        `Name=${name}`,
        `Exec=${execPath} %u`,
        "Type=Application",
        "Terminal=false",
        `MimeType=x-scheme-handler/${code};`,
    ].join("\n");

    const desktopFileDir = path.join(
            os.homedir(),
            "/.local/share/applications"
        ),
        desktopFileName = `${code}.desktop`,
        desktopFilePath = path.join(desktopFileDir, desktopFileName);

    await fs.promises.mkdir(desktopFileDir, {
        recursive: true,
    });

    await fs.promises.writeFile(desktopFilePath, desktopContent);

    await exec(`xdg-mime default ${desktopFileName} x-scheme-handler/${code}`);
}

module.exports = {
    mergeObj,
    registerLinuxProtocol,
};
