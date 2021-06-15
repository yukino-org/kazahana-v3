const path = require("path");
const { app, BrowserWindow, ipcMain, dialog } = require("electron");
const Store = require("./store");
const Rpc = require("./rpc");
const Igniter = require("./igniter");
const Logger = require("./logger");
const { productName } = require("../../package.json");

const isDev = process.env.NODE_ENV === "development";
Logger.info("Starting app");

const createWindow = async () => {
    Logger.info(`Environment: ${process.env.NODE_ENV}`);

    const ignition = new Igniter();
    Logger.info("Created igniter");

    ignition.start();
    Logger.info("Started igniter");

    const continueProc = await ignition.update();
    Logger.warn(`Continue process: ${continueProc}`);
    if (!continueProc) return ignition.close();

    await Rpc.connect();

    const dimensions = Store.getWindowSize();
    const win = new BrowserWindow({
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

    if (isDev) {
        if (!process.env.VITE_SERVE_URL) {
            Logger.error("Missing env variable: process.env.VITE_SERVE_URL");
            throw new Error("Missing 'process.env.VITE_SERVE_URL'!");
        }

        win.loadURL(process.env.VITE_SERVE_URL);
        win.webContents.openDevTools();
        Logger.info(`Opened URL: ${process.env.VITE_SERVE_URL}`);
    } else {
        const file = path.join(
            __dirname,
            "..",
            "..",
            "dist",
            "vite",
            "index.html"
        );
        win.loadFile(file);
        Logger.info(`Opened file: ${file}`);
    }

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
