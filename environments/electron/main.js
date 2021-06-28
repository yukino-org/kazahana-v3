const path = require("path");
const { app, BrowserWindow, ipcMain, dialog } = require("electron");
const Store = require("./store");
const Rpc = require("./rpc");
const Igniter = require("./igniter");
const Logger = require("./logger");
const util = require("./util");
const IpcHandler = require("./ipc");
const { name: productCode, productName } = require("../../package.json");

const isDev = process.env.NODE_ENV === "development";
Logger.debug("main", "Starting app");

/**
 * @type {BrowserWindow | undefined}
 */
let win,
    /**
     * @type {boolean}
     */
    isBooting = false;

/**
 * @returns {Promise<void>}
 */
const createWindow = async () => {
    if (!initiateInstance()) return;

    isBooting = true;
    Logger.debug("main", `Environment: ${process.env.NODE_ENV}`);

    const ignition = new Igniter();
    Logger.debug("main", "Created igniter");

    ignition.start();
    Logger.debug("main", "Started igniter");

    const continueProc = await ignition.update();
    Logger.warn("main", `Continue process: ${continueProc}`);
    if (!continueProc) {
        isBooting = false;
        ignition.close();
        return;
    }

    app.removeAsDefaultProtocolClient(productCode);
    if (isDev && process.platform === "win32") {
        app.setAsDefaultProtocolClient(productCode, process.execPath, [
            path.resolve(process.argv[1])
        ]);
    } else {
        app.setAsDefaultProtocolClient(productCode);
    }

    if (process.platform === "linux") {
        try {
            await util.registerLinuxProtocol(
                productName,
                productCode,
                app.getPath("exe")
            );
        } catch (err) {
            Logger.error(
                "main",
                `Failed to register deeplink protocol: ${err}`
            );
        }
    }

    const dimensions = Store.getWindowSize();
    win = new BrowserWindow({
        title: productName,
        x: dimensions.x,
        y: dimensions.y,
        width: dimensions.width,
        height: dimensions.height,
        fullscreen: false,
        minWidth: 400,
        minHeight: 300,
        webPreferences: {
            contextIsolation: true,
            nodeIntegration: false,
            preload: path.join(__dirname, "preload.js")
        },
        show: false,
        frame: false,
        icon: path.join(__dirname, "..", "..", "resources", "icon.png")
    });

    if (dimensions.isMaximized) win.maximize();
    else win.minimize();

    if (process.platform === "darwin" && dimensions.fullscreen) {
        win.setFullScreen(true);
    }

    Logger.debug("main", "Created window");

    /**
     * @type {string}
     */
    let loadURL;
    if (isDev) {
        if (!process.env.VITE_SERVE_URL) {
            Logger.error(
                "main",
                "Missing env variable: process.env.VITE_SERVE_URL"
            );
            throw new Error("Missing 'process.env.VITE_SERVE_URL'!");
        }

        loadURL = process.env.VITE_SERVE_URL;
    } else {
        loadURL = `file://${path.join(
            __dirname,
            "..",
            "..",
            "dist",
            "vite",
            "index.html"
        )}`;
    }

    setLaunchURLIfWindowsOrLinux();
    win.loadURL(loadURL);
    Logger.debug("main", `Opened URL: ${loadURL}`);
    Logger.setBridgeDebug((...args) =>
        win.webContents.send("Electron-Log", ...args)
    );

    if (isDev) win.webContents.openDevTools();
    await Rpc.connect();

    Logger.warn("main", "Closing igniter and opening main window");
    ignition.close();

    win.on("ready-to-show", () => {
        win.show();
    });

    win.on("close", () => {
        Store.setWindowSize({
            ...win.getBounds(),
            isMaximized: win.isMaximized(),
            fullscreen: process.platform === "darwin" && win.isFullScreen()
        });

        if (!win.isDestroyed()) {
            win.destroy();
        }

        win = null;
    });

    ipcMain.handle("Minimize-Window", () => {
        Logger.warn("main", "Main window has been minimized!");
        win.minimize();
    });

    ipcMain.handle("Maximize-Window", () => {
        if (process.platform === "darwin" && win.isFullScreen()) {
            win.setFullScreen(false);
            Logger.warn("main", "Main window has been exited from fullscreen!");
        } else if (process.platform === "darwin" && win.isMaximized()) {
            win.setFullScreen(true);
            Logger.warn("main", "Main window has been fullscreened!");
        } else if (win.isMaximized()) {
            win.unmaximize();
            Logger.warn("main", "Main window has been unmaximized!");
        } else {
            win.maximize();
            Logger.warn("main", "Main window has been maximized!");
        }
    });

    ipcMain.handle("Close-Window", async () => {
        const resp = await dialog.showMessageBox(null, {
            title: "Exit",
            message: "Do you want to close the app?",
            type: "warning",
            buttons: ["Yes", "No"],
            defaultId: 1
        });

        if (resp.response === 0) {
            Logger.warn("main", "Closing window");
            Logger.setBridgeDebug(null);
            win.close();
        } else {
            Logger.debug("main", "User aborted app close!");
        }
    });

    ipcMain.handle("Reload-Window", () => {
        Logger.warn("main", "Reloading window");
        win.reload();
    });

    isBooting = false;
};

IpcHandler(ipcMain);

app.on("ready", async () => {
    Logger.warn("main", "Creating window (app ready)");
    await createWindow();
});

app.on("activate", async () => {
    if (!win && !isBooting) {
        Logger.warn(
            "main",
            "No windows were open so opening new one (app activate)"
        );
        await createWindow();
    }
});

app.on("window-all-closed", () => {
    if (process.platform !== "darwin") {
        Logger.warn("main", "Qutting app");
        app.quit();
    }
});

app.on("will-finish-launching", () => {
    app.on("open-url", (event, url) => {
        event.preventDefault();

        setDeepLinkURL(parseDeepLink(url));
    });
});

/**
 * @return {void}
 */
function setLaunchURLIfWindowsOrLinux() {
    if (process.platform === "win32" || process.platform === "linux") {
        setDeepLinkURL(getDeepLinkedArg(process.argv));
    }
}

/**
 * @returns {boolean}
 */
function initiateInstance() {
    const isPrimaryInstance = app.requestSingleInstanceLock();
    if (isPrimaryInstance) {
        app.on("second-instance", (event, args) => {
            event.preventDefault();

            if (process.platform === "win32" || process.platform === "linux") {
                setDeepLinkURL(getDeepLinkedArg(args));
            }

            if (win) {
                if (win.isMinimized()) {
                    win.restore();
                }
                win.focus();
            }
        });

        return true;
    } else {
        app.quit();
        return false;
    }
}

const deepLinkMatcher = new RegExp(`^${productCode}://(.*)`);

/**
 * @param {string} url
 * @returns {string | undefined}
 */
function parseDeepLink(url) {
    const matched = url.match(deepLinkMatcher);
    return matched && matched[1] ? matched[1] : undefined;
}

/**
 * @param {string[]} args
 * @returns {string | undefined}
 */
function getDeepLinkedArg(args) {
    const found = args.find(arg => deepLinkMatcher.test(arg));
    return found && parseDeepLink(found);
}

/**
 * @param {string | undefined} url
 * @returns void
 */
function setDeepLinkURL(url) {
    if (!win || !url) return;
    win.webContents.send("deeplink", url);
}
