const path = require("path");
const spawn = require("cross-spawn");

const androidRoot = path.resolve(
    __dirname,
    "..",
    "environments",
    "capacitor",
    "android"
);
const modeRaw = process.env.BUILD_MODE || "debug";

const start = async () => {
    const allowed = ["debug", "release"];
    if (!allowed.includes(modeRaw))
        return console.error(`Invalid build mode: ${modeRaw}`);

    const mode = `assemble${modeRaw.charAt(0).toUpperCase()}${modeRaw.slice(
        1
    )}`;
    console.log(`Executing mode: ${mode}`);

    const buildProcess = spawn(`"./gradlew" ${mode}`, {
        stdio: "inherit",
        cwd: androidRoot,
    });

    buildProcess.on("close", () => {
        let out;
        if (modeRaw === "debug")
            out = path.join(
                androidRoot,
                "app",
                "build",
                "outputs",
                "apk",
                "debug"
            );

        if (out) console.log(`Builded apk should be present at: ${out}`);
    });

    buildProcess.on("error", (err) => {
        console.error(err);
    });

    buildProcess.on("exit", (code) => {
        console.warn(`Build process exited with code ${code}! Exiting...`);
        process.exit(code);
    });
};

start();
