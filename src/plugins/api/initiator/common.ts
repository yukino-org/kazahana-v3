import { InitiatorFn } from "./";
import MyAnimeList from "../../integrations/myanimelist";

export const initiator: InitiatorFn = async () => {
    await MyAnimeList.initialize();
};
