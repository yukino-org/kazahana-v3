<template>
    <div>
        <h1 class="mb-1 text-xl font-bold text-indigo-400">
            {{ plugin || "Unknown" }}
        </h1>

        <Loading
            class="mt-8"
            v-if="['waiting', 'resolving'].includes(info.state)"
            text="Fetching information, please wait..."
        />
        <p
            class="mt-6 text-center opacity-75"
            v-else-if="info.state === 'resolved' && !info.data"
        >
            No results were found!
        </p>
        <p
            class="mt-6 text-center opacity-75"
            v-else-if="info.state === 'failed'"
        >
            Failed to fetch manga information!
        </p>
        <div
            :class="['mt-8', selected ? 'md:mt-0' : 'md:mt-4']"
            v-else-if="info.state === 'resolved' && info.data"
        >
            <div
                class="
                    flex flex-col
                    md:flex-row
                    justify-center
                    items-center
                    gap-6
                "
            >
                <img
                    class="flex-none w-36 lg:w-44 rounded"
                    :src="info.data.thumbnail"
                    :alt="info.data.title"
                    v-if="!selected"
                />

                <div
                    :class="[
                        'flex-grow text-center',
                        selected &&
                            'flex flex-col md:flex-row justify-between items-center gap-6',
                    ]"
                >
                    <PageTitle :title="info.data.title" />

                    <div
                        :class="[
                            !selected && 'mt-6',
                            'flex-grow md:flex-initial flex flex-row justify-center items-center flex-wrap',
                            selected ? 'gap-6' : 'gap-8',
                        ]"
                    >
                        <div>
                            <p
                                :class="[
                                    'opacity-75 block',
                                    selected && 'md:hidden',
                                ]"
                            >
                                Favorite
                            </p>

                            <div
                                class="text-3xl mt-0.5 cursor-pointer"
                                @click.stop.prevent="toggleAnime('favorite')"
                            >
                                <Icon
                                    class="text-red-500"
                                    icon="heart"
                                    v-if="favorites"
                                />
                                <Icon
                                    class="opacity-75"
                                    :icon="['far', 'heart']"
                                    v-else
                                />
                            </div>
                        </div>

                        <div>
                            <p
                                :class="[
                                    'opacity-75 block',
                                    selected && 'md:hidden',
                                ]"
                            >
                                Bookmark
                            </p>

                            <div
                                class="text-3xl mt-0.5 cursor-pointer"
                                @click.stop.prevent="toggleAnime('bookmarked')"
                            >
                                <Icon
                                    class="text-indigo-500"
                                    icon="bookmark"
                                    v-if="bookmarked"
                                />
                                <Icon
                                    class="opacity-75"
                                    :icon="['far', 'bookmark']"
                                    v-else
                                />
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div v-if="selected">
                <MangaPager
                    class="mt-10"
                    v-if="plugin && selected.url"
                    :title="info.data.title"
                    :plugin="plugin"
                    :chapTitle="selected.title"
                    :volume="selected.volume"
                    :chapter="selected.chapter"
                    :link="selected.url"
                />
            </div>

            <div v-if="selected">
                <p class="text-center mt-8 text-sm opacity-75">
                    Chapter controls
                </p>
                <div
                    class="
                        flex flex-row
                        justify-center
                        items-center
                        flex-wrap
                        gap-2
                        mt-2
                        mb-4
                    "
                >
                    <button
                        class="
                            text-white
                            bg-indigo-500
                            hover:bg-indigo-600
                            transition
                            duration-200
                            px-3
                            py-2
                            rounded
                            focus:outline-none
                        "
                        @click.stop.prevent="!!void previousChapter()"
                    >
                        <Icon class="mr-1 opacity-75" icon="caret-left" />
                        Previous Chapter
                    </button>

                    <button
                        class="
                            text-white
                            bg-indigo-500
                            hover:bg-indigo-600
                            transition
                            duration-200
                            px-3
                            py-2
                            rounded
                            focus:outline-none
                        "
                        @click.stop.prevent="!!void nextChapter()"
                    >
                        Next Chapter
                        <Icon class="ml-1 opacity-75" icon="caret-right" />
                    </button>
                </div>
            </div>

            <p class="text-sm opacity-75 mt-10">Connections</p>
            <div class="mt-1 grid gap-3">
                <MyAnimeListMangaConnection
                    :altTitle="info.data.title"
                    :altURL="
                        typeof $route.query.url === 'string'
                            ? $route.query.url
                            : undefined
                    "
                />

                <hr class="lg:hidden opacity-40" />

                <AniListMangaConnection
                    :altTitle="info.data.title"
                    :altURL="
                        typeof $route.query.url === 'string'
                            ? $route.query.url
                            : undefined
                    "
                />
            </div>

            <div
                class="
                    flex flex-row
                    justify-between
                    items-center
                    mt-10
                    text-sm
                    opacity-75
                "
            >
                <p>Contents</p>
                <Icon
                    class="cursor-pointer"
                    icon="sort-amount-up"
                    title="Sort"
                    @click.stop.prevent="!!void reverseChapters()"
                />
            </div>

            <div class="mt-1 grid gap-2">
                <div
                    v-for="chap in reversed
                        ? info.data.chapters.slice().reverse()
                        : info.data.chapters"
                >
                    <div
                        class="
                            hover-pop
                            bg-gray-100
                            dark:bg-gray-800
                            px-3
                            py-1.5
                            cursor-pointer
                            rounded
                        "
                        @click.stop.prevent="!!void selectChapter(chap)"
                    >
                        <div>
                            <p class="text-lg">
                                <span class="font-bold">{{ chap.title }}</span>
                                <span class="ml-1 opacity-75"
                                    >(Vol. {{ chap.volume }} Chap.
                                    {{ chap.chapter }})</span
                                >
                            </p>
                            <ExternalLink
                                class="text-xs"
                                :text="`View on ${plugin}`"
                                :url="chap.url"
                            />
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import { Extractors, ExtractorsEntity, Rpc, Store } from "../plugins/api";
import { Await, StateController, util } from "../plugins/util";
import { StoreKeys } from "../plugins/types";

