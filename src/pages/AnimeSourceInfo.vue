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
            class="text-center opacity-75 mt-4"
            v-else-if="info.state === 'resolved' && !info.data"
        >
            No results were found!
        </p>
        <div v-else-if="info.state === 'resolved' && info.data">
            <div
                class="
                    flex flex-col
                    sm:flex-row
                    justify-center
                    sm:justify-between
                    items-center
                    flex-wrap
                    gap-4
                "
            >
                <PageTitle :title="info.data.title" />

                <div
                    class="
                        flex flex-row
                        justify-between
                        items-center
                        flex-wrap
                        gap-4
                    "
                >
                    <div>
                        <div
                            class="text-2xl mt-0.5 cursor-pointer"
                            @click.stop.prevent="toggleAnime('favorite')"
                        >
                            <Icon
                                class="text-red-500"
                                icon="heart"
                                v-if="favorite"
                            />
                            <Icon
                                class="opacity-75"
                                :icon="['far', 'heart']"
                                v-else
                            />
                        </div>
                    </div>

                    <div>
                        <div
                            class="text-2xl mt-0.5 cursor-pointer"
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

            <div v-if="selected">
                <AnimePlayer
                    class="mt-1"
                    v-if="selected.episode && plugin && selected.url"
                    :title="info.data.title"
                    :episode="selected.episode"
                    :plugin="plugin"
                    :link="selected.url"
                    :autoPlayHandler="() => nextEpisode()"
                />
                <div
                    class="
                        mt-4
                        flex flex-row
                        justify-center
                        items-center
                        flex-wrap
                        gap-2
                    "
                >
                    <button
                        class="
                            bg-indigo-500
                            hover:bg-indigo-600
                            text-white
                            transition
                            duration-300
                            px-3
                            py-1
                            rounded
                            focus:outline-none
                        "
                        @click.stop.prevent="!!void prevEpisode()"
                    >
                        <Icon class="mr-1 opacity-75" icon="caret-left" />
                        Previous Episode
                    </button>
                    <button
                        class="
                            bg-indigo-500
                            hover:bg-indigo-600
                            text-white
                            transition
                            duration-300
                            px-3
                            py-1
                            rounded
                            focus:outline-none
                        "
                        @click.stop.prevent="!!void nextEpisode()"
                    >
                        Next Episode
                        <Icon class="ml-1 opacity-75" icon="caret-right" />
                    </button>
                </div>
            </div>

            <p></p>
            <p class="text-sm opacity-75 mt-6">Connections</p>
            <div class="mt-1 grid gap-2">
                <MyAnimeListConnection
                    ref="MyAnimeListConnection"
                    :altTitle="info.data.title"
                />
            </div>

            <div>
                <div
                    class="
                        flex flex-row
                        justify-between
                        items-center
                        mt-6
                        text-sm
                        opacity-75
                    "
                >
                    <p>Episodes</p>
                    <Icon
                        class="cursor-pointer"
                        icon="sort-amount-up"
                        title="Sort"
                        @click.stop.prevent="!!void reverseEpisodes()"
                    />
                </div>
                <div
                    class="
                        mt-1
                        grid grid-cols-2
                        md:grid-cols-3
                        lg:grid-cols-4
                        gap-2
                        items-center
                    "
                >
                    <div class="col-span-1" v-for="ep in info.data.episodes">
                        <div
                            class="
                                hover-pop
                                bg-gray-100
                                dark:bg-gray-800
                                text-center
                                p-1.5
                                cursor-pointer
                                rounded
                            "
                            @click.stop.prevent="!!void selectEpisode(ep)"
                        >
                            <p>
                                Episode <b>{{ ep.episode }}</b>
                            </p>
                            <ExternalLink
                                class="text-xs"
                                :text="`View on ${plugin}`"
                                :url="ep.url"
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
import { Await, StateController, constants, util } from "../plugins/util";
import { BookmarkedEntity, RecentlyViewedEntity } from "../plugins/types";

import PageTitle from "../components/PageTitle.vue";
import Loading from "../components/Loading.vue";
import ExternalLink from "../components/ExternalLink.vue";
import AnimePlayer from "../components/AnimePlayer.vue";
import MyAnimeListConnection from "../components/Connections/MyAnimeList.vue";

interface SelectedEntity {
    episode: string;
    url: string;
}

