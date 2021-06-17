const path = require("path");
const { app, BrowserWindow, ipcMain, dialog } = require("electron");
const Store = require("./store");
const Rpc = require("./rpc");
const Igniter = require("./igniter");
const Logger = require("./logger");
const { name: productCode, productName } = require("../../package.json");

const isDev = process.env.NODE_ENV === "development";
Logger.info("Starting app");

/**
 * @type {string | undefined}
 */
let launchURL;

/**
 * @type {BrowserWindow | undefined}
 */
let win;

const createWindow = async () => {
    if (!initiateInstance()) return;

    Logger.info(`Environment: ${process.env.NODE_ENV}`);

    const ignition = new Igniter();
    Logger.info("Created igniter");

    ignition.start();
    Logger.info("Started igniter");

    const continueProc = await ignition.update();
    Logger.warn(`Continue process: ${continueProc}`);
    if (!continueProc) return ignition.close();

    app.removeAsDefaultProtocolClient(productCode);
    if (isDev && process.platform === "win32") {
        app.setAsDefaultProtocolClient(productCode, process.execPath, [
            path.resolve(process.argv[1]),
        ]);
    } else {
        app.setAsDefaultProtocolClient(productCode);
    }

    const dimensions = Store.getWindowSize();
    win = new BrowserWindow({
        title: productName,
        x: dimensions.x,
        y: dimensions.y,
        width: dimensions.width,
        height: dimensions.height,
        minWidth: 400,
        minHeight: 300,
        webPreferences: {
            contextIsolation: true,
            nodeIntegration: false,
            preload: path.join(__dirname, "preload.js"),
        },
        show: false,
        frame: false,
        icon: path.join(__dirname, "..", "..", "resources", "icon.png"),
    });

    if (dimensions.isMaximized) win.maximize();
    else win.minimize();

    if (dimensions.fullscreen) win.setFullScreen(true);

    Logger.info("Created main window");

    let loadURL;
    if (isDev) {
        if (!process.env.VITE_SERVE_URL) {
            Logger.error("Missing env variable: process.env.VITE_SERVE_URL");
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

    setLauchURLIfWindows();
    if (launchURL) loadURL += `?redirect=${launchURL}`;

    win.loadURL(loadURL);
    Logger.info(`Opened URL: ${loadURL}`);

    if (isDev) win.webContents.openDevTools();
    await Rpc.connect();

    win.on("ready-to-show", () => {
        Logger.warn("Closing igniter and opening main window");
        ignition.close();
        win.show();
    });

    win.on("close", () => {
        Store.setWindowSize({
            ...win.getBounds(),
            isMaximized: win.isMaximized(),
            isFullScreen: process.platform === "darwin" && win.isFullScreen(),
        });

        if (!win.isDestroyed()) {
            Logger.warn("Main window has been closed!");
            win.destroy();
        }

        win = null;
    });

    ipcMain.handle("minimize-window", () => {
        Logger.warn("Main window has been minimized!");
        win.minimize();
    });

    ipcMain.handle("toggle-maximize-window", () => {
        if (process.platform === "darwin" && win.isFullScreen()) {
            win.setFullScreen(false);
            Logger.warn("Main window has been exited from fullscreen!");
        } else if (process.platform === "darwin" && win.isMaximized()) {
            win.setFullScreen(true);
            Logger.warn("Main window has been fullscreened!");
        } else if (win.isMaximized()) {
            win.unmaximize();
            Logger.warn("Main window has been unmaximized!");
        } else {
            win.maximize();
            Logger.warn("Main window has been maximized!");
        }
    });

    ipcMain.handle("close-window", async () => {
        const resp = await dialog.showMessageBox(null, {
            title: "Exit",
            message: "Do you want to close the app?",
            type: "warning",
            buttons: ["Yes", "No"],
            defaultId: 1,
        });

        if (resp.response === 0) {
            Logger.warn("Closing window");
            win.close();
        } else {
            Logger.info("User aborted app close!");
        }
    });

    ipcMain.handle("reload-window", () => {
        Logger.warn("Reloading window");
        win.reload();
    });
};

require("./ipc")(ipcMain);

app.on("ready", async () => {
    Logger.warn("Creating window (app ready)");
    await createWindow();
});

app.on("activate", async () => {
    if (BrowserWindow.getAllWindows().length === 0) {
        Logger.warn("No windows were open so opening new one (app activate)");
        await createWindow();
    }
});

app.on("window-all-closed", () => {
    if (process.platform !== "darwin") {
        Logger.warn("Qutting app");
        app.quit();
    }
});

app.on("will-finish-launching", function () {
    app.on("open-url", function (event, url) {
        event.preventDefault();

        console.log("loadurl", url);
        launchURL = url;
    });
});

function setLauchURLIfWindows() {
    if (process.platform === "win32") {
        console.log("launchurlifwin", process.argv, process.argv.slice(1));
        launchURL = process.argv.slice(1);
    }
}

function initiateInstance() {
    const isPrimaryInstance = app.requestSingleInstanceLock();
    if (isPrimaryInstance) {
        app.on("second-instance", (event, args) => {
            event.preventDefault();

            if (process.platform === "win32") {
                launchURL = args.slice(1);
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
