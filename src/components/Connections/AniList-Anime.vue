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
                <img class="w-7 h-auto rounded" :src="logo" alt="AniList" />
                <div>
                    <p class="text-xl font-bold">
                        AniList
                        <span class="text-xs ml-0.5 opacity-75">(Anime)</span>
                        <span class="text-xs ml-1 opacity-75" v-if="info.data"
                            >({{ info.data.progress }}/{{
                                info.data.media.episodes
                            }})</span
                        >
                    </p>
                    <p class="opacity-75 text-xs" v-if="altTitle && info.data">
                        Computed as
                        <b>{{ info.data.media.title.userPreferred }}</b>
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
                        v-if="info.data.progress >= currentEpisode"
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
                        focus:ring-0 focus:outline-none
                        capitalize
                    "
                    style="font-size: inherit"
                    @change="updateStatus($event)"
                    v-if="info.data"
                >
                    <option
                        v-for="status in allowedStatus"
                        :value="status"
                        :selected="status === info.data.status"
                    >
                        {{
                            status[0].toUpperCase() +
                            status.slice(1).toLowerCase()
                        }}
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
                    @keypress.enter="!!void searchAniList()"
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
                    @click.stop.prevent="!!void searchAniList()"
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
                            dark:bg-gray-800
                            hover-pop
                            p-3
                            rounded
                            cursor-pointer
                        "
                        v-for="item in others.animeSearchResults.data"
                        @click.stop.prevent="!!void changeItem(item.id)"
                    >
                        <img
                            class="flex-none w-12 rounded"
                            :src="item.coverImage.medium"
                            :alt="item.title.userPreferred"
                        />

                        <div class="flex-grow">
                            <p class="text-lg font-bold">
                                {{ item.title.userPreferred }}
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
import AniList, { Status } from "../../plugins/integrations/anilist";
import { Store } from "../../plugins/api";
import {
    Await,
    NotNull,
    StateController,
    constants,
    util,
} from "../../plugins/util";
import {
    AniListAnimeConnectionSubscriber,
    StoreKeys,
} from "../../plugins/types";

import Loading from "../Loading.vue";
import Popup from "../Popup.vue";

type ReducedGetAnimeEntity = Omit<
    NotNull<Await<ReturnType<typeof AniList["getAnime"]>>>,
    "id"
>;

export default defineComponent({
    props: {
        id: Number,
        altTitle: String,
        altURL: String,
    },
    components: {
        Loading,
        Popup,
    },
    data() {
        const data: {
            computedId: number | null;
            computedAltTitle: string;
            loggedIn: boolean;
            logo: string;
            info: StateController<ReducedGetAnimeEntity>;
            allowedStatus: string[];
            others: {
                animeSearchResults: StateController<
                    NotNull<Await<ReturnType<typeof AniList["searchAnime"]>>>
                >;
            };
            showSearch: boolean;
            currentEpisode: number | null;
        } = {
            computedId: this.id || null,
            computedAltTitle: this.altTitle || "",
            loggedIn: AniList.isLoggedIn(),
            logo: constants.assets.images.aniListLogo,
            info: util.createStateController(),
            allowedStatus: <any>Status,
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
        this.$bus.subscribe("set-AniList-anime-episode", this.setEpisode);
        this.$bus.subscribe("update-AniList-anime-status", this.setStatus);
    },
    beforeDestroy() {
        this.$bus.unsubscribe("set-AniList-anime-episode", this.setEpisode);
        this.$bus.unsubscribe("update-AniList-anime-status", this.setStatus);
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
                await this.searchAniList();

                const first = this.others.animeSearchResults.data?.[0];
                if (first) {
                    this.computedId = first.id;
                    this.saveCache();
                    this.getInfo();
                }
            }
        },
        async getCached() {
            if (!this.altURL) return;

            const store = await Store.getClient();
            const all =
                (await store.get(StoreKeys.aniListAnimeCacheTitles)) || [];

            const cached = all.find((x) => x.altURLs.includes(this.altURL!));

            if (cached) {
                this.computedId = cached.id;
            }
        },
        async saveCache() {
            if (!this.computedId || !this.altURL) return false;

            const store = await Store.getClient();
            let all =
                (await store.get(StoreKeys.aniListAnimeCacheTitles)) || [];

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

            await store.set(StoreKeys.aniListAnimeCacheTitles, all);
        },
        async searchAniList() {
            if (!this.altTitle) return;

            this.others.animeSearchResults.state = "resolving";
            const animes = await AniList.searchAnime(this.altTitle);
            if (animes) {
                this.others.animeSearchResults.data = animes;
            }

            this.others.animeSearchResults.state = "resolved";
            return;
        },
        async changeItem(id: number) {
            this.computedId = id;
            await this.getInfo();
            this.saveCache();
            this.toggleSearch();
        },
        async getInfo() {
            if (!this.computedId) return;

            this.info.state = "resolving";
            let info: ReducedGetAnimeEntity | null = await AniList.getAnime(
                this.computedId
            ).catch(() => null);

            if (!info) {
                const gen = await AniList.getAnimeGeneric(
                    this.computedId
                ).catch(() => null);
                if (gen) {
                    info = {
                        status: "CURRENT",
                        progress: 0,
                        media: gen,
                    };
                }
            }

            if (info) {
                this.info.state = "resolved";
                this.info.data = info;
            } else {
                this.info.state = "failed";
            }
        },
        async updateStatus(event: Event) {
            if (!this.computedId) return;

            const value = (event.target as HTMLInputElement | null)?.value;
            if (value && this.allowedStatus.includes(value)) {
                await AniList.updateAnime(this.computedId, {
                    status: <any>value,
                });
            }
        },
        async setStatus(data: AniListAnimeConnectionSubscriber) {
            if (
                !this.computedId ||
                !this.info.data ||
                (this.info.data.media.episodes &&
                    data.episode > this.info.data.media.episodes) ||
                this.info.data.progress === data.episode
            )
                return;

            if (
                data.autoComplete &&
                this.info.data.media.episodes === data.episode
            ) {
                data.status = "COMPLETED";
            }

            try {
                const res = await AniList.updateAnime(this.computedId, {
                    progress: data.episode,
                    status: data.status || "CURRENT",
                });
                if (res) {
                    this.info.data = res;
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
                this.searchAniList();
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
