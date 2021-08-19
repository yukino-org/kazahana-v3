import { spawn } from "../../spawn";
import { config } from "../../config";

spawn("flutter", ["run", "-d", "macos"], config.base);