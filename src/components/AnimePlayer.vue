<template>
    <div>
        <div v-if="playUrl">
            <p class="text-sm opacity-75 mt-4">
                Player (Episode {{ episode }})
            </p>
            <div class="mt-2">
                <video class="outline-none w-full" controls>
                    <source :src="playUrl" />
                </video>
            </div>
            <p class="mt-2">
                Stream URL:
                <span
                    class="bg-gray-100 dark:bg-gray-800 rounded px-1 break-all"
                    >{{ playUrl }}</span
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
                            flex flex-row
                            justify-center
                            items-center
                        "
                    >
                        <div class="flex-grow">
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
                        <div>
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
                                @click="selectPlayUrl(stream.url)"
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
import api from "../plugins/api";

import Loading from "./Loading.vue";
import ExternalLink from "./ExternalLink.vue";

export default defineComponent({
    components: {
        Loading,
        ExternalLink,
    },
    props: {
        episode: Number,
        plugin: String,
        link: String,
    },
    data() {
        const data: {
            state: "pending" | "loading" | "noresult" | "result";
            info: any;
            playUrl: string | null;
        } = {
            state: "pending",
            info: null,
            playUrl: null,
        };

        return data;
    },
    mounted() {
        this.getInfo();
        this.watchEpisode();
    },
    methods: {
        watchEpisode() {
            watch(
                () => this.episode,
                (cur, prev) => {
                    if (cur !== prev) {
                        this.info = null;
                        this.playUrl = null;
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

            this.state = "loading";
            const { data, err } = await api.anime.extractors.links(
                this.plugin,
                this.link
            );
            if (err) {
                this.state = "noresult";
                return this.$logger.emit(
                    "error",
                    `Could not fetch anime's information: ${err}`
                );
            }

            this.state = "result";
            this.info = data;
        },
        getHostFromUrl(url: string) {
            return url.match(/https?:\/\/(.*?)\//)?.[1] || url;
        },
        selectPlayUrl(url: string) {
            this.playUrl = url;
            if (url.includes("m3u8")) {
                this.$logger.emit(
                    "warn",
                    "Some .m3u8 might just give a black output, those are not supported"
                );
            }
        },
    },
});
</script>
