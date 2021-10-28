import { getVersion } from "./";

const start = async () => {
    console.log(await getVersion());
};

start();
