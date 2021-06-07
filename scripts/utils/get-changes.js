const cp = require("child_process");
const util = require("util");

const exec = util.promisify(cp.exec);
const filterRegex =
    /^\b[0-9a-f]{5,40}\b (build|chore|ci|docs|feat|fix|perf|refactor|revert|style|test){1}(\([\w-\.]+\))?(!)?: ([\w ])+([\s\S]*)/;

module.exports = async (tag1, tag2) => {
    const { stdout } = await exec(`git rev-list --oneline ${tag1}..${tag2}`);
    if (!stdout) return null;
    return [
        ...new Set(stdout.split("\n").filter((l) => filterRegex.test(l))),
    ].join("\n");
};

// module.exports("v0.0.8-beta.0", "v0.0.10-beta.0").then(console.log);
