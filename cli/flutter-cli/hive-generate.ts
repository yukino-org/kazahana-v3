import { spawn } from "../spawn";
import { config } from "../config";

spawn("flutter", ["packages", "pub", "run", "build_runner", "build"], config.base);