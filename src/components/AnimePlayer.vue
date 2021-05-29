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
                    controls
                    :style="{ width: `${playerWidth}%` }"
                    v-if="currentPlaying.type === 'streamable'"
                >
                    <source :src="currentPlaying.url" />
                </video>
            </div>
            <p class="mt-2">
                Stream URL:
                <span
                    class="bg-gray-100 dark:bg-gray-800 rounded px-1 break-all select-all"
                    >{{ currentPlaying.url }}</span
                >
            </p>
        </div>

        <Loading
            class="my-6"
            v-if="state === 'pending' || state === 'loading'"
            text="Fetching links, please wait..."
        />
        <div v-else-if="state === 'result' && info">
            <p class="text-sm opacity-75 mt-4">
                Sources (Episode {{ episode }})
            </p>
            <div class="mt-1 grid gap-2">
                <div v-for="stream in info" :key="stream.url">
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
                            pb-3
                            md:pb-0
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
        <p class="text-center opacity-75 my-6" v-else-if="state === 'noresult'">
            No results were found!
        </p>
    </div>
</template>

<script lang="ts">
import { defineComponent, watch } from "vue";
import { Extractors, ExtractorsEntity, Store } from "../plugins/api";
import { Await } from "../plugins/util";

import Loading from "./Loading.vue";
import ExternalLink from "./ExternalLink.vue";

export default defineComponent({
    components: {
        Loading,
        ExternalLink,
    },
    props: {
        episode: String,
        plugin: String,
        link: String,
    },
    data() {
        const data: {
            state: "pending" | "loading" | "noresult" | "result";
            info: Await<
                ReturnType<ExtractorsEntity["anime"][""]["getDownloadLinks"]>
            > | null;
            currentPlaying: {
                type: string;
                url: string;
            } | null;
            playerWidth: number;
            supportsPlayerWidth: boolean;
        } = {
            state: "pending",
            info: null,
            currentPlaying: null,
            playerWidth: 100,
            supportsPlayerWidth: ["electron"].includes(app_platform),
        };

        return data;
    },
    mounted() {
        this.updateWidth();
        this.getInfo();
        this.watchEpisode();
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
                (cur, prev) => {
                    if (cur !== prev) {
                        this.selectPlayUrl(null, null);
                        this.getInfo();
                    }
                }
            );
        },
        async getInfo() {
            if (!this.plugin) {
                this.state = "noresult";
                return this.$logger.emit("error", "Invalid 'plugin' on query!");
            }
            if (!this.link) {
                this.state = "noresult";
                return this.$logger.emit("error", "Invalid 'plugin' on query!");
            }

            try {
                this.info = null;
                this.state = "loading";
                const client = await Extractors.getClient();
                const data = await client.anime[this.plugin].getDownloadLinks(
                    this.link
                );

                this.state = "result";
                this.info = data.sort((x) =>
                    x.type.some((y) => ["streamable"].includes(y)) ? -1 : 1
                );
            } catch (err) {
                this.state = "noresult";
                this.$logger.emit(
                    "error",
                    `Could not fetch anime's information: ${err}`
                );
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
    },
});
</script>
