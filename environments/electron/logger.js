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

        this.file = fs.createWriteStream(path.join(logDir, "logger.log"));
    }

    debug(txt) {
        this.write(`[${Logger.time} DBUG] ${txt}`);
    }

    info(txt) {
        this.write(`[${Logger.time} INFO] ${txt}`);
    }

    error(txt) {
        this.write(`[${Logger.time} ERR!] ${txt}`);
    }

    warn(txt) {
        this.write(`[${Logger.time} WARN] ${txt}`);
    }

    write(txt) {
        if (this.file && this.file.writable) this.file.write(`${txt}\n`);
        if (isDev) console.log(txt);
    }

    static get time() {
        return new Date().toLocaleString();
    }
}

module.exports = new Logger();
