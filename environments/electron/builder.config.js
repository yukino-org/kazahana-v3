module.exports = {
    productName: "Yukino",
    appId: "io.github.zyrouge.yukino",
    copyright: "Copyright © 2021 Zyrouge",
    files: [
        "dist/vite/**/*",
        "resources/**/*",
        "environments/electron/**/*",
        "node_modules/**/*",
        "package.json",
    ],
    directories: {
        buildResources: "resources",
        output: "dist/electron",
    },
    extraMetadata: {
        main: "environments/electron/main.js",
    },
    publish: ["github"],
    win: {
        target: "nsis",
    },
        "dmg": {
            "title":"Yukino",
        "background": null,
        "backgroundColor": "#ffffff",
        "window": {
            "width": "400",
            "height": "300"
        },
        "contents": [
            {
                "x": 100,
                "y": 100
            },
            {
                "x": 300,
                "y": 100,
                "type": "link",
                "path": "/Applications"
            }
        ]
    },
    "mac": {
        "target": "dmg",
        "category": "public.app-category.utilities"
      },
    nsis: {
        oneClick: false,
        allowToChangeInstallationDirectory: true,
    },
    linux: {
        target: "AppImage",
    },
    generateUpdatesFilesForAllChannels: true,
};
