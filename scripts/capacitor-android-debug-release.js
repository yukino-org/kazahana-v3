const builder = require("./utils/capacitor-android-build");

const start = async () => {
    const out = await builder("release");
    console.log(`Output apk can be found at: ${out}`);
};

start();
