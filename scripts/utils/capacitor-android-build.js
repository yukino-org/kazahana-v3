const path = require("path");
const spawn = require("cross-spawn");

const androidRoot = path.resolve(
    __dirname,
    "..",
    "..",
    "environments",
    "capacitor",
    "android"
);

/**
 * @param {"debug" | "release"} mode
 * @returns {Promise<string>}
 */
module.exports = (mode) =>
    new Promise((resolve, reject) => {
        const allowed = ["debug", "release"];
        if (!allowed.includes(mode))
            return reject(`Invalid build mode: ${mode}`);

        const buildProcess = spawn(
            "gradlew",
            [
                `assemble${mode.charAt(0).toUpperCase()}${mode.slice(1)}`,
                "--rerun-tasks",
            ],
            {
                stdio: "inherit",
                cwd: androidRoot,
            }
        );

        buildProcess.on("close", () => {
            return resolve(
                path.join(androidRoot, "app", "build", "outputs", "apk", mode)
            );
        });

        buildProcess.on("error", (err) => {
            return reject(err);
        });
    });
