const Store = require("electron-store");

class DataStore {
    constructor() {
        this.store = new Store();
    }

    /**
     * @returns {ReturnType<import("electron").BrowserWindow["getBounds"]> & { isMaximized: boolean; }}
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
            }
        );
    }

    /**
     * @param {ReturnType<import("electron").BrowserWindow["getBounds"]> & { isMaximized: boolean; }} size
     */
    setWindowSize(size) {
        this.store.set("window_size", size);
    }
}

module.exports = new DataStore();
