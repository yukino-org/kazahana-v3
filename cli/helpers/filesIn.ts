import { join } from "path";
import { lstat, readdir } from "fs-extra";

export const filesIn = async (path: string): Promise<string[]> => {
    const files: string[] = [];

    for (const x of await readdir(path)) {
        const p = join(path, x);
        const stat = await lstat(p);

        if (stat.isFile()) {
            files.push(p);
        } else {
            files.push(...(await filesIn(p)));
        }
    }

    return files;
};