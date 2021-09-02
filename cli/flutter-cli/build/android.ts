import { spawn } from "../../spawn";
import { config } from "../../config";

spawn("flutter", ["build", "apk"], config.base);