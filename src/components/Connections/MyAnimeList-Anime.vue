<template>
    <div>
        <div
            class="
                flex flex-col
                md:flex-row
                justify-center
                items-center
                gap-2
                md:gap-4
            "
        >
            <div class="w-full md:w-auto flex-grow flex items-center gap-3">
                <img
                    class="w-7 h-auto rounded"
                    :src="logo"
                    alt="MyAnimeList (Anime)"
                />
                <div>
                    <p class="text-xl font-bold">
                        MyAnimeList
                        <span class="text-xs ml-0.5 opacity-75">(Anime)</span>
                        <span class="text-xs mx-1 opacity-75" v-if="info.data"
                            >({{
                                info.data.my_list_status
                                    ?.num_episodes_watched || 0
                            }}/{{ info.data.num_episodes }})</span
                        >
                    </p>
                    <p class="opacity-75 text-xs" v-if="altTitle && info.data">
                        Computed as <b>{{ info.data.title }}</b>
                        <span
                            class="ml-2 text-red-500 font-bold cursor-pointer"
                            @click.stop.prevent="!!void toggleSearch()"
                            >Not this?</span
                        >
                    </p>
                </div>
            </div>

            <div
                class="
                    w-full
                    md:w-auto
                    flex flex-row
                    justify-end
                    items-center
                    gap-2
                    flex-wrap
                    text-sm
                "
            >
                <router-link
                    class="
                        text-white
                        px-3
                        py-2
                        focus:outline-none
                        bg-blue-500
                        hover:bg-blue-600
                        transition
                        duration-200
                        rounded
                    "
                    to="/connections"
                    v-if="!loggedIn"
                >
                    <Icon icon="sign-in-alt" /> Connect
                </router-link>

                <template
                    v-if="info.data && typeof currentEpisode === 'number'"
                >
                    <button
                        class="
                            text-white
                            focus:outline-none
                            bg-red-500
                            hover:bg-red-600
                            transition
                            duration-300
                            px-3
                            py-2
                            rounded
                        "
                        v-if="
                            (info.data.my_list_status?.num_episodes_watched ||
                                0) >= currentEpisode
                        "
                        @click.stop.prevent="!!void setWatched(false)"
                    >
                        <Icon class="mr-1" icon="eye-slash" /> Mark as unwatched
                    </button>
                    <button
                        class="
                            text-white
                            focus:outline-none
                            bg-green-500
                            hover:bg-green-600
                            transition
                            duration-300
                            px-3
                            py-2
                            rounded
                        "
                        v-else
                        @click.stop.prevent="!!void setWatched(true)"
                    >
                        <Icon class="mr-1" icon="eye" /> Mark as watched
                    </button>
                </template>

                <select
                    class="
                        bg-gray-100
                        dark:bg-gray-800
                        rounded
                        py-1.5
                        border-transparent
                        focus:outline-none focus:ring-0
                        capitalize
                    "
                    style="font-size: inherit"
                    @change="updateStatus($event)"
                    v-if="info.data"
                >
                    <option
                        v-for="status in allowedStatus"
                        :value="status"
                        :selected="status === info.data.my_list_status?.status"
                    >
                        {{ status.replace(/_/g, " ") }}
                    </option>
                </select>
            </div>
        </div>

        <Popup :show="showSearch" @close="!!void toggleSearch()">
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
                        bg-gray-100
                        dark:bg-gray-800
                        rounded
                        border-transparent
                        transition
                        duration-300
                    "
                    v-model="computedAltTitle"
                    type="text"
                    placeholder="Type in anime's name..."
                    @keypress.enter="!!void searchMAL()"
                />

                <button
                    type="submit"
                    class="
                        text-white
                        px-4
                        py-2
                        rounded
                        bg-indigo-500
                        hover:bg-indigo-600
                        transition
                        duration-200
                    "
                    @click.stop.prevent="!!void searchMAL()"
                >
                    Search
                </button>
            </div>

            <div class="mt-6 grid gap-2">
                <Loading
                    class="mt-4"
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
                    class="grid gap-2"
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
    AnimeStatus,
} from "../../plugins/integrations/myanimelist";
import { Store } from "../../plugins/api";
import {
    Await,
    NotNull,
    StateController,
    constants,
    util,
} from "../../plugins/util";
import {
    MyAnimeListAnimeConnectionSubscriber,
    StoreKeys,
} from "../../plugins/types";

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
            computedAltTitle: string;
            loggedIn: boolean;
            logo: string;
            info: StateController<
                NotNull<Await<ReturnType<typeof MyAnimeList.getAnime>>>
            >;
            allowedStatus: string[];
            others: {
                animeSearchResults: StateController<
                    NotNull<
                        Await<ReturnType<typeof MyAnimeList.searchAnime>>
                    >["data"]
                >;
            };
            showSearch: boolean;
            currentEpisode: number | null;
        } = {
            computedId: this.id || null,
            computedAltTitle: this.altTitle || "",
            loggedIn: MyAnimeList.isLoggedIn(),
            logo: constants.assets.images.myAnimeListLogo,
            info: util.createStateController(),
            allowedStatus: <any>AnimeStatus,
            others: {
                animeSearchResults: util.createStateController(),
            },
            showSearch: false,
            currentEpisode: null,
        };

        return data;
    },
    mounted() {
        this.initiate();
        this.$bus.subscribe("set-MAL-anime-episode", this.setEpisode);
        this.$bus.subscribe("update-MAL-anime-status", this.setStatus);
    },
    beforeDestroy() {
        this.$bus.subscribe("set-MAL-anime-episode", this.setEpisode);
        this.$bus.unsubscribe("update-MAL-anime-status", this.setStatus);
    },
    methods: {
        async initiate() {
            if (this.computedId) {
                return this.getInfo();
            }

            if (this.altURL) {
                await this.getCached();
            }

            if (this.computedId) {
                return this.getInfo();
            }

            if (this.altTitle) {
                await this.searchMAL();

                const first = this.others.animeSearchResults.data?.[0];
                if (first) {
                    this.computedId = first.node.id.toString();
                    this.saveCache();
                    this.getInfo();
                }
            }
        },
        async getCached() {
            if (!this.altURL) return;

            const store = await Store.getClient();
            const all =
                (await store.get(StoreKeys.myAnimeListAnimeCacheTitles)) || [];

            const cached = all.find((x) => x.altURLs.includes(this.altURL!));
            if (cached) {
                this.computedId = cached.id;
            }
        },
        async saveCache() {
            if (!this.computedId || !this.altURL) return false;

            const store = await Store.getClient();
            const all =
                (await store.get(StoreKeys.myAnimeListAnimeCacheTitles)) || [];

            let added = false;
            all.map((item) => {
                if (item.id === this.computedId) {
                    if (!item.altURLs.includes(this.altURL!)) {
                        item.altURLs.push(this.altURL!);
                    }
                    added = true;
                } else if (item.altURLs.includes(this.altURL!)) {
                    item.altURLs = item.altURLs.filter(
                        (x) => x !== this.altURL!
                    );
                }

                return item;
            });

            if (!added) {
                all.push({
                    id: this.computedId,
                    altURLs: [this.altURL],
                });
            }

            await store.set(StoreKeys.myAnimeListAnimeCacheTitles, all);
        },
        async searchMAL() {
            if (!this.altTitle) return;

            this.others.animeSearchResults.state = "resolving";
            const animes = await MyAnimeList.searchAnime(this.altTitle);
            if (animes) {
                this.others.animeSearchResults.data = animes.data;
            }

            this.others.animeSearchResults.state = "resolved";
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

            const value = (event.target as HTMLInputElement | null)?.value;
            if (value && this.allowedStatus.includes(value)) {
                await MyAnimeList.updateAnime(this.computedId, {
                    status: <any>value,
                });
            }
        },
        async setStatus(data: MyAnimeListAnimeConnectionSubscriber) {
            if (
                !this.computedId ||
                !this.info.data ||
                (this.info.data.num_episodes &&
                    data.episode > this.info.data.num_episodes) ||
                (this.info.data.my_list_status &&
                    this.info.data.my_list_status.num_episodes_watched ===
                        data.episode)
            )
                return;

            if (
                data.autoComplete &&
                this.info.data.num_episodes === data.episode
            ) {
                data.status = "completed";
            }

            try {
                const res = await MyAnimeList.updateAnime(this.computedId, {
                    num_watched_episodes: data.episode,
                    status: data.status || "watching",
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
            } catch (err: any) {
                this.$logger.emit(
                    "error",
                    `Failed to update episode while syncing with MAL: ${err?.message}`
                );
            }
        },
        setEpisode(episode: number | null) {
            this.currentEpisode = episode;
        },
        toggleSearch() {
            this.showSearch = !this.showSearch;
            if (!this.others.animeSearchResults.data) {
                this.searchMAL();
            }
        },
        setWatched(watched: boolean) {
            if (typeof this.currentEpisode !== "number") return;

            this.setStatus({
                episode: watched
                    ? this.currentEpisode
                    : this.currentEpisode - 1,
            });
        },
    },
});
</script>
