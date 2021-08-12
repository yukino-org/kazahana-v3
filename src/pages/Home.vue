<template>
    <div>
        <PageTitle title="Home" />

        <div>
            <p class="-mt-1 text-xl text-indigo-500 font-bold">Top Animes</p>

            <Loading
                class="mt-4"
                v-if="['waiting', 'resolving'].includes(animes.state)"
                text="Fetching top animes, please wait..."
            />
            <p
                class="mt-6 text-center opacity-75"
                v-else-if="animes.state === 'failed'"
            >
                Failed to load top animes!
            </p>
            <p
                class="mt-6 text-center opacity-75"
                v-else-if="
                    animes.state === 'resolved' && !Object.keys(animes).length
                "
            >
                No results were found!
            </p>
            <div
                class="mt-4"
                v-else-if="
                    animes.state === 'resolved' && Object.keys(animes).length
                "
            >
                <div
                    class="
                        mt-1
                        flex flex-row
                        justify-center
                        items-center
                        flex-wrap
                        gap-1
                    "
                >
                    <div v-for="cat in categories">
                        <p
                            :class="[
                                'capitalize px-1.5 rounded-sm cursor-pointer',
                                cat === selected
                                    ? 'bg-indigo-500 text-white'
                                    : 'bg-gray-100 dark:bg-gray-800',
                            ]"
                            @click.stop.prevent="!!void selectCategory(cat)"
                        >
                            {{ makeProperCategory(cat) }}
                        </p>
                    </div>
                </div>

                <Loading
                    class="mt-8"
                    v-if="!animes.data[selected]"
                    :text="`Fetching animes in ${selected}, please wait...`"
                />
                <div
                    class="
                        mt-6
                        grid grid-cols-1
                        md:grid-cols-2
                        gap-2
                        items-center
                    "
                    v-else
                >
                    <div
                        class="col-span-1"
                        v-for="anime in animes.data[selected]"
                    >
                        <div>
                            <router-link
                                :to="{
                                    path: '/anime',
                                    query: {
                                        url: anime.url,
                                    },
                                }"
                            >
                                <div
                                    class="
                                        hover-pop
                                        bg-gray-100
                                        dark:bg-gray-800
                                        px-4
                                        py-2
                                        rounded
                                        flex flex-row
                                        justify-between
                                        items-center
                                        gap-4
                                        text-center
                                    "
                                >
                                    <div>
                                        <p class="text-xs opacity-75">Rank</p>
                                        <p class="font-bold">
                                            #{{ anime.rank }}
                                        </p>
                                        <div class="block sm:hidden">
                                            <p class="text-xs opacity-75">
                                                Score
                                            </p>
                                            <p class="font-bold">
                                                {{ anime.score }}
                                            </p>
                                        </div>
                                    </div>
                                    <img
                                        class="w-14 rounded"
                                        :src="getHighResImage(anime.image)"
                                        :alt="anime.title"
                                        v-if="anime.image"
                                    />
                                    <div class="flex-grow">
                                        <p class="text-lg font-bold">
                                            {{ anime.title }}
                                        </p>

                                        <p class="-mt-1.5">
                                            <ExternalLink
                                                class="text-xs"
                                                text="View on MyAnimeList"
                                                :url="anime.url"
                                            />
                                        </p>
                                    </div>
                                    <div class="hidden sm:block">
                                        <p class="text-xs opacity-75">Score</p>
                                        <p class="font-bold">
                                            {{ anime.score }}
                                        </p>
                                    </div>
                                </div>
                            </router-link>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import { Extractors, ExtractorsEntity, Rpc } from "../plugins/api";
import { Await, StateControllerNoNull, util } from "../plugins/util";

import PageTitle from "../components/PageTitle.vue";
import Loading from "../components/Loading.vue";
import ExternalLink from "../components/ExternalLink.vue";

export default defineComponent({
    name: "Home",
    components: {
        PageTitle,
        Loading,
        ExternalLink,
    },
    data() {
        const data: {
            categories: string[];
            animes: StateControllerNoNull<
                Record<
                    string,
                    Await<
                        ReturnType<
                            ExtractorsEntity["integrations"]["MyAnimeList"]["getTopAnime"]
                        >
                    >
                >
            >;
            selected: string;
        } = {
            categories: [],
            animes: util.createStateControllerNoNull({}),
            selected: "all",
        };

        return data;
    },
    mounted() {
        this.setRpc();
        this.getCategories();
        this.getTopAnimes(this.selected);
    },
    methods: {
        async getCategories() {
            const client = await Extractors.getClient();
            this.categories =
                await client.integrations.MyAnimeList.getTopAnimeTypes();
        },
        async getTopAnimes(type: string) {
            try {
                this.animes.state = "resolving";
                const client = await Extractors.getClient();
                const data = await client.integrations.MyAnimeList.getTopAnime(
                    type
                );
                this.animes.data[type] = data;
                this.animes.state = "resolved";
            } catch (err: any) {
                this.animes.state = "failed";
                this.$logger.emit(
                    "error",
                    `Could not fetch top animes: ${err?.message}`
                );
            }
        },
        async setRpc() {
            const rpc = await Rpc.getClient();
            rpc?.({
                details: "On Homepage",
            });
        },
        selectCategory(type: string) {
            this.selected = type;
            if (!this.animes.data[type]) this.getTopAnimes(type);
        },
        getHighResImage(url: string) {
            return util.getHighResMALImage(url);
        },
        makeProperCategory(cat: string) {
            if (cat === "bypopularity") cat = "Popularity";
            return cat;
        },
    },
});
</script>
