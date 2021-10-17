import { IOptions, compare } from "@zyrouge/git-compare";

export const getChanges = async (
    opts: Omit<IOptions, "allowOnlyConventional" | "filterDuplicatesMsg">
) => {
    const changes = await compare({
        ...opts,
        allowOnlyConventional: true,
        filterDuplicatesMsg: true,
    });

    const features: string[] = [];
    const fixes: string[] = [];
    const refactors: string[] = [];

    changes.forEach((x) => {
        const msg = `\`${x.id}\` ${x.msg}`;
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
