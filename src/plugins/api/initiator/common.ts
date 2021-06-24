import { InitiatorFn } from "./";
import MyAnimeList from "../../integrations/myanimelist";
import AniList from "../../integrations/anilist";

export const initiator: InitiatorFn = async () => {
    await MyAnimeList.initialize();
    await AniList.initialize();
};
