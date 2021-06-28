const path = require("path");
const fs = require("fs");
const { app } = require("electron");

const logDir = path.join(app.getPath("appData"), app.getName());

const isDev = process.env.NODE_ENV === "development";

class Logger {
    constructor() {
        fs.mkdirSync(logDir, {
            recursive: true
        });

        this.bridgeDbug = null;
        this.file = fs.createWriteStream(path.join(logDir, "logger.log"));
    }

    setBridgeDebug(dbug) {
        this.bridgeDbug = dbug;
    }

    debug(proc, txt, dontEmitBridge) {
        this.write(`[${Logger.time} DBUG] ${proc}: ${txt}`);
        this.emitBridge("debug", proc, txt, dontEmitBridge);
    }

    error(proc, txt, dontEmitBridge) {
        this.write(`[${Logger.time} ERR!] ${proc}: ${txt}`);
        this.emitBridge("error", proc, txt, dontEmitBridge);
    }

    warn(proc, txt, dontEmitBridge) {
        this.write(`[${Logger.time} WARN] ${proc}: ${txt}`);
        this.emitBridge("warn", proc, txt, dontEmitBridge);
    }

    write(txt) {
        if (this.file && this.file.writable) this.file.write(`${txt}\n`);
        if (isDev) console.log(txt);
    }

    emitBridge(type, proc, txt, dontEmitBridge) {
        if (this.bridgeDbug && !dontEmitBridge) {
            try {
                this.bridgeDbug(type, proc, txt);
            } catch (err) {
                // Ignore these as window events could be not available
            }
        }
    }

    static get time() {
        return new Date().toLocaleTimeString();
    }
}

module.exports = new Logger();
