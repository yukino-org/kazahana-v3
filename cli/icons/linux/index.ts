import { Logger } from "../../logger";

const logger = new Logger("linux:icons");

export const generate = async () => {
    logger.log("Handled by the .desktop file");
}