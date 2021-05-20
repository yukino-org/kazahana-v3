const path = require("path");
const { app, BrowserWindow, ipcMain } = require("electron");
const { autoUpdater } = require("electron-updater");

const isDev = process.env.NODE_ENV === "development";

const createWindow = () => {
    const win = new BrowserWindow({
        width: 800,
        height: 600,
        webPreferences: {
            contextIsolation: true,
            nodeIntegration: false,
            preload: path.join(__dirname, "preload.js"),
        },
        frame: false,
    });

    if (isDev) {
        if (!process.env.VITE_SERVE_URL)
            throw new Error("Missing 'process.env.VITE_SERVE_URL'!");

        win.loadURL(process.env.VITE_SERVE_URL);
        win.webContents.openDevTools();
    } else {
        win.loadFile(
            path.join(__dirname, "..", "..", "dist", "vite", "index.html")
        );
    }

    win.on("close", () => {
        if (!win.isDestroyed()) {
            win.destroy();
        }
    });

    ipcMain.handle("minimize-window", () => {
        win.minimize();
    });

    ipcMain.handle("toggle-maximize-window", () => {
        if (win.isMaximized()) {
            win.unmaximize();
        } else {
            win.maximize();
        }
    });

    ipcMain.handle("close-window", () => {
        win.close();
    });

    ipcMain.handle("reload-window", () => {
        win.reload();
    });
};

require("./ipc")(ipcMain);

app.on("ready", async () => {
    autoUpdater.checkForUpdatesAndNotify();

    createWindow();
});

app.on("activate", () => {
    if (BrowserWindow.getAllWindows().length === 0) {
        createWindow();
    }
});

app.on("window-all-closed", () => {
    if (process.platform !== "darwin") {
        app.quit();
    }
});
