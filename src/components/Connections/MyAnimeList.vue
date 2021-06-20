<template>
    <div>
        <div class="flex flex-row justify-center items-center gap-4 flex-wrap">
            <div class="flex-grow flex items-center gap-3">
                <img class="w-7 h-auto rounded" :src="logo" alt="MyAnimeList" />
                <div>
                    <p class="text-xl font-bold">
                        MyAnimeList
                        <span class="text-xs mx-1 opacity-75" v-if="info.data"
                            >(
                            {{
                                info.data.my_list_status
                                    ?.num_episodes_watched || 0
                            }}/{{ info.data.num_episodes }})</span
                        >
                    </p>
                    <p class="opacity-75 text-xs" v-if="altTitle && info.data">
                        Computed as <b>{{ info.data.title }}</b>
                        <span
                            class="ml-1 text-red-500 font-bold cursor-pointer"
                            @click.stop.prevent="!!void toggleSearch()"
                            >Not this?</span
                        >
                    </p>
                </div>
            </div>

            <router-link
                class="
                    px-3
                    py-1.5
                    focus:outline-none
                    bg-blue-500
                    hover:bg-blue-600
                    transition
                    duration-200
                    rounded
                "
                to="/connections"
                v-if="!loggedIn"
                >Login</router-link
            >
            <div
                class="flex flex-row justify-center items-center gap-2"
                v-else-if="info.data"
            >
                <div class="select">
                    <select class="capitalize" @change="updateStatus($event)">
                        <option
                            v-for="status in allowedStatus"
                            :value="status"
                            :selected="
                                status ===
                                (info.data.my_list_status?.status || 0)
                            "
                        >
                            {{ status.replace(/_/g, " ") }}
                        </option>
                    </select>
                </div>
            </div>
        </div>

        <Popup :show="showSearch">
            <div
                class="
                    flex flex-row
                    justify-center
                    items-center
                    flex-wrap
                    gap-2
                "
            >
                <input
                    class="
                        flex-grow
                        text-box
                        bg-gray-200
                        dark:bg-gray-700
                        ring-gray-200
                        dark:gray-700
                    "
                    v-model="computedAltTitle"
                    type="text"
                    placeholder="Type in anime's name..."
                    @keypress.enter="!!void searchMAL()"
                />

                <button
                    type="submit"
                    class="btn"
                    @click.stop.prevent="!!void searchMAL()"
                >
                    Search
                </button>
            </div>

            <div class="mt-6 grid gap-2">
                <Loading
                    class="mt-8"
                    v-if="
                        ['waiting', 'resolving'].includes(
                            others.animeSearchResults.state
                        )
                    "
                    text="Loading results, please wait..."
                />
                <p
                    class="mt-6 opacity-75 text-center"
                    v-else-if="others.animeSearchResults.state === 'failed'"
                >
                    Failed to fetch results!
                </p>
                <p
                    class="mt-6 opacity-75 text-center"
                    v-else-if="
                        others.animeSearchResults.state === 'resolved' &&
                        !others.animeSearchResults.data
                    "
                >
                    No results were found.
                </p>
                <div
                    class="grid md:grid-cols-1 grid-cols-2 gap-2"
                    v-else="
                        others.animeSearchResults.state === 'resolved' &&
                        others.animeSearchResults.data
                    "
                >
                    <div
                        class="
                            col-span-1
                            flex flex-row
                            justify-center
                            items-center
                            gap-4
                            bg-gray-200
                            dark:bg-gray-700
                            hover-pop
                            p-3
                            rounded
                            cursor-pointer
                        "
                        v-for="item in others.animeSearchResults.data"
                        @click.stop.prevent="
                            !!void changeItem(item.node.id.toString())
                        "
                    >
                        <img
                            class="flex-none w-12 rounded"
                            :src="item.node.main_picture.medium"
                            :alt="item.node.title"
                        />

                        <div class="flex-grow">
                            <p class="text-lg font-bold">
                                {{ item.node.title }}
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </Popup>
    </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import MyAnimeList, {
    AnimeListEntity,
    AnimeEntity,
    AnimeStatus,
    AnimeStatusType,
} from "../../plugins/integrations/myanimelist";
import { Store } from "../../plugins/api";
import { StateController, constants, util } from "../../plugins/util";
import { MyAnimeListCachedAnimeTitles } from "../../plugins/types";

import Loading from "../Loading.vue";
import Popup from "../Popup.vue";

