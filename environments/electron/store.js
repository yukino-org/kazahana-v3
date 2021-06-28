const ElectronStore = require("electron-store");

/**
 * @typedef WindowSizeExtended
 * @property {boolean} isMaximized
 * @property {boolean} fullscreen
 */

/**
 * @typedef {import("electron").Rectangle & WindowSizeExtended} WindowSize
 */

class Store extends ElectronStore {
    all() {
        return this.store;
    }
}

class DataStore {
    constructor() {
        this.store = new Store();
    }

    /**
     * @returns {WindowSize}
     */
    getWindowSize() {
        const data = this.store.get("window_size");

        return (
            data || {
                x: undefined,
                y: undefined,
                width: 800,
                height: 600,
                isMaximized: false,
                fullscreen: false
            }
        );
    }

    /**
     * @param {WindowSize} size
     * @returns {void}
     */
    setWindowSize(size) {
        this.store.set("window_size", size);
    }
}

module.exports = new DataStore();
