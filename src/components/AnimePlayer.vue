<template>
    <div>
        <div v-if="currentPlaying">
            <div
                class="
                    flex flex-col
                    sm:flex-row
                    justify-between
                    items-center
                    gap-3.5
                "
            >
                <p class="text-sm opacity-75">Player (Episode {{ episode }})</p>
                <div class="flex flex-row justify-center items-center gap-3.5">
                    <div
                        class="
                            text-sm
                            flex flex-row
                            justify-center
                            items-center
                        "
                    >
                        <span class="mr-2 opacity-75">Autoplay:</span>
                        <input type="checkbox" v-model="autoPlay" />
                    </div>

                    <div
                        class="
                            text-sm
                            flex flex-row
                            justify-center
                            items-center
                        "
                    >
                        <span class="mr-2 opacity-75">Auto next:</span>
                        <input type="checkbox" v-model="autoNext" />
                    </div>

                    <div
                        class="
                            text-sm
                            flex flex-row
                            justify-center
                            items-center
                        "
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
                                >
                                    {{ wid }}%
                                </option>
                            </select>
                        </div>
                    </div>
                </div>
            </div>

            <div class="mt-2">
                <video
                    class="outline-none"
                    id="video-player"
                    controls
                    :style="{ width: `${playerWidth}%` }"
                    v-if="currentPlaying.type === 'streamable'"
                    @loadedmetadata="initializePlayer()"
                    @timeupdate="updateStats(true)"
                    @ended="handleEnded()"
                    :key="currentPlaying.url"
                >
                    <source :src="getValidImageUrl(currentPlaying.url)" />
                </video>
            </div>

            <p class="mt-2" v-if="currentPlaying.url">
                Stream URL:
                <span
                    class="
                        ml-2
                        bg-gray-100
                        dark:bg-gray-800
                        rounded
                        px-1
                        break-all
                        select-all
                        cursor-pointer
                    "
                    @click.stop.prevent="!!void copyCurrentUrlToClipboard()"
                    >{{ shrinkText(currentPlaying.url) }}</span
                >
                <span
                    :class="[
                        'ml-2 cursor-pointer opacity-75 hover:opacity-100 transition duration-200',
                        showCopied && 'opacity-100 text-green-500'
                    ]"
                    @click.stop.prevent="!!void copyCurrentUrlToClipboard()"
                >
                    <transition name="fade" mode="out-in">
                        <Icon icon="check" v-if="showCopied" />
                        <Icon icon="clipboard" v-else />
                    </transition>
                </span>
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
                <div v-for="stream in info.data">
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
                                gap-2
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
                                @click.stop.prevent="
                                    !!void selectPlayUrl(
                                        'streamable',
                                        stream.url
                                    )
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
import {
    Extractors,
    ExtractorsEntity,
    FullScreen,
    Store
} from "../plugins/api";
import { Await, StateController, constants, util } from "../plugins/util";
import { LastLeftEntity, Settings } from "../plugins/types";

import Loading from "./Loading.vue";
import ExternalLink from "./ExternalLink.vue";

