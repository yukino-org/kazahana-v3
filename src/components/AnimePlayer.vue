<template>
    <div>
        <div v-if="currentPlaying">
            <div
                class="
                    flex flex-col
                    sm:flex-row
                    justify-between
                    items-center
                    gap-2
                    mb-4
                "
            >
                <p class="text-sm opacity-75 mt-4">
                    Player (Episode {{ episode }})
                </p>
                <div
                    class="text-sm flex flex-row justify-center items-center"
                    v-if="supportsPlayerWidth"
                >
                    <span class="mr-2 opacity-75">Player width:</span>
                    <div class="select w-40">
                        <select class="capitalize" v-model="playerWidth">
                            <option
                                v-for="wid in Array(10)
                                    .fill(null)
                                    .map((x, i) => i * 10 + 10)"
                                :value="wid"
                                :key="wid"
                            >
                                {{ wid }}%
                            </option>
                        </select>
                    </div>
                </div>
            </div>

            <div class="my-2">
                <video
                    class="outline-none"
                    id="video-player"
                    controls
                    :style="{ width: `${playerWidth}%` }"
                    v-if="currentPlaying.type === 'streamable'"
                    @loadedmetadata="initializePlayer()"
                    @timeupdate="updateLastWatched(true)"
                >
                    <source :src="getValidImageUrl(currentPlaying.url)" />
                </video>
            </div>
            <p class="mt-2">
                Stream URL:
                <span
                    class="
                        bg-gray-100
                        dark:bg-gray-800
                        rounded
                        px-1
                        break-all
                        select-all
                    "
                    >{{ currentPlaying.url }}</span
                >
            </p>
        </div>

        <Loading
            class="my-6"
            v-if="['waiting', 'resolving'].includes(info.state)"
            text="Fetching links, please wait..."
        />
        <p
            class="text-center opacity-75 my-6"
            v-else-if="info.state === 'resolved' && !info.data"
        >
            No result were found!
        </p>
        <p
            class="text-center opacity-75 my-6"
            v-else-if="info.state === 'failed'"
        >
            Failed to fetch results!
        </p>
        <div v-else-if="info.state === 'resolved' && info">
            <p class="text-sm opacity-75 mt-4">
                Sources (Episode {{ episode }})
            </p>
            <div class="mt-1 grid gap-2">
                <div v-for="stream in info.data" :key="stream.url">
                    <div
                        class="
                            bg-gray-100
                            dark:bg-gray-800
                            rounded
                            px-3
                            py-1.5
                            flex flex-col
                            md:flex-row
                            justify-between
                            items-center
                            gap-3
                        "
                    >
                        <div class="w-full">
                            <p><b>Host:</b> {{ getHostFromUrl(stream.url) }}</p>
                            <p><b>Quality:</b> {{ stream.quality }}</p>
                            <p>
                                <b>Type:</b>
                                <span class="ml-1 capitalize">{{
                                    stream.type.join(", ").replace(/_/g, " ")
                                }}</span>
                            </p>
                            <p>
                                <ExternalLink
                                    class="text-sm"
                                    text="Open in browser"
                                    :url="stream.url"
                                />
                            </p>
                        </div>
                        <div
                            class="
                                flex-none flex flex-row
                                justify-center
                                items-center
                                flex-wrap
                                mb-1.5
                            "
                            v-if="isPlayable(stream.type)"
                        >
                            <button
                                class="
                                    text-white
                                    bg-indigo-500
                                    hover:bg-indigo-600
                                    transition
                                    duration-200
                                    px-3
                                    py-1
                                    rounded
                                    focus:outline-none
                                "
                                v-if="stream.type.includes('streamable')"
                                @click.prevent="
                                    selectPlayUrl('streamable', stream.url)
                                "
                            >
                                <Icon class="text-sm mr-1" icon="play" /> Play
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script lang="ts">
import { defineComponent, watch } from "vue";
import { Extractors, ExtractorsEntity, Store } from "../plugins/api";
import { Await, StateController, util } from "../plugins/util";
import { LastWatchedEntity } from "../plugins/types";

import Loading from "./Loading.vue";
import ExternalLink from "./ExternalLink.vue";

