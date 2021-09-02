import { resolve, join } from "path";

const root = resolve(__dirname, "..");

const defaultIcon = join(root, "assets/images/yukino-icon.png");
const skrinkedIcon = join(root, "assets/images/yukino-icon-shrinked.png");

export const config = {
    base: root,
    android: {
        project: join(root, "android"),
        icon: skrinkedIcon,
    },
    ios: {
        project: join(root, "ios"),
        icon: skrinkedIcon,
    },
    macos: {
        project: join(root, "macos"),
        icon: defaultIcon,
    },
    linux: {
        project: join(root, "linux"),
        icon: defaultIcon,
    },
    windows: {
        project: join(root, "windows"),
        icon: defaultIcon,
    },
}