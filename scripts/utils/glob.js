const path = require("path");
const fs = require("fs");

const dir = (p) => {
    const files = [];
    for (const f of fs.readdirSync(p).map((x) => path.join(p, x))) {
        const lstat = fs.lstatSync(f);
        if (lstat.isDirectory()) files.push(...dir(f));
        else files.push(f);
    }
    return files;
};

module.exports = (p) => {
    const lstat = fs.lstatSync(p);
    return lstat.isDirectory() ? dir(p) : [p];
};
