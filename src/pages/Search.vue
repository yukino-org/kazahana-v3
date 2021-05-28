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
                        :to="anime.route"
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
                                {{ anime.plugin }}
                            </p>
                            <p class="mt-0.5 text-lg font-bold leading-snug">
                                {{ anime.title }}
                            </p>
                            <div class="mt-1 flex flex-row gap-1">
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
                                    >Episodes:
                                    {{
                                        anime.additional?.episodes || "-"
                                    }}</span
                                >
                                <span
                                    class="
                                        text-white text-xs
                                        px-1
                                        py-0.5
                                        rounded-sm
                                        bg-purple-500
                                    "
                                    >Score:
                                    {{ anime.additional?.score || "-" }}</span
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
                                :text="`View at ${anime.plugin}`"
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
import { RouteLocationRaw } from "vue-router";
import { Extractors, Rpc } from "../plugins/api";
import { util } from "../plugins/util";

import PageTitle from "../components/PageTitle.vue";
import Loading from "../components/Loading.vue";
import ExternalLink from "../components/ExternalLink.vue";

interface ResultType {
    title: string;
    description: string;
    thumbnail: string;
    url: string;
    air: string;
    plugin: string;
    route: RouteLocationRaw;
    type: "anime" | "manga";
    additional?: {
        episodes: string;
        score: string;
    };
}

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
            result: ResultType[] | null;
            selectedPlugin: string[];
            allPlugins: {
                name: string;
                type: string;
                category: "integration-MAL" | "anime" | "manga";
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
                    category: "integration-MAL",
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
            const client = await Extractors.getClient();

            const animePlugins = Object.keys(client.anime);
            animePlugins.forEach((x: string) => {
                this.allPlugins.push({
                    name: x,
                    type: "short",
                    category: "anime",
                });
            });

            const mangaPlugins = Object.keys(client.manga);
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
            const client = await Extractors.getClient();

            for (const pluginName of this.selectedPlugin) {
                try {
                    const config = this.allPlugins.find(
                        (x) => x.name === pluginName
                    );
                    if (!config) {
                        this.$logger.emit(
                            "error",
                            "Corresponding plugin was not found!"
                        );
                    } else if (config.category === "integration-MAL") {
                        const data =
                            await client.integrations.MyAnimeList.search(
                                this.terms
                            );

                        results.push(
                            ...data.map((x) => {
                                const res: ResultType = {
                                    title: x.title,
                                    description: x.description.replace(
                                        /(read more\.)$/,
                                        ""
                                    ),
                                    thumbnail: util.getHighResMALImage(
                                        x.thumbnail
                                    ),
                                    url: x.url,
                                    air: "",
                                    plugin: config.name,
                                    route: {
                                        path: "/anime",
                                        query: {
                                            url: x.url,
                                        },
                                    },
                                    type: "anime",
                                    additional: {
                                        episodes: x.episodes,
                                        score: x.score,
                                    },
                                };
                                return res;
                            })
                        );
                    } else if (config.category === "anime") {
                        const data = await client.anime[config.name].search(
                            this.terms
                        );

                        results.push(
                            ...data.map((x) => {
                                const res: ResultType = {
                                    title: x.title,
                                    description: "",
                                    thumbnail: x.thumbnail,
                                    url: x.url,
                                    air: "",
                                    plugin: config.name,
                                    route: {
                                        path: "/anime/source",
                                        query: {
                                            plugin: config.name,
                                            url: x.url,
                                        },
                                    },
                                    type: "anime",
                                };
                                return res;
                            })
                        );
                    } else if (config.category === "manga") {
                        const data = await client.manga[config.name].search(
                            this.terms
                        );

                        results.push(
                            ...data.map((x) => {
                                const res: ResultType = {
                                    title: x.title,
                                    description: "",
                                    thumbnail: x.image || "",
                                    url: x.url,
                                    air: "",
                                    plugin: config.name,
                                    route: {
                                        path: "/anime/source",
                                        query: {
                                            plugin: config.name,
                                            url: x.url,
                                        },
                                    },
                                    type: "manga",
                                };
                                return res;
                            })
                        );
                    }
                } catch (err) {}
            }

            const rpc = await Rpc.getClient();
            if (!results?.length) {
                this.result = null;
                this.state = "noresults";
                rpc?.({
                    details: "On Search Page",
                });
            } else {
                this.result = results;
                this.state = "results";
                rpc?.({
                    details: `Searching for ${this.terms} (${this.selectedPlugin})`,
                });
            }
        },
    },
});
</script>
