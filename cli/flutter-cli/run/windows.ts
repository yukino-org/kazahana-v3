import { spawn } from "../../spawn";
import { config } from "../../config";

spawn("flutter", ["run", "-d", "windows", ...process.argv.slice(2)], config.base);