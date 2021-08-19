import { spawn } from "../../spawn";
import { config } from "../../config";

spawn("flutter", ["run", "-d", "linux"], config.base);