export default defineComponent({
    components: {
        Loading,
        ExternalLink,
    },
    props: {
        title: String,
        episode: String,
        plugin: String,
        link: String,
    },
    data() {
        const data: {
            info: StateController<
                Await<
                    ReturnType<
                        ExtractorsEntity["anime"][""]["getDownloadLinks"]
                    >
                >
            >;
            currentPlaying: {
                type: string;
                url: string;
            } | null;
            playerWidth: number;
            supportsPlayerWidth: boolean;
            lastWatchUpdated: number;
        } = {
            info: util.createStateController(),
            currentPlaying: null,
            playerWidth: 100,
            supportsPlayerWidth: ["electron"].includes(app_platform),
            lastWatchUpdated: 0,
        };

        return data;
    },
    mounted() {
        this.updateWidth();
        this.watchEpisode();
        this.getInfo();
    },
    methods: {
        async updateWidth() {
            const store = await Store.getClient();
            let wid = (await store.get("settings"))?.defaultPlayerWidth;
            if (wid && !isNaN(wid)) {
                wid = +wid;
                if (wid > 0 && wid <= 100) {
                    this.playerWidth = wid;
                }
            }
        },
        watchEpisode() {
            watch(
                () => this.episode,
                async (cur, prev) => {
                    if (cur !== prev) {
                        this.selectPlayUrl(null, null);
                        await this.getInfo();
                        this.scrollToPlayer();
                    }
                }
            );
        },
        scrollToPlayer() {
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
                this.info.data = null;
                this.info.state = "resolving";

                const client = await Extractors.getClient();
                const data = await client.anime[this.plugin].getDownloadLinks(
                    this.link
                );

                this.info.data = data.sort((x) =>
                    x.type.some((y) => ["streamable"].includes(y)) ? -1 : 1
                );
                this.info.state = "resolved";
            } catch (err) {
                this.info.state = "failed";
                this.$logger.emit(
                    "error",
                    `Could not fetch anime's information: ${err}`
                );
            }
        },
        initializePlayer() {
            const video = <any>document.getElementById("video-player");
            if (video && this.$route.query.watched) {
                const watched =
                    typeof this.$route.query.watched === "string"
                        ? +this.$route.query.watched
                        : null;

                if (watched !== null && !isNaN(watched)) {
                    video.currentTime = watched;
                }

                this.updateLastWatched();
            }
        },
        getHostFromUrl(url: string) {
            return url.match(/https?:\/\/(.*?)\//)?.[1] || url;
        },
        selectPlayUrl(type: string | null, url: string | null) {
            if (!type || !url) return (this.currentPlaying = null);

            this.currentPlaying = {
                type,
                url,
            };

            if (url?.includes("m3u8")) {
                this.$logger.emit(
                    "warn",
                    "Some .m3u8 might just give a black output, those are not supported"
                );
            }
        },
        isPlayable(types: string[]) {
            if (types.includes("streamable")) return true;
            return false;
        },
        async updateLastWatched(fromPlayer: boolean = false) {
            if (fromPlayer) {
                const timeout = 10000;
                const diff = Date.now() - this.lastWatchUpdated;
                if (diff < timeout) return;
            }

            let watchedDuration = 0,
                totalDuration = 0;

            const video = <any>document.getElementById("video-player");
            if (video) {
                if (typeof video.currentTime === "number")
                    watchedDuration = video.currentTime;
                if (typeof video.duration === "number")
                    totalDuration = video.duration;
            }

            const store = await Store.getClient();
            try {
                await store.set("lastWatchedLeft", <LastWatchedEntity>{
                    title: `${this.title} (Episode ${this.episode})`,
                    episode: this.episode,
                    watched: watchedDuration,
                    total: totalDuration,
                    updatedAt: Date.now(),
                    route: {
                        route: this.$route.path,
                        queries: { ...this.$route.query },
                    },
                    showPopup: true,
                });
                this.lastWatchUpdated = Date.now();
            } catch (err) {
                this.$logger.emit(
                    "error",
                    `Failed to updated last watched: ${err?.message}`
                );
            }
        },
        getValidImageUrl: util.getValidImageUrl,
    },
});
</script>
