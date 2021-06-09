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
            <button
                type="submit"
                class="btn"
                @click.stop.prevent="!!void search()"
            >
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
                        : 'bg-gray-100 hover:bg-gray-200 dark:bg-gray-800 dark:hover:bg-gray-700 transition duration-300',
                ]"
                :title="
                    selectedPlugin.includes(plugin.name)
                        ? 'Selected'
                        : 'Disabled'
                "
                v-for="plugin in allPlugins"
            >
                <p @click.stop.prevent="!!void toggleSelected(plugin.name)">
                    {{ plugin.name }}
                </p>
            </div>
        </div>

        <p
            class="text-center mt-6 opacity-75"
            v-if="result.state === 'waiting'"
        >
            Enter something to search for!
        </p>
        <Loading
            class="mt-8"
            v-else-if="result.state === 'resolving'"
            :text="`Fetching results for ${terms}...`"
        />
        <p
            class="text-center mt-6 opacity-75"
            v-else-if="result.state === 'failed'"
        >
            Failed to fetch results.
        </p>
        <p
            class="text-center mt-6 opacity-75"
            v-else-if="result.state === 'resolved' && result.data?.length === 0"
        >
            No results were found.
        </p>
        <div
            class="mt-8"
            v-else-if="result.state === 'resolved' && result.data"
        >
            <div class="grid grid-cols-1 lg:grid-cols-2 gap-3 items-center">
                <div class="col-span-1" v-for="anime in result.data">
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
                            :class="[
                                'rounded flex-none w-20',
                                anime.description ? 'sm:w-32' : 'sm:w-20',
                            ]"
                            :src="getValidImageUrl(anime.thumbnail)"
                            :alt="anime.title"
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
                            <div class="mt-1 flex flex-row flex-wrap gap-1">
                                <span
                                    class="
                                        capitalize
                                        text-white text-xs
                                        px-1
                                        py-0.5
                                        rounded-sm
                                        bg-red-500
                                    "
                                    v-if="anime.type"
                                    >Type: {{ anime.type }}</span
                                >
                                <span
                                    class="
                                        text-white text-xs
                                        px-1
                                        py-0.5
                                        rounded-sm
                                        bg-blue-500
                                    "
                                    v-if="anime.additional?.episodes"
                                    >Episodes:
                                    {{ anime.additional.episodes }}</span
                                >
                                <span
                                    class="
                                        text-white text-xs
                                        px-1
                                        py-0.5
                                        rounded-sm
                                        bg-purple-500
                                    "
                                    v-if="anime.additional?.score"
                                    >Score: {{ anime.additional.score }}</span
                                >
                            </div>
                            <p
                                class="
                                    mt-2
                                    text-sm
                                    opacity-75
                                    leading-tight
                                    hidden
                                    sm:block
                                "
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
import { Extractors, Rpc, Store } from "../plugins/api";
import { StateController, constants, util } from "../plugins/util";
import { RecentlyBrowsedEntity } from "../plugins/types";

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
            terms: string;
            result: StateController<ResultType[]>;
            selectedPlugin: string[];
            allPlugins: {
                name: string;
                type: string;
                category: "integration-MAL" | "anime" | "manga";
            }[];
        } = {
            terms:
                typeof this.$route.query.terms === "string"
                    ? this.$route.query.terms
                    : "",
            result: util.createStateController(),
            selectedPlugin: Array.isArray(this.$route.query.plugins)
                ? <string[]>(
                      this.$route.query.plugins.filter(
                          (x) => typeof x === "string"
                      )
                  )
                : ["MyAnimeList"],
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
        if (this.$route.query.autoSearch === "1") {
            this.search();
        }
    },
    methods: {
        watchPluginChange() {
            watch(
                () => this.selectedPlugin,
                (cur, prev) => {
                    if (cur !== prev && this.terms) {
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

            if (!this.selectedPlugin.length) {
                return this.$logger.emit(
                    "warn",
                    "Select atleast one source to search!"
                );
            }

            this.result.data = null;
            const results = [];
            this.result.state = "resolving";
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
                                        path: "/manga/source",
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
                } catch (err) {
                    this.result.state = "failed";
                    return this.$logger.emit(
                        "error",
                        `Something went wrong: ${err?.message}`
                    );
                }
            }

            const rpc = await Rpc.getClient();
            this.result.data = results;
            this.result.state = "resolved";
            rpc?.({
                details: this.result.data.length
                    ? `Searching for ${this.terms} (${this.selectedPlugin})`
                    : "On Search Page",
            });

            const store = await Store.getClient();
            const allSearchedEntities: RecentlyBrowsedEntity[] =
                (await store.get(constants.storeKeys.recentlyBrowsed)) || [];

            allSearchedEntities.splice(0, 0, {
                terms: this.terms,
                searchedAt: Date.now(),
                resultsFound: results.length,
                route: {
                    route: this.$route.path,
                    queries: {
                        terms: this.terms,
                        plugins: [...this.selectedPlugin],
                    },
                },
            });
            allSearchedEntities.length = 50;

            await store.set(
                constants.storeKeys.recentlyBrowsed,
                allSearchedEntities
            );
        },
        getValidImageUrl: util.getValidImageUrl,
    },
});
</script>
