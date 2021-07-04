const path = require("path");
const spawn = require("cross-spawn");
const { createServer } = require("vite");
const addressToString = require("./utils/address-to-string");
const pkgJson = require("../package.json");

const PORT = process.env.PORT ? +process.env.PORT : 3000;

const start = async () => {
    process.env.NODE_ENV = "development";

    const server = await createServer({
        root: path.resolve(__dirname, ".."),
        server: {
            port: PORT,
            watch: true
        }
    });

    await server.listen();

    process.env.VITE_SERVE_URL = addressToString(
        server.httpServer.address(),
        server.config.server.https
    );

    const electronStart = "electron:start";
    if (!pkgJson.scripts[electronStart])
        throw new Error("Missing 'scripts.electron:start' in package.json");

    const electronProcess = spawn(`yarn ${electronStart}`, {
        stdio: "inherit"
    });

    electronProcess.on("error", err => {
        console.error(err);
    });

    electronProcess.on("exit", code => {
        console.warn(`Electron process exited with code ${code}! Exiting...`);
        process.exit(code);
    });
};

start();
