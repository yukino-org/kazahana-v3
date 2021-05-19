const path = require("path");
const { app, BrowserWindow, ipcMain } = require("electron");

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
};

require("./ipc")(ipcMain);

app.whenReady().then(() => {
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
