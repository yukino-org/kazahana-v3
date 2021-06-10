const { compare } = require("@zyrouge/git-compare");

module.exports = async (opts) => {
    const changes = await compare({
        ...opts,
        allowOnlyConventional: true,
        filterDuplicatesMsg: true,
    });

    const features = [];
    const fixes = [];
    const refactors = [];

    changes.forEach((x) => {
        const msg = `${x.id} ${x.msg}`;
        if (x.msg.startsWith("feat")) {
            features.push(msg);
        } else if (x.msg.startsWith("fix")) {
            fixes.push(msg);
        } else if (x.msg.startsWith("refactor")) {
            refactors.push(msg);
        } else console.log(msg);
    });

    return {
        features,
        fixes,
        refactors,
    };
};

// module
//     .exports({
//         repo: {
//             author: "zyrouge",
//             repo: "yukino-app",
//         },
//         version: {
//             previous: "v0.0.11-beta.0",
//             current: "v0.0.12-beta.0",
//         },
//     })
//     .then((x) => console.log(JSON.stringify(x, null, 4)));
