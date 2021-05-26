<template>
    <div>
        <PageTitle title="Search" />
        <div class="mt-6 flex flex-row justify-center items-center gap-2">
            <input
                class="flex-grow text-box"
                v-model="terms"
                type="text"
                placeholder="Type in anime's name..."
                @keypress.enter="search()"
            />
            <button type="submit" class="btn" @click.prevent="search()">
                Search
            </button>
        </div>

        <div
            class="
                flex flex-row
                justify-center
                items-center
                flex-wrap
                gap-2
                mt-6
            "
        >
            <div
                :class="[
                    'px-2 py-0.5 rounded cursor-pointer',
                    selectedPlugin.includes(plugin.name)
                        ? 'bg-green-400 dark:bg-green-500 text-white'
                        : 'bg-gray-100 dark:bg-gray-800',
                ]"
                :title="
                    selectedPlugin.includes(plugin.name)
                        ? 'Selected'
                        : 'Disabled'
                "
                v-for="plugin in allPlugins"
            >
                <p @click.prevent="toggleSelected(plugin.name)">
                    {{ plugin.name }}
                </p>
            </div>
        </div>

        <p class="text-center mt-6 opacity-75" v-if="state === 'search'">
            Enter something to search for!
        </p>
        <Loading
            class="mt-8"
            v-else-if="state === 'loading'"
            :text="`Fetching results for ${terms}...`"
        />
        <p
            class="text-center mt-6 opacity-75"
            v-else-if="state === 'noresults'"
        >
            No results were found.
        </p>

        <div class="mt-8" v-if="result && result.length">
            <div class="grid grid-cols-1 lg:grid-cols-2 gap-3 items-center">
                <div
                    class="col-span-1"
                    v-for="anime in result"
                    :key="anime.url"
                >
                    <router-link
                        :to="anime.link"
                        class="
                            hover-pop
                            flex flex-row
                            justify-center
                            items-center
                            gap-4
                            bg-gray-100
                            dark:bg-gray-800
                            rounded
                            p-3
                            cursor-pointer
                        "
                    >
                        <img
                            class="rounded"
                            :src="anime.thumbnail"
                            :alt="anime.title"
                            :style="{
                                width: anime.description ? '8rem' : '5rem',
                            }"
                            v-if="anime.thumbnail"
                        />
                        <div class="flex-grow">
                            <p
                                class="
                                    text-xs
                                    opacity-75
                                    text-indigo-500
                                    dark:text-indigo-400
                                    font-bold
                                "
                            >
                                {{ anime.plugin.name }}
                            </p>
                            <p class="mt-0.5 text-lg font-bold leading-snug">
                                {{ anime.title }}
                            </p>
                            <div
                                class="mt-1 flex flex-row gap-1"
                                v-if="
                                    anime.type || anime.episodes || anime.score
                                "
                            >
                                <span
                                    class="
                                        text-white text-xs
                                        px-1
                                        py-0.5
                                        rounded-sm
                                        bg-red-500
                                    "
                                    >Type: {{ anime.type || "-" }}</span
                                >
                                <span
                                    class="
                                        text-white text-xs
                                        px-1
                                        py-0.5
                                        rounded-sm
                                        bg-blue-500
                                    "
                                    >Episodes: {{ anime.episodes || "-" }}</span
                                >
                                <span
                                    class="
                                        text-white text-xs
                                        px-1
                                        py-0.5
                                        rounded-sm
                                        bg-purple-500
                                    "
                                    >Score: {{ anime.score || "-" }}</span
                                >
                            </div>
                            <p
                                class="mt-2 text-sm opacity-75 leading-tight"
                                v-if="anime.description"
                            >
                                {{ anime.description }}
                                <ExternalLink
                                    text="read more at MyAnimeList"
                                    :url="anime.url"
                                />
                            </p>
                            <p
                                class="mt-1 text-sm opacity-75 leading-tight"
                                v-if="anime.air"
                            >
                                {{ anime.air }}
                            </p>
                            <ExternalLink
                                class="text-xs"
                                :text="`View at ${anime.plugin.name}`"
                                :url="anime.url"
                                v-if="!anime.description"
                            />
                        </div>
                    </router-link>
                </div>
            </div>
        </div>
    </div>
</template>

<script lang="ts">
import { defineComponent, watch } from "vue";
import api from "../plugins/api";
import util from "../plugins/util";

