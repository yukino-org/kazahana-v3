const path = require("path");
const fs = require("fs");
const { app } = require("electron");

const logDir = path.join(app.getPath("appData"), app.getName());

const isDev = process.env.NODE_ENV === "development";

class Logger {
    constructor() {
        fs.mkdirSync(logDir, {
            recursive: true,
        });

        this.bridgeDbug = null;
        this.file = fs.createWriteStream(path.join(logDir, "logger.log"));
    }

    setBridgeDebug(dbug) {
        this.bridgeDbug = dbug;
    }

    debug(proc, txt, dontEmitBridge) {
        this.write(`[${Logger.time} DBUG] ${proc}: ${txt}`);
        if (this.bridgeDbug && !dontEmitBridge) {
            this.bridgeDbug("debug", proc, txt);
        }
    }

    error(proc, txt, dontEmitBridge) {
        this.write(`[${Logger.time} ERR!] ${proc}: ${txt}`);
        if (this.bridgeDbug && !dontEmitBridge) {
            this.bridgeDbug("error", proc, txt);
        }
    }

    warn(proc, txt, dontEmitBridge) {
        this.write(`[${Logger.time} WARN] ${proc}: ${txt}`);
        if (this.bridgeDbug && !dontEmitBridge) {
            this.bridgeDbug("warn", proc, txt);
        }
    }

    write(txt) {
        if (this.file && this.file.writable) this.file.write(`${txt}\n`);
        if (isDev) console.log(txt);
    }

    static get time() {
        return new Date().toLocaleTimeString();
    }
}

module.exports = new Logger();
