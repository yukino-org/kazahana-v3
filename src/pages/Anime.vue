<template>
    <div>
        <Loading
            class="mt-8"
            v-if="['waiting', 'resolving'].includes(info.state)"
            text="Loading anime, please wait..."
        />
        <p
            class="mt-6 opacity-75 text-center"
            v-else-if="info.state === 'failed'"
        >
            Anime information could not be fetched!
        </p>
        <p
            class="mt-6 opacity-75 text-center"
            v-else-if="info.state === 'resolved' && !info.data"
        >
            Failed to fetch anime information!
        </p>
        <div v-else-if="info.state === 'resolved' && info.data">
            <div
                class="
                    flex flex-col
                    md:flex-row
                    justify-between
                    items-center
                    gap-8
                "
            >
                <div class="flex-grow text-center order-last md:order-none">
                    <PageTitle :title="info.data.title" />

                    <div
                        class="
                            flex flex-row
                            justify-center
                            items-center
                            flex-wrap
                            mt-8
                            gap-10
                        "
                    >
                        <div>
                            <p class="opacity-75">Score</p>
                            <p class="text-3xl font-bold">
                                {{ info.data.stats.score || "-" }}
                            </p>
                        </div>

                        <div>
                            <p class="opacity-75">Rank</p>
                            <p class="text-3xl font-bold">
                                {{ info.data.stats.rank || "-" }}
                            </p>
                        </div>

                        <div>
                            <p class="opacity-75">Popularity</p>
                            <p class="text-3xl font-bold">
                                {{ info.data.stats.popularity || "-" }}
                            </p>
                        </div>

                        <div>
                            <p class="opacity-75">Favorite</p>
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
                            <p class="opacity-75">Bookmark</p>
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
                <div class="flex-none">
                    <img
                        class="rounded w-36 sm:w-56"
                        :src="getValidImageUrl(info.data.image)"
                        :alt="info.data.title"
                        v-if="info.data.image"
                    />
                </div>
            </div>

            <div class="mt-8">
                <div v-if="info.data.synopsis">
                    <p
                        class="text-sm opacity-75"
                        @click.stop.prevent="!!void toggleOpen('about')"
                    >
                        About
                        <Icon
                            class="opacity-75 ml-1"
                            icon="caret-up"
                            v-if="opened.about"
                        />
                        <Icon
                            class="opacity-75 ml-1"
                            icon="caret-down"
                            v-else
                        />
                    </p>

                    <transition name="fade">
                        <p v-if="opened.about">{{ info.data.synopsis }}</p>
                    </transition>
                </div>

                <p class="text-sm opacity-75 mt-6">Information</p>
                <div>
                    <p><b>Type:</b> {{ info.data.info.type || "-" }}</p>
                    <p><b>Status:</b> {{ info.data.info.status || "-" }}</p>
                    <p><b>Season:</b> {{ info.data.season || "-" }}</p>
                    <p>
                        <b>Premiered:</b> {{ info.data.info.premiered || "-" }}
                    </p>
                    <p><b>Episodes:</b> {{ info.data.info.episodes || "-" }}</p>
                    <p><b>Aired:</b> {{ info.data.info.aired || "-" }}</p>
                    <p><b>Genres:</b> {{ info.data.info.genres || "-" }}</p>
                    <p><b>Duration:</b> {{ info.data.info.duration || "-" }}</p>
                    <p><b>Rating:</b> {{ info.data.info.rating || "-" }}</p>
                </div>

                <p class="text-sm opacity-75 mt-6">Connections</p>
                <div class="mt-1 grid gap-4">
                    <MyAnimeListAnimeConnection
                        :id="MyAnimeListID"
                        v-if="MyAnimeListID"
                    />

                    <AniListAnimeConnection
                        :altTitle="info.data.title"
                        :altURL="
                            typeof $route.query.url === 'string'
                                ? $route.query.url
                                : undefined
                        "
                        v-if="info.data.title"
                    />
                </div>

                <p class="text-sm opacity-75 mt-6">Sources (Anime)</p>
                <div class="mt-1 grid gap-2">
                    <div v-for="plugin in extractors.anime">
                        <AnimeSourceViewer
                            :title="info.data.title"
                            :pluginKey="plugin"
                            :pluginName="plugin"
                        />
                    </div>
                </div>

                <p class="text-sm opacity-75 mt-6">Sources (Manga)</p>
                <div class="mt-1 grid gap-2">
                    <div v-for="plugin in extractors.manga">
                        <MangaSourceViewer
                            :title="info.data.title"
                            :pluginKey="plugin"
                            :pluginName="plugin"
                        />
                    </div>
                </div>

                <p class="text-sm opacity-75 mt-6">Characters</p>
                <div
                    class="
                        mt-1
                        grid grid-cols-1
                        lg:grid-cols-2
                        gap-2
                        items-center
                    "
                >
                    <div
                        class="col-span-1"
                        v-for="character in info.data.characters"
                    >
                        <div
                            class="
                                p-2
                                grid grid-cols-1
                                sm:grid-cols-2
                                items-center
                                gap-4
                                rounded
                                bg-gray-100
                                dark:bg-gray-800
                            "
                        >
                            <div
                                class="
                                    col-span-1
                                    flex flex-row
                                    justify-between
                                    items-center
                                    gap-3
                                "
                            >
                                <img
                                    class="rounded flex-none"
                                    :src="getValidImageUrl(character.image)"
                                    :alt="character.name"
                                    style="width: 3rem"
                                    v-if="character.image"
                                />
                                <div class="flex-grow">
                                    <p class="leading-tight">
                                        {{ character.name }}
                                    </p>
                                    <p class="mt-1 opacity-75 text-xs">
                                        {{ character.role }}
                                    </p>
                                    <p>
                                        <ExternalLink
                                            class="text-xs"
                                            text="View on MAL"
                                            :url="character.url"
                                        />
                                    </p>
                                </div>
                            </div>
                            <div
                                class="
                                    col-span-1
                                    flex flex-row
                                    justify-between
                                    items-center
                                    gap-3
                                    text-right
                                "
                            >
                                <div class="flex-grow" v-if="character.actor">
                                    <p class="leading-tight">
                                        {{ character.actor.name }}
                                    </p>
                                    <p class="mt-1 opacity-75 text-xs">
                                        {{ character.actor.language }}
                                    </p>
                                    <p>
                                        <ExternalLink
                                            class="text-xs"
                                            text="View on MAL"
                                            :url="character.actor.url"
                                        />
                                    </p>
                                </div>
                                <img
                                    class="rounded flex-none"
                                    :src="
                                        getValidImageUrl(character.actor.image)
                                    "
                                    :alt="character.actor.name"
                                    style="width: 3rem"
                                    v-if="character.actor?.image"
                                />
                            </div>
                        </div>
                    </div>
                </div>

                <p class="text-sm opacity-75 mt-6">Similar</p>
                <div
                    class="
                        mt-1
                        grid grid-cols-1
                        md:grid-cols-2
                        gap-2
                        items-center
                    "
                >
                    <div
                        class="col-span-1 cursor-pointer"
                        @click.stop.prevent="!!void getAnimeInfo(anime.url)"
                        v-for="anime in info.data.recommendations"
                    >
                        <div
                            class="
                                hover-pop
                                flex flex-row
                                justify-start
                                items-center
                                bg-gray-100
                                dark:bg-gray-800
                                rounded
                                p-2
                                gap-4
                            "
                        >
                            <img
                                class="w-16 rounded"
                                :src="getValidImageUrl(anime.thumbnail)"
                                :alt="anime.title"
                                v-if="anime.thumbnail"
                            />
                            <div class="flex-grow">
                                <p class="text-lg font-bold">
                                    {{ anime.title }}
                                </p>
                                <ExternalLink
                                    class="text-xs"
                                    text="View on MyAnimeList"
                                    :url="anime.url"
                                />
                            </div>
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
import ExternalLink from "../components/ExternalLink.vue";
import AnimeSourceViewer from "../components/AnimeSourceViewer.vue";
import MangaSourceViewer from "../components/MangaSourceViewer.vue";
import Loading from "../components/Loading.vue";
import MyAnimeListAnimeConnection from "../components/Connections/MyAnimeList-Anime.vue";
import AniListAnimeConnection from "../components/Connections/AniList-Anime.vue";