import PageTitle from "../components/PageTitle.vue";
import Loading from "../components/Loading.vue";
import ExternalLink from "../components/ExternalLink.vue";

export default defineComponent({
    name: "Search",
    components: {
        PageTitle,
        Loading,
        ExternalLink,
    },
    data() {
        const data: {
            state: "search" | "loading" | "noresults" | "results";
            terms: string;
            result: any[] | null;
            selectedPlugin: string[];
            allPlugins: {
                name: string;
                type: string;
                category: "integration" | "anime" | "manga";
            }[];
        } = {
            state: "search",
            terms: "",
            result: null,
            selectedPlugin: ["MyAnimeList"],
            allPlugins: [
                {
                    name: "MyAnimeList",
                    type: "extended",
                    category: "integration",
                },
            ],
        };

        return data;
    },
    mounted() {
        this.getAllPlugins();
        this.watchPluginChange();
    },
    methods: {
        watchPluginChange() {
            watch(
                () => this.selectedPlugin,
                (cur, prev) => {
                    if (cur !== prev && this.result) {
                        this.search();
                    }
                }
            );
        },
        toggleSelected(plugin: string) {
            this.selectedPlugin = this.selectedPlugin.includes(plugin)
                ? this.selectedPlugin.filter((x) => x !== plugin)
                : [...this.selectedPlugin, plugin];
        },
        async getAllPlugins() {
            const animePlugins = await api.anime.extractors.all();
            animePlugins.forEach((x: string) => {
                this.allPlugins.push({
                    name: x,
                    type: "short",
                    category: "anime",
                });
            });

            const mangaPlugins = await api.manga.extractors.all();
            mangaPlugins.forEach((x: string) => {
                this.allPlugins.push({
                    name: x,
                    type: "short",
                    category: "manga",
                });
            });
        },
        async search() {
            if (!this.terms) {
                return this.$logger.emit(
                    "warn",
                    "Provide some search terms to search!"
                );
            }

            if (this.terms.length < 3) {
                return this.$logger.emit(
                    "warn",
                    "Enter atleast 3 characters to search!"
                );
            }

            this.result = null;
            const results = [];
            this.state = "loading";
            for (const pluginName of this.selectedPlugin) {
                const config = this.allPlugins.find(
                    (x) => x.name === pluginName
                );
                if (!config) {
                    return this.$logger.emit(
                        "error",
                        "Corresponding plugin was not found!"
                    );
                }

                if (config.category === "integration") {
                    let res = await (<any>api.intergrations)[
                        config.name
                    ]?.search(this.terms);

                    if (res.data && config.name === "MyAnimeList") {
                        results.push(
                            ...res.data.map((x: any) => {
                                x.plugin = config;
                                x.description = x.description.replace(
                                    /(read more\.)$/,
                                    ""
                                );
                                x.thumbnail = util.getHighResMALImage(
                                    x.thumbnail
                                );
                                x.link = {
                                    path: "/anime",
                                    query: {
                                        url: x.url,
                                    },
                                };
                                return x;
                            })
                        );
                    }
                } else if (config.category === "anime") {
                    let res = await api.anime.extractors.search(
                        config.name,
                        this.terms
                    );
                    if (res.data) {
                        results.push(
                            ...res.data.map((x: any) => {
                                x.plugin = config;
                                x.link = {
                                    path: "/anime/source",
                                    query: {
                                        plugin: config.name,
                                        url: x.url,
                                    },
                                };
                                return x;
                            })
                        );
                    }
                } else if (config.category === "manga") {
                    let res = await api.manga.extractors.search(
                        config.name,
                        this.terms
                    );
                    if (res.data) {
                        results.push(
                            ...res.data.map((x: any) => {
                                x.plugin = config;
                                x.thumbnail = x.image;
                                x.link = {
                                    path: "/manga/source",
                                    query: {
                                        plugin: config.name,
                                        url: x.url,
                                    },
                                };
                                return x;
                            })
                        );
                    }
                }
            }

            if (!results?.length) {
                this.result = null;
                this.state = "noresults";
                api.rpc({
                    details: "On Search Page",
                });
            } else {
                this.result = results;
                this.state = "results";
                api.rpc({
                    details: `Searching for ${this.terms} (${this.selectedPlugin})`,
                });
            }
        },
    },
});
</script>
