const path = require("path");
const spawn = require("cross-spawn");
const { createServer } = require("vite");
const pkgJson = require("../package.json");

const PORT = process.env.PORT ? +process.env.PORT : 3000;

const start = async () => {
    process.env.NODE_ENV = "development";
    process.env.VITE_APP_URL = `http://localhost:${PORT}`;

    const server = await createServer({
        root: path.resolve(__dirname, ".."),
        server: {
            port: PORT,
        },
    });

    await server.listen();

    const electronStart = "electron:start";
    if (!electronStart in pkgJson.scripts)
        throw new Error("Missing 'scripts.electron:start' in package.json");

    const electronProcess = spawn(`yarn ${electronStart}`, {
        stdio: "inherit",
    });

    electronProcess.on("error", (err) => {
        console.error(err);
    });

    electronProcess.on("exit", (code) => {
        console.warn(`Electron process exited with code ${code}! Exiting...`);
        process.exit(code);
    });
};

start();
