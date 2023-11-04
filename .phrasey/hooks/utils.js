const p = require("path");

const rootDir = p.resolve(__dirname, "../..");
const rootI18nDir = p.join(rootDir, "i18n");
const appI18nDir = p.join(rootDir, "lib/core/translator");

module.exports = {
    rootDir,
    appI18nDir,
    rootI18nDir,
};
