const { compare } = require("@zyrouge/git-compare");

module.exports = async (opts) => {
    const changes = await compare({
        ...opts,
        allowOnlyConventional: true,
        filterDuplicatesMsg: true,
    });
    return changes.map((x) => `${x.id} ${x.msg}`).join("\n");
};

// module
//     .exports({
//         repo: {
//             author: "zyrouge",
//             repo: "yukino-app",
//         },
//         version: {
//             previous: "v0.0.8-beta.0",
//             current: "v0.0.10-beta.0",
//         },
//     })
//     .then(console.log);
