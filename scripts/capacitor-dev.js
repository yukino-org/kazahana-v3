const path = require("path");
const spawn = require("cross-spawn");
const cp = require("child_process");
const util = require("util");
const os = require("os");
const { createServer } = require("vite");
const addressToString = require("./utils/address-to-string");
const pkgJson = require("../package.json");

const exec = util.promisify(cp.exec);

const PORT = process.env.PORT ? +process.env.PORT : 3000;

const start = async () => {
    process.env.NODE_ENV = "development";

    const host =
        process.env.host ||
        Object.values(os.networkInterfaces())
            .flat(1)
            .find(
                (x) =>
                    !x.internal &&
                    x.family === "IPv4" &&
                    x.address.startsWith("192")
            ).address;
    if (!host)
        throw new Error(
            "Could not find LAN host, use 'process.env.host' to set it manually."
        );

    const server = await createServer({
        root: path.resolve(__dirname, ".."),
        server: {
            port: PORT,
            watch: {
                ignored: ["environments"],
            },
            host,
        },
    });

    await server.listen();

    process.env.VITE_SERVE_URL = addressToString(
        {
            ...server.httpServer.address(),
            address: host,
        },
        server.config.server.https
    );

    await exec("npx cap copy");
    console.log("Synced capacitor config");

    const capacitorAndroidRun = "capacitor:android:run";
    if (!pkgJson.scripts[capacitorAndroidRun])
        throw new Error(
            "Missing 'scripts.capacitor:android:run' in package.json"
        );

    const electronProcess = spawn(`yarn ${capacitorAndroidRun}`, {
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
