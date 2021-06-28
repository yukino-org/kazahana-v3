const path = require("path");
const { app, BrowserWindow } = require("electron");
const Store = require("../store");
const Logger = require("../logger");
const { productName, version } = require("../../../package.json");

const isDev = process.env.NODE_ENV === "development";

if (isDev) {
    app.getVersion = () => version;
    Logger.warn("igniter", `Changed app version to ${app.getVersion()}`);
}

class Igniter {
    constructor() {
        /**
         * @type {BrowserWindow | null}
         */
        this.win = null;

        /**
         * @type {import("electron-updater").AppUpdater}
         */
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
                "igniter",
                `Changed updater config path to ${this.autoUpdater.updateConfigPath}`
            );
        }
    }

    /**
     * @returns {void}
     */
    start() {
        this.win = new BrowserWindow({
            title: productName,
            width: 300,
            height: 330,
            resizable: false,
            webPreferences: {
                contextIsolation: true,
                nodeIntegration: false,
                preload: path.join(__dirname, "preload.js")
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
            )
        });
        Logger.debug("igniter", "Created window");

        const url = `file://${path.join(
            __dirname,
            "splash.html"
        )}?title=${productName}&version=${app.getVersion()}`;

        this.win.loadURL(url);
        Logger.debug("igniter", `Opened url in ignition window: ${url}`);
    }

    /**
     * @returns {Promise<boolean>}
     */
    update() {
        return new Promise(resolve => {
            this.autoUpdater.checkForUpdates();

            this.autoUpdater.on("update-not-available", () => {
                Logger.debug("igniter", "No updates were found");
                resolve(true);
            });

            this.autoUpdater.on("update-downloaded", () => {
                Logger.debug("igniter", "Downloaded update");
                this.win.webContents.send("update-downloaded");
                this.autoUpdater.quitAndInstall();
                resolve(false);
            });

            this.autoUpdater.on("checking-for-update", () => {
                Logger.debug("igniter", "Checking for update");
                this.win.webContents.send("checking-for-update");
            });

            this.autoUpdater.on("update-available", info => {
                Logger.debug(
                    "igniter",
                    `New update is available: ${info.version}`
                );
                this.win.webContents.send("new-update", info.version);
                this.autoUpdater.downloadUpdate();
            });

            this.autoUpdater.on("download-progress", progress => {
                Logger.debug(
                    "igniter",
                    `Update progress: ${progress.percent.toFixed(2)}%/100%`
                );
                const toMb = n => (n / 1000000).toFixed(2);
                this.win.webContents.send("download-progress", {
                    percent: progress.percent,
                    transferred: toMb(progress.transferred),
                    total: toMb(progress.total)
                });
            });

            this.autoUpdater.on("error", err => {
                Logger.error("igniter", `Updated error: ${err}`);
                this.win.webContents.send(
                    "error",
                    err && err.message ? err.message : err
                );
                resolve(true);
            });

            this.autoUpdater.checkForUpdates();
            Logger.debug("igniter", "Checking for update");
        });
    }

    /**
     * @returns {void}
     */
    close() {
        try {
            this.win.destroy();
        } catch (err) {
            Logger.error(
                "igniter",
                `Failed to destroy window: ${err?.message}`
            );
        }
    }
}

module.exports = Igniter;