export default defineComponent({
    emits: ["playNext"],
    components: {
        Loading,
        ExternalLink
    },
    props: {
        title: String,
        episode: String,
        plugin: String,
        link: String,
        autoPlayHandler: Function
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
            autoPlay: boolean;
            autoNext: boolean;
            fullScreenWatcher: ReturnType<typeof setInterval> | null;
            showCopied: boolean;
        } = {
            info: util.createStateController(),
            currentPlaying: null,
            playerWidth: 100,
            supportsPlayerWidth: ["electron"].includes(app_platform),
            lastWatchUpdated: 0,
            autoPlay: false,
            autoNext: false,
            fullScreenWatcher: null,
            showCopied: false
        };

        return data;
    },
    mounted() {
        this.updatePageSetting();
        this.watchEpisode();
        this.getInfo();
        this.attachFullScreenEvents();
    },
    beforeDestroy() {
        if (this.fullScreenWatcher !== null) {
            clearInterval(this.fullScreenWatcher);
        }
        this.$bus.dispatch("set-MAL-episode", null);
    },
    methods: {
        async updatePageSetting() {
            const store = await Store.getClient();
            const settings: Partial<Settings> =
                (await store.get(constants.storeKeys.settings)) || {};

            let width: number | undefined = settings.defaultPlayerWidth;
            if (width && !isNaN(width)) {
                width = +width;
                if (width > 0 && width <= 100) {
                    this.playerWidth = width;
                }
            }

            this.autoPlay =
                (settings?.autoPlay || constants.defaults.settings.autoPlay) ===
                "enabled";
            this.autoNext =
                (settings?.autoNext || constants.defaults.settings.autoNext) ===
                "enabled";
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
                    behavior: "smooth"
                });
            }
        },
        async getInfo() {
            this.$bus.dispatch("set-MAL-episode", null);

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

                this.info.data = data.sort(x =>
                    x.type.some(y => ["streamable"].includes(y)) ? -1 : 1
                );
                this.info.state = "resolved";

                if (this.episode) {
                    const ep = +this.episode;
                    if (!isNaN(ep)) {
                        this.$bus.dispatch("set-MAL-episode", ep);
                    }
                }
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

                delete this.$route.query.watched;
                this.updateStats();
                this.autoPlay = video.play();
            }
        },
        getHostFromUrl(url: string) {
            return url.match(/https?:\/\/(.*?)\//)?.[1] || url;
        },
        selectPlayUrl(type: string | null, url: string | null) {
            if (!type || !url) return (this.currentPlaying = null);

            this.currentPlaying = {
                type,
                url
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
        attachFullScreenEvents() {
            if ("onfullscreenchange" in document) {
                document.addEventListener(
                    "fullscreenchange",
                    this.setFullScreen
                );
            }

            if ("onmozfullscreenchange" in document) {
                // @ts-ignore
                document.addEventListener(
                    "mozfullscreenchange",
                    this.setFullScreen
                );
            }

            if ("onwebkitfullscreenchange" in document) {
                // @ts-ignore
                document.addEventListener(
                    "webkitfullscreenchange",
                    this.setFullScreen
                );
            }

            if (["capacitor"].includes(app_platform)) {
                this.fullScreenWatcher = setInterval(this.setFullScreen, 5000);
            }
        },
        async setFullScreen() {
            const fullscreened = !!document.fullscreenElement;
            const fullscreen = await FullScreen.getClient();

            if (fullscreened) {
                await fullscreen?.(true);
            } else {
                await fullscreen?.(false);
            }
        },
        async updateStats(fromPlayer: boolean = false) {
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

            if (watchedDuration / totalDuration > 0.8) {
                const ep = this.episode?.match(/\d+/)?.[0];
                if (ep) {
                    this.$bus.dispatch("update-MAL-status", {
                        episode: +ep,
                        status: "watching"
                    });
                }
            }

            const store = await Store.getClient();
            try {
                if (!this.$state.props.incognito) {
                    const lastLeft: LastLeftEntity = {
                        title: `${this.title} (Episode ${this.episode})`,
                        episode: {
                            episode: this.episode!,
                            watched: watchedDuration,
                            total: totalDuration
                        },
                        updatedAt: Date.now(),
                        route: {
                            route: this.$route.path,
                            queries: <Record<string, string>>{
                                ...this.$route.query
                            }
                        },
                        showPopup: true
                    };

                    await store.set(
                        constants.storeKeys.lastWatchedLeft,
                        lastLeft
                    );
                    this.lastWatchUpdated = Date.now();
                }
            } catch (err) {
                this.$logger.emit(
                    "error",
                    `Failed to updated last watched: ${err?.message}`
                );
            }
        },
        async handleEnded() {
            if (this.autoNext) {
                this.$emit("playNext");
            }
        },
        copyCurrentUrlToClipboard() {
            if (!this.currentPlaying?.url) return;
            util.copyToClipboard(this.currentPlaying.url);
            this.showCopied = true;
            setTimeout(() => {
                this.showCopied = false;
            }, 5000);
        },
        shrinkText: (txt: string) => util.shrinkedText(txt, 80),
        getValidImageUrl: util.getValidImageUrl
    }
});
</script>