export default defineComponent({
    components: {
        PageTitle,
        Loading,
        ExternalLink,
        AnimePlayer,
        MyAnimeListConnection,
    },
    data() {
        const data: {
            info: StateController<
                Await<ReturnType<ExtractorsEntity["anime"][""]["getInfo"]>>
            >;
            plugin: string | null;
            link: string | null;
            selected: SelectedEntity | null;
            favorite: boolean;
            bookmarked: boolean;
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
            favorite: false,
            bookmarked: false,
        };

        return data;
    },
    mounted() {
        this.getInfo();
    },
    methods: {
        scrollToView() {
            const ele = document.getElementById("main-container");
            if (ele) {
                window.scrollTo({
                    top: ele.offsetTop,
                    behavior: "smooth",
                });
            }
        },
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
                const data = await client.anime[this.plugin].getInfo(this.link);
                this.info.data = data;
                this.info.state = "resolved";

                const episode = this.$route.query.episode;
                if (typeof episode === "string") {
                    const foundEp = this.info.data.episodes.find(
                        (x) => x.episode === episode
                    );
                    if (foundEp) {
                        this.selectEpisode(foundEp);
                    }
                }

                this.refreshRpc();

                const store = await Store.getClient();

                (["bookmarked", "favorite"] as const).forEach(async (type) => {
                    const allBookmarked: BookmarkedEntity[] =
                        (await store.get(constants.storeKeys[type])) || [];

                    this[type] =
                        allBookmarked.findIndex(
                            (x) => x.route.queries.url === this.$route.query.url
                        ) >= 0;
                });

                if (!this.$constants.props.incognito) {
                    const allRecentlyViewed: RecentlyViewedEntity[] =
                        (await store.get(constants.storeKeys.recentlyViewed)) ||
                        [];
                    allRecentlyViewed.splice(0, 0, {
                        title: `${data.title}${
                            this.selected
                                ? ` (Episode ${this.selected.episode})`
                                : ""
                        }`,
                        image: "",
                        plugin: `${this.plugin} (Anime)`,
                        viewedAt: Date.now(),
                        route: {
                            route: this.$route.path,
                            queries: {
                                ...(<Record<string, string>>this.$route.query),
                            },
                        },
                    });
                    await store.set(
                        constants.storeKeys.recentlyViewed,
                        allRecentlyViewed.slice(0, 100)
                    );
                }
            } catch (err) {
                this.info.state = "failed";
                this.$logger.emit(
                    "error",
                    `Could not fetch anime's information: ${err}`
                );
            }
        },
        reverseEpisodes() {
            if (!this.info.data?.episodes) return;
            this.info.data.episodes = this.info.data.episodes.reverse();
        },
        async selectEpisode(ep: SelectedEntity) {
            this.selected = ep;
            this.scrollToView();

            const episodeNum = ep.episode.match(/\d+/)?.[0];
            if (episodeNum && this.$refs.MyAnimeListConnection)
                (<any>this.$refs.MyAnimeListConnection).setEpisode(
                    +episodeNum,
                    "watching"
                );

            if (this.selected && this.info.data) {
                const rpc = await Rpc.getClient();
                rpc?.({
                    details: "Currently watching",
                    state: `${this.info.data.title} (Episode ${
                        this.selected.episode
                    }) ${this.plugin ? `(${this.plugin})` : ""}`,
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
        prevEpisode() {
            if (!this.info.data || !this.selected) return;
            const cur = this.info.data.episodes.findIndex(
                (x) => x.episode === this.selected?.episode
            );
            if (typeof cur === "number") {
                const prev = this.info.data.episodes[cur - 1];
                if (prev) this.selectEpisode(prev);
            }
        },
        nextEpisode() {
            if (!this.info.data || !this.selected) return;
            const cur = this.info.data.episodes.findIndex(
                (x) => x.episode === this.selected?.episode
            );
            if (typeof cur === "number") {
                const next = this.info.data.episodes[cur + 1];
                if (next) this.selectEpisode(next);
            }
        },
        async refreshRpc() {
            const rpc = await Rpc.getClient();
            if (this.info.data) {
                rpc?.({
                    details: "Viewing episodes of",
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
        async toggleAnime(type: "bookmarked" | "favorite") {
            if (!this.info.data) return;

            const store = await Store.getClient();
            const allBookmarked: BookmarkedEntity[] =
                (await store.get(constants.storeKeys[type])) || [];

            const index = allBookmarked.findIndex(
                (x) => x.route.queries.url === this.$route.query.url
            );

            if (index >= 0) {
                allBookmarked.splice(index, 1);
                this[type] = false;
            } else {
                allBookmarked.splice(0, 0, {
                    title: this.info.data.title,
                    image: "",
                    plugin: "MyAnimeList",
                    bookmarkedAt: Date.now(),
                    route: {
                        route: this.$route.path,
                        queries: {
                            ...(<Record<string, string>>this.$route.query),
                        },
                    },
                });
                this[type] = true;
            }

            await store.set(constants.storeKeys[type], allBookmarked);
        },
    },
});
</script>
