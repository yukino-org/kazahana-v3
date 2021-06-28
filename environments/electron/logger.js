const path = require("path");
const fs = require("fs");
const { app } = require("electron");

/**
 * @callback DebugBridgeHandler
 * @param {string} type
 * @param {string} proc
 * @param {string} txt
 * @returns {void}
 */

const logDir = path.join(app.getPath("appData"), app.getName());

const isDev = process.env.NODE_ENV === "development";

class Logger {
    constructor() {
        fs.mkdirSync(logDir, {
            recursive: true
        });

        /**
         * @type {DebugBridgeHandler | null}
         */
        this.bridgeDbug = null;

        /**
         * @type {fs.WriteStream}
         */
        this.file = fs.createWriteStream(path.join(logDir, "logger.log"));
    }

    /**
     * @param {DebugBridgeHandler | null} dbug
     * @returns {void}
     */
    setBridgeDebug(dbug) {
        this.bridgeDbug = dbug;
    }

    /**
     * @param {string} proc
     * @param {string} txt
     * @param {boolean} [dontEmitBridge]
     * @returns {void}
     */
    debug(proc, txt, dontEmitBridge) {
        this.write(`[${Logger.time} DBUG] ${proc}: ${txt}`);
        this.emitBridge("debug", proc, txt, dontEmitBridge);
    }

    /**
     * @param {string} proc
     * @param {string} txt
     * @param {boolean} [dontEmitBridge]
     * @returns {void}
     */
    error(proc, txt, dontEmitBridge) {
        this.write(`[${Logger.time} ERR!] ${proc}: ${txt}`);
        this.emitBridge("error", proc, txt, dontEmitBridge);
    }

    /**
     * @param {string} proc
     * @param {string} txt
     * @param {boolean} [dontEmitBridge]
     * @returns {void}
     */
    warn(proc, txt, dontEmitBridge) {
        this.write(`[${Logger.time} WARN] ${proc}: ${txt}`);
        this.emitBridge("warn", proc, txt, dontEmitBridge);
    }

    /**
     * @param {string} txt
     * @returns {void}
     */
    write(txt) {
        if (this.file && this.file.writable) this.file.write(`${txt}\n`);
        if (isDev) console.log(txt);
    }

    /**
     * @param {string} type
     * @param {string} proc
     * @param {string} txt
     * @param {boolean} [dontEmitBridge]
     * @returns {void}
     */
    emitBridge(type, proc, txt, dontEmitBridge) {
        if (this.bridgeDbug && !dontEmitBridge) {
            try {
                this.bridgeDbug(type, proc, txt);
            } catch (err) {
                // Ignore these as window events could be not available
            }
        }
    }

    /**
     * @type {string}
     */
    static get time() {
        return new Date().toLocaleTimeString();
    }
}

module.exports = new Logger();
