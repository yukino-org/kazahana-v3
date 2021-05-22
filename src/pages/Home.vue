<template>
    <div>
        <PageTitle title="Home" />
        <div>
            <p class="text-xl">Top Animes</p>
            <Loading
                v-if="!hasLoaded"
                text="Fetching top animes, please wait..."
            />
            <div v-else-if="hasLoaded && Object.keys(animes).length">
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
                    <div v-for="cat in categories" :key="cat">
                        <p
                            :class="[
                                'capitalize px-1 rounded-sm cursor-pointer',
                                cat === selected
                                    ? 'bg-indigo-500 text-white'
                                    : 'bg-gray-100 dark:bg-gray-800',
                            ]"
                            @click="selectCategory(cat)"
                        >
                            {{ cat }}
                        </p>
                    </div>
                </div>

                <Loading
                    class="mt-8"
                    v-if="!animes[selected]"
                    :text="`Fetching animes in ${selected}, please wait...`"
                />
                <div
                    class="
                        mt-4
                        grid grid-cols-1
                        md:grid-cols-2
                        gap-2
                        items-center
                    "
                    v-else
                >
                    <div
                        class="col-span-1"
                        v-for="anime in animes[selected]"
                        :key="anime.key"
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
                                    </div>
                                    <img
                                        class="w-14 rounded"
                                        :src="getHighResImage(anime.image)"
                                        :alt="anime.title"
                                    />
                                    <div class="flex-grow">
                                        <p class="text-lg font-bold">
                                            {{ anime.title }}
                                        </p>
                                    </div>
                                    <div>
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
            <p class="text-center opacity-75" v-else>
                Failed to load top animes!
            </p>
        </div>
    </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import api from "../plugins/api";
import util from "../plugins/util";

import PageTitle from "../components/PageTitle.vue";
import Loading from "../components/Loading.vue";

export default defineComponent({
    name: "Home",
    components: {
        PageTitle,
        Loading,
    },
    data() {
        const data: {
            hasLoaded: boolean;
            categories: string[];
            animes: Record<string, any[]>;
            selected: string;
        } = {
            hasLoaded: false,
            categories: [],
            animes: {},
            selected: "all",
        };

        return data;
    },
    async mounted() {
        api.rpc({
            details: "On Homepage",
        });
        await this.getCategories();
        await this.getTopAnimes(this.selected);
    },
    methods: {
        async getCategories() {
            this.categories = await api.anime.topTypes();
        },
        async getTopAnimes(type: string) {
            const { data, err } = await api.anime.top(type);
            if (err) {
                this.$logger.emit(
                    "error",
                    `Could not fetch anime's information: ${err}`
                );
            } else this.animes[type] = data;
            this.hasLoaded = true;
        },
        selectCategory(type: string) {
            this.selected = type;
            if (!this.animes[type]) this.getTopAnimes(type);
        },
        getHighResImage(url: string) {
            return util.getHighResMALImage(url);
        },
    },
});
</script>
