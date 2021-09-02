import { spawn } from "../../spawn";
import { config } from "../../config";

spawn("flutter", ["run", "-d", "ios", ...process.argv.slice(2)], config.base);