export default defineComponent({
    name: "Anime",
    components: {
        PageTitle,
        ExternalLink,
        AnimeSourceViewer,
        MangaSourceViewer,
        Loading,
        MyAnimeListAnimeConnection,
        AniListAnimeConnection,
    },
    data() {
        const data: {
            info: StateController<
                Await<
                    ReturnType<
                        ExtractorsEntity["integrations"]["MyAnimeList"]["getAnimeInfo"]
                    >
                >
            >;
            extractors: {
                anime: string[];
                manga: string[];
            };
            opened: {
                about: boolean;
            };
            [StoreKeys.favorite]: boolean;
            [StoreKeys.bookmarked]: boolean;
            MyAnimeListID: string | null;
        } = {
            info: util.createStateController(),
            extractors: {
                anime: [],
                manga: [],
            },
            opened: {
                about: false,
            },
            [StoreKeys.favorite]: false,
            [StoreKeys.bookmarked]: false,
            MyAnimeListID:
                (typeof this.$route.query.url === "string" &&
                    this.$route.query.url.match(
                        /https:\/\/myanimelist\.net\/anime\/(\d+)/
                    )?.[1]) ||
                null,
        };

        return data;
    },
    mounted() {
        this.getAnimeInfo();
        this.getSources();
    },
    methods: {
        async getAnimeInfo(_url?: string) {
            window.scrollTo({
                top: 0,
            });

            if (_url) {
                this.$router.push({
                    query: {
                        url: _url,
                    },
                });
            }

            const url = this.$route.query.url;

            if (typeof url !== "string") {
                this.info.state = "failed";
                return this.$logger.emit("error", "Missing 'url' in query!");
            }

            try {
                this.info.data = null;
                this.info.state = "resolving";
                const client = await Extractors.getClient();
                const data = await client.integrations.MyAnimeList.getAnimeInfo(
                    url
                );

                this.info.data = data;
                this.info.state = "resolved";

                const rpc = await Rpc.getClient();
                rpc?.({
                    details: "Viewing about",
                    state: this.info.data.title,
                    buttons: [
                        {
                            label: "View",
                            url,
                        },
                    ],
                });

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
                        title: data.title,
                        image: data.image,
                        plugin: "MyAnimeList (Anime)",
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
                    `Failed to fetch anime information: ${err?.message}`
                );
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
                    image: this.info.data.image,
                    plugin: "MyAnimeList (Anime)",
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
        async getSources() {
            const client = await Extractors.getClient();
            this.extractors.anime = Object.keys(client.anime);
            this.extractors.manga = Object.keys(client.manga);
        },
        toggleOpen(key: string) {
            // @ts-ignore
            this.opened[key] = !this.opened[key];
        },
        getValidImageUrl: util.getValidImageUrl,
    },
});
</script>
