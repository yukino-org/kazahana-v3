import { spawn } from "../spawn";
import { config } from "../config";

spawn("flutter", ["packages", "pub", "run", "build_runner", "build", "--delete-conflicting-outputs"], config.base);