const path = require("path");
const { app, BrowserWindow } = require("electron");
const Store = require("../store");
const Logger = require("../logger");
const { productName, version } = require("../../../package.json");

const isDev = process.env.NODE_ENV === "development";

if (isDev) {
    app.getVersion = () => version;
    Logger.warn(`Changed app version to ${app.getVersion()}`);
}

class Igniter {
    /**
     * @param {import("electron-updater").AppUpdater} updater
     */
    constructor() {
        this.win = null;
        this.autoUpdater = require("electron-updater").autoUpdater;
        this.autoUpdater.autoDownload = false;
        this.autoUpdater.logger = null;
        this.autoUpdater.channel =
            Store.store.get("settings.updateChannel") || "latest";
        this.autoUpdater.allowDowngrade = false;

        if (isDev) {
            this.autoUpdater.updateConfigPath = path.join(
                __dirname,
                "dev-mock-update.yml"
            );
            Logger.warn(
                `Changed updater config path to ${this.autoUpdater.updateConfigPath}`
            );
        }
    }

    start() {
        this.win = new BrowserWindow({
            title: productName,
            width: 300,
            height: 330,
            resizable: false,
            webPreferences: {
                contextIsolation: true,
                nodeIntegration: false,
                preload: path.join(__dirname, "preload.js"),
            },
            frame: false,
            transparent: true,
            icon: path.join(
                __dirname,
                "..",
                "..",
                "..",
                "resources",
                "icon.png"
            ),
        });
        Logger.info("Created ignition window");

        const url = `file://${path.join(
            __dirname,
            "splash.html"
        )}?title=${encodeURIComponent(
            productName
        )}&version=${encodeURIComponent(app.getVersion())}`;
        this.win.loadURL(url);
        Logger.info(`Opened url in ignition window: ${url}`);
    }

    /**
     * @returns {Promise<boolean}
     */
    async update() {
        return new Promise(async (resolve) => {
            this.autoUpdater.checkForUpdates();

            this.autoUpdater.on("update-not-available", () => {
                Logger.info("No updates were found");
                resolve(true);
            });

            this.autoUpdater.on("update-downloaded", () => {
                Logger.info("Downloaded update");
                this.win.webContents.send("update-downloaded");
                this.autoUpdater.quitAndInstall();
                resolve(false);
            });

            this.autoUpdater.on("checking-for-update", () => {
                Logger.info("Checking for update");
                this.win.webContents.send("checking-for-update");
            });

            this.autoUpdater.on("update-available", (info) => {
                Logger.info(`New update is available: ${info.version}`);
                this.win.webContents.send("new-update", info.version);
                this.autoUpdater.downloadUpdate();
            });

            this.autoUpdater.on("download-progress", (progress) => {
                const toMb = (n) => (n / 1000000).toFixed(2);
                const txt = `${progress.percent.toFixed(2)}% completed (${toMb(
                    progress.transferred
                )}/${toMb(progress.total)} mb at ${toMb(
                    progress.bytesPerSecond
                )} mbps)`;
                Logger.info(`Update progress: ${txt}`);
                this.win.webContents.send("download-progress", txt);
            });

            this.autoUpdater.on("error", (err) => {
                Logger.error(`Updated error: ${err}`);
                this.win.webContents.send(
                    "error",
                    err && err.message ? err.message : err
                );
                resolve(true);
            });

            this.autoUpdater.checkForUpdates();
            Logger.info("Checking for update");
        });
    }

    close() {
        try {
            this.win.destroy();
        } catch (err) {}
    }
}

module.exports = Igniter;
