const path = require("path");
const fs = require("fs");

const logDir = path.join(__dirname, "logs");

class Logger {
    constructor() {
        fs.mkdirSync(logDir, {
            recursive: true,
        });

        this.file = fs.createWriteStream(
            path.join(logDir, `data-${Logger.date.replace(/[^\d]+/g, "-")}.log`)
        );
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
        this.file.write(`${txt}\n`);
        console.log(txt);
    }

    static get date() {
        return new Date().toLocaleDateString();
    }

    static get time() {
        return new Date().toLocaleString();
    }
}

module.exports = new Logger();