export default defineComponent({
    props: {
        id: String,
        altTitle: String,
        altURL: String,
    },
    components: {
        Loading,
        Popup,
    },
    data() {
        const data: {
            computedId: string | null;
            computedAltTitle: string | null;
            loggedIn: boolean;
            logo: string;
            info: StateController<AnimeEntity>;
            allowedStatus: string[];
            others: {
                animeSearchResults: StateController<AnimeListEntity["data"]>;
            };
            showSearch: boolean;
        } = {
            computedId: this.id || null,
            computedAltTitle: this.altTitle || null,
            loggedIn: MyAnimeList.isLoggedIn(),
            logo: constants.assets.images.myAnimeListLogo,
            info: util.createStateController(),
            allowedStatus: <any>AnimeStatus,
            others: {
                animeSearchResults: util.createStateController(),
            },
            showSearch: false,
        };

        return data;
    },
    mounted() {
        this.initiate();
    },
    methods: {
        async initiate() {
            if (this.computedId) {
                return this.getInfo();
            }

            let proceed = true;
            if (this.altURL) {
                proceed = await this.getCached();
            }
            if (!proceed) return this.getInfo();

            if (this.altTitle) {
                proceed = await this.searchMAL();
                const first = this.others.animeSearchResults.data?.[0];
                if (proceed && first) {
                    this.computedId = first.node.id.toString();
                    this.saveCache();
                    this.getInfo();
                }
            }
        },
        async getCached() {
            if (!this.altURL) return false;

            const store = await Store.getClient();
            const all: MyAnimeListCachedAnimeTitles[] =
                (await store.get(constants.storeKeys.myAnimeListCacheTitles)) ||
                [];

            const cached = all.find((x) => x.altURLs.includes(this.altURL!));
            if (cached) {
                this.computedId = cached.id;
                return true;
            }
            return false;
        },
        async saveCache() {
            if (!this.computedId || !this.altURL) return false;

            const store = await Store.getClient();
            const all: MyAnimeListCachedAnimeTitles[] =
                (await store.get(constants.storeKeys.myAnimeListCacheTitles)) ||
                [];

            const index = all.findIndex((x) => x.id === this.computedId);
            if (index >= 0) {
                const ele = all[index];
                all[index] = {
                    id: ele.id,
                    altURLs: [...ele.altURLs, this.altURL],
                };
            } else {
                all.push({
                    id: this.computedId,
                    altURLs: [this.altURL],
                });
            }

            await store.set(constants.storeKeys.myAnimeListCacheTitles, all);
        },
        async searchMAL() {
            if (!this.altTitle) return false;

            this.others.animeSearchResults.state = "resolved";
            const animes = await MyAnimeList.searchAnime(this.altTitle);
            if (animes) {
                this.others.animeSearchResults.data = animes.data;
                return true;
            }

            this.others.animeSearchResults.state = "resolved";
            return false;
        },
        async changeItem(id: string) {
            this.computedId = id;
            await this.getInfo();
            this.saveCache();
            this.toggleSearch();
        },
        async getInfo() {
            this.info.state = "resolving";
            if (this.computedId) {
                const info = await MyAnimeList.getAnime(this.computedId);
                if (info) {
                    this.info.state = "resolved";
                    this.info.data = info;
                } else {
                    this.info.state = "failed";
                }
            }
        },
        async updateStatus(event: any) {
            if (!this.computedId) return;

            const value = event.target.value;
            if (this.allowedStatus.includes(value)) {
                await MyAnimeList.updateAnime(this.computedId, {
                    status: <any>value,
                });
            }
        },
        async setEpisode(
            episode: number,
            status: AnimeStatusType = "watching",
            autoComplete: boolean = true
        ) {
            if (
                !this.computedId ||
                !this.info.data ||
                episode > this.info.data.num_episodes
            )
                return;

            if (autoComplete && this.info.data.num_episodes === episode) {
                status = "completed";
            }

            try {
                const res = await MyAnimeList.updateAnime(this.computedId, {
                    num_watched_episodes: episode,
                    status,
                });
                if (res) {
                    this.info.data.my_list_status = {
                        status: res.status,
                        score: res.score,
                        num_episodes_watched: res.num_episodes_watched,
                        is_rewatching: res.is_rewatching,
                        updated_at: res.updated_at,
                    };
                }
            } catch (err) {
                this.$logger.emit(
                    "error",
                    `Failed to update episode while syncing with MAL: ${err?.message}`
                );
            }
        },
        toggleSearch() {
            this.showSearch = !this.showSearch;
        },
    },
});
</script>