import PageTitle from "../components/PageTitle.vue";
import Loading from "../components/Loading.vue";
import ExternalLink from "../components/ExternalLink.vue";
import MangaPager from "../components/MangaPager.vue";
import MyAnimeListMangaConnection from "../components/Connections/MyAnimeList-Manga.vue";
import AniListMangaConnection from "../components/Connections/AniList-Manga.vue";

type SelectedEntity = Await<
    ReturnType<ExtractorsEntity["manga"][""]["getInfo"]>
>["chapters"][0];

export default defineComponent({
    components: {
        PageTitle,
        Loading,
        ExternalLink,
        MangaPager,
        MyAnimeListMangaConnection,
        AniListMangaConnection,
    },
    data() {
        const data: {
            info: StateController<
                Await<ReturnType<ExtractorsEntity["manga"][""]["getInfo"]>>
            >;
            plugin: string | null;
            link: string | null;
            selected: SelectedEntity | null;
            [StoreKeys.bookmarked]: boolean;
            [StoreKeys.favorite]: boolean;
            reversed: boolean;
        } = {
            info: util.createStateController(),
            plugin:
                typeof this.$route.query.plugin === "string"
                    ? this.$route.query.plugin
                    : null,
            link:
                typeof this.$route.query.url === "string"
                    ? this.$route.query.url
                    : null,
            selected: null,
            [StoreKeys.bookmarked]: false,
            [StoreKeys.favorite]: false,
            reversed: false,
        };

        return data;
    },
    mounted() {
        this.getInfo();
    },
    methods: {
        async getInfo() {
            if (!this.plugin) {
                this.info.state = "failed";
                return this.$logger.emit("error", "Invalid 'plugin' on query!");
            }
            if (!this.link) {
                this.info.state = "failed";
                return this.$logger.emit("error", "Invalid 'plugin' on query!");
            }

            try {
                this.info.state = "resolving";
                const client = await Extractors.getClient();
                const data = await client.manga[this.plugin].getInfo(this.link);

                data.chapters = util.tryArrange(data.chapters, "chapter");
                this.info.data = data;
                this.info.state = "resolved";

                const chapter = this.$route.query.chapter,
                    volume = this.$route.query.volume;
                delete this.$route.query.chapter;
                delete this.$route.query.volume;

                if (typeof chapter === "string" && typeof volume === "string") {
                    const foundChap = this.info.data.chapters.find(
                        (x) => x.chapter === chapter && x.volume === volume
                    );
                    if (foundChap) {
                        this.selectChapter(foundChap);
                    }
                }

                this.refreshRpc();

                const store = await Store.getClient();

                ([StoreKeys.bookmarked, StoreKeys.favorite] as const).forEach(
                    async (key) => {
                        const allBookmarked = (await store.get(key)) || [];

                        this[key] =
                            allBookmarked.findIndex(
                                (x) =>
                                    x.route.queries.url ===
                                    this.$route.query.url
                            ) >= 0;
                    }
                );

                if (!this.$state.props.incognito) {
                    const allRecentlyViewed =
                        (await store.get(StoreKeys.recentlyViewed)) || [];

                    allRecentlyViewed.splice(0, 0, {
                        title: `${data.title}${
                            this.selected
                                ? ` (Vol. ${this.selected.volume} Chap. ${this.selected.chapter})`
                                : ""
                        }`,
                        image: data.thumbnail,
                        plugin: `${this.plugin} (Manga)`,
                        viewedAt: Date.now(),
                        route: {
                            route: this.$route.path,
                            queries: {
                                ...(<Record<string, string>>this.$route.query),
                            },
                        },
                    });

                    await store.set(
                        StoreKeys.recentlyViewed,
                        allRecentlyViewed.slice(0, 100)
                    );
                }
            } catch (err: any) {
                this.info.state = "failed";
                this.$logger.emit(
                    "error",
                    `Could not fetch manga's information: ${err?.message}`
                );
            }
        },
        async selectChapter(chapter: SelectedEntity) {
            this.selected = chapter;

            if (this.selected && this.info.data) {
                const rpc = await Rpc.getClient();
                const extra: string[] = [];
                if (this.selected.volume)
                    extra.push(`Vol. ${this.selected.volume}`);
                if (this.selected.chapter)
                    extra.push(`Chap. ${this.selected.chapter}`);

                rpc?.({
                    details: "Currently reading",
                    state: `${this.info.data.title}${
                        extra.length ? ` (${extra.join(" ")})` : ""
                    } (${this.plugin})`,
                    buttons: this.link
                        ? [
                              {
                                  label: "View",
                                  url: this.link,
                              },
                          ]
                        : undefined,
                });
            } else {
                this.refreshRpc();
            }
        },
        previousChapter() {
            if (!this.info.data?.chapters.length) return;

            if (this.selected) {
                const currentIndex = this.info.data.chapters.findIndex(
                    (x) => x.url === this.selected?.url
                );
                const prevChapter = this.info.data.chapters[currentIndex - 1];
                if (prevChapter) {
                    return this.selectChapter(prevChapter);
                }
            }

            this.selectChapter(
                this.info.data.chapters[this.info.data.chapters.length - 1]
            );
        },
        nextChapter() {
            if (!this.info.data?.chapters.length) return;

            if (this.selected) {
                const currentIndex = this.info.data.chapters.findIndex(
                    (x) => x.url === this.selected?.url
                );
                const nextChapter = this.info.data.chapters[currentIndex + 1];
                if (nextChapter) {
                    return this.selectChapter(nextChapter);
                }
            }

            this.selectChapter(this.info.data.chapters[0]);
        },
        reverseChapters() {
            this.reversed = !this.reversed;
        },
        async refreshRpc() {
            const rpc = await Rpc.getClient();
            if (this.info.data) {
                rpc?.({
                    details: "Viewing chapters and volumes of",
                    state: this.info.data.title,
                    buttons: this.link
                        ? [
                              {
                                  label: "View",
                                  url: this.link,
                              },
                          ]
                        : undefined,
                });
            }
        },
        async toggleAnime(type: "favorite" | "bookmarked") {
            if (!this.info.data) return;

            const store = await Store.getClient();
            const allBookmarked = (await store.get(StoreKeys[type])) || [];

            const index = allBookmarked.findIndex(
                (x) => x.route.queries.url === this.$route.query.url
            );

            if (index >= 0) {
                allBookmarked.splice(index, 1);
                this[StoreKeys[type]] = false;
            } else {
                allBookmarked.splice(0, 0, {
                    title: this.info.data.title,
                    image: this.info.data.thumbnail || "",
                    plugin: <string>this.$route.query.plugin,
                    bookmarkedAt: Date.now(),
                    route: {
                        route: this.$route.path,
                        queries: {
                            ...(<Record<string, string>>this.$route.query),
                        },
                    },
                });
                this[StoreKeys[type]] = true;
            }

            await store.set(StoreKeys[type], allBookmarked);
        },
    },
});
</script>
