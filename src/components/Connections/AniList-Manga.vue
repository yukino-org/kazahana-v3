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
                    alt="AniList (Manga)"
                />
                <div>
                    <p class="text-xl font-bold">
                        AniList
                        <span class="text-xs ml-0.5 opacity-75">(Manga)</span>
                        <span class="text-xs mx-1 opacity-75" v-if="info.data"
                            >(Vol. {{ info.data.progressVolumes || 0 }}/{{
                                info.data.media.volumes || 0
                            }}
                            Chap.
                            {{ info.data.progress || 0 }}/{{
                                info.data.media.chapters || 0
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
                    v-if="info.data && typeof currentChapter === 'number'"
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
                        v-if="(info.data.progress || 0) >= currentChapter"
                        @click.stop.prevent="!!void setRead(false)"
                    >
                        <Icon class="mr-1" icon="eye-slash" /> Mark as unread
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
                        @click.stop.prevent="!!void setRead(true)"
                    >
                        <Icon class="mr-1" icon="eye" /> Mark as read
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
                    placeholder="Type in manga's name..."
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
                            others.mangaSearchResults.state
                        )
                    "
                    text="Loading results, please wait..."
                />
                <p
                    class="mt-6 opacity-75 text-center"
                    v-else-if="others.mangaSearchResults.state === 'failed'"
                >
                    Failed to fetch results!
                </p>
                <p
                    class="mt-6 opacity-75 text-center"
                    v-else-if="
                        others.mangaSearchResults.state === 'resolved' &&
                        !others.mangaSearchResults.data
                    "
                >
                    No results were found.
                </p>
                <div
                    class="grid gap-2"
                    v-else="
                        others.mangaSearchResults.state === 'resolved' &&
                        others.mangaSearchResults.data
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
                        v-for="item in others.mangaSearchResults.data"
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
    AniListMangaConnectionSubscriber,
    StoreKeys,
} from "../../plugins/types";

import Loading from "../Loading.vue";
import Popup from "../Popup.vue";

type ReducedGetMangaEntity = Omit<
    NotNull<Await<ReturnType<typeof AniList["getManga"]>>>,
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
            info: StateController<ReducedGetMangaEntity>;
            allowedStatus: string[];
            others: {
                mangaSearchResults: StateController<
                    NotNull<Await<ReturnType<typeof AniList["searchManga"]>>>
                >;
            };
            showSearch: boolean;
            currentChapter: number | null;
            currentVolume: number | null;
        } = {
            computedId: this.id || null,
            computedAltTitle: this.altTitle || "",
            loggedIn: AniList.isLoggedIn(),
            logo: constants.assets.images.aniListLogo,
            info: util.createStateController(),
            allowedStatus: <any>Status,
            others: {
                mangaSearchResults: util.createStateController(),
            },
            showSearch: false,
            currentChapter: null,
            currentVolume: null,
        };

        return data;
    },
    mounted() {
        this.initiate();
        this.$bus.subscribe("set-AniList-manga-chapter", this.setChapter);
        this.$bus.subscribe("set-AniList-manga-volume", this.setVolume);
        this.$bus.subscribe("update-AniList-manga-status", this.setStatus);
    },
    beforeDestroy() {
        this.$bus.unsubscribe("set-AniList-manga-chapter", this.setChapter);
        this.$bus.unsubscribe("set-AniList-manga-volume", this.setVolume);
        this.$bus.unsubscribe("update-AniList-manga-status", this.setStatus);
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

                const first = this.others.mangaSearchResults.data?.[0];
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
                (await store.get(StoreKeys.aniListMangaCacheTitles)) || [];

            const cached = all.find((x) => x.altURLs.includes(this.altURL!));

            if (cached) {
                this.computedId = cached.id;
            }
        },
        async saveCache() {
            if (!this.computedId || !this.altURL) return false;

            const store = await Store.getClient();
            let all =
                (await store.get(StoreKeys.aniListMangaCacheTitles)) || [];

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

            await store.set(StoreKeys.aniListMangaCacheTitles, all);
        },
        async searchAniList() {
            if (!this.altTitle) return;

            this.others.mangaSearchResults.state = "resolving";
            const mangas = await AniList.searchManga(this.altTitle);
            if (mangas) {
                this.others.mangaSearchResults.data = mangas;
            }

            this.others.mangaSearchResults.state = "resolved";
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
            let info: ReducedGetMangaEntity | null = await AniList.getManga(
                this.computedId
            ).catch(() => null);

            if (!info) {
                const gen = await AniList.getMangaGeneric(
                    this.computedId
                ).catch(() => null);
                if (gen) {
                    info = {
                        status: "CURRENT",
                        progress: 0,
                        progressVolumes: 0,
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
        async updateStatus(event: any) {
            if (!this.computedId) return;

            const value = (event.target as HTMLInputElement | null)?.value;
            if (value && this.allowedStatus.includes(value)) {
                await AniList.updateManga(this.computedId, {
                    status: <any>value,
                });
            }
        },
        async setStatus(data: AniListMangaConnectionSubscriber) {
            if (
                !this.computedId ||
                !this.info.data ||
                (this.info.data.media.chapters &&
                    data.chapter > this.info.data.media.chapters)
            )
                return;

            if (
                data.autoComplete &&
                this.info.data.media.chapters === data.chapter
            ) {
                status = "completed";
            }

            try {
                const res = await AniList.updateManga(this.computedId, {
                    progress: data.chapter,
                    progressVolumes: data.volume,
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
        setChapter(chapter: number | null) {
            this.currentChapter = chapter;
        },
        setVolume(volume: number | null) {
            this.currentVolume = volume;
        },
        toggleSearch() {
            this.showSearch = !this.showSearch;
            if (!this.others.mangaSearchResults.data) {
                this.searchAniList();
            }
        },
        setRead(read: boolean) {
            if (typeof this.currentChapter !== "number") return;

            this.setStatus({
                chapter: read ? this.currentChapter : this.currentChapter - 1,
            });
        },
    },
});
</script>
