import { resolve, join } from "path";

const root = resolve(__dirname, "..");
const defaultIcon = join(root, "assets/images/yukino-icon.png");

export const config = {
    base: root,
    android: {
        project: join(root, "android"),
        icon: defaultIcon,
    },
    ios: {
        project: join(root, "ios"),
        icon: defaultIcon,
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