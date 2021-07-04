const path = require("path");
const cp = require("child_process");
const util = require("util");
const os = require("os");
const { createServer } = require("vite");
const addressToString = require("./utils/address-to-string");

const exec = util.promisify(cp.exec);

const PORT = process.env.PORT ? +process.env.PORT : 3000;

const start = async () => {
    process.env.NODE_ENV = "development";

    const host =
        process.env.host ||
        Object.values(os.networkInterfaces())
            .flat(1)
            .find(
                x =>
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
                ignored: ["environments"]
            },
            host
        }
    });

    await server.listen();

    process.env.VITE_SERVE_URL = addressToString(
        {
            ...server.httpServer.address(),
            address: host
        },
        server.config.server.https
    );

    await exec("npx cap copy");
    console.log("Synced capacitor config");
};

start();
