const { join } = require("path");
const { readFile } = require("fs-extra");
const { config } = require("../config");
const { matchRegex } = require("../others/version");

const getVersion = async () => {
    const path = join(config.base, "pubspec.yaml");
    const content = (await readFile(path)).toString();
    return content.match(matchRegex)[1].trim();
};

module.exports.getVersion = getVersion;
