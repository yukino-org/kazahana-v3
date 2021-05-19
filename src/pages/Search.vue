<template>
    <div>
        <PageTitle title="Search" />
        <div class="mt-6 flex flex-row justify-center items-center">
            <input
                class="flex-grow text-box mr-1"
                v-model="terms"
                type="text"
                placeholder="Type in anime's name..."
                @keypress.enter="search()"
            />
            <button type="submit" class="btn" @click.prevent="search()">
                Search
            </button>
        </div>

        <p class="text-center mt-4 opacity-75" v-if="state === 'search'">
            Enter something to search for!
        </p>
        <Loading
            class="mt-8"
            v-else-if="state === 'loading'"
            :text="`Fetching results for ${terms}...`"
        />
        <p
            class="text-center mt-4 opacity-75"
            v-else-if="state === 'noresults'"
        >
            No results were found.
        </p>

        <div class="mt-8" v-if="result && result.length">
            <div class="grid grid-cols-1 lg:grid-cols-2 gap-4">
                <div
                    class="col-span-1"
                    v-for="anime in result"
                    :key="anime.url"
                >
                    <router-link
                        :to="{
                            path: '/anime',
                            query: {
                                url: anime.url,
                            },
                        }"
                        class="
                            hover-pop
                            flex flex-row
                            justify-center
                            items-center
                            gap-4
                            bg-gray-100
                            dark:bg-gray-800
                            rounded
                            p-4
                            cursor-pointer
                        "
                    >
                        <img
                            class="rounded"
                            :src="getHighResImage(anime.thumbnail)"
                            :alt="anime.title"
                            style="width: 8rem"
                        />
                        <div>
                            <p class="text-lg font-bold">{{ anime.title }}</p>
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
                            <p class="mt-2 text-sm opacity-75 leading-tight">
                                {{ replaceReadMore(anime.description) }}
                                <ExternalLink
                                    text="read more at MyAnimeList"
                                    :url="anime.url"
                                />
                            </p>
                        </div>
                    </router-link>
                </div>
            </div>
        </div>
    </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import api from "../plugins/api";

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
            result: any[];
        } = {
            state: "search",
            terms: "",
            result: [],
        };

        return data;
    },
    methods: {
        async search() {
            if (!this.terms)
                return this.$logger.emit(
                    "warn",
                    "Provide some search terms to search!"
                );

            if (this.terms.length < 3)
                return this.$logger.emit(
                    "warn",
                    "Enter atleast 3 characters to search!"
                );

            this.result = [];
            this.state = "loading";

            const { data, err } = await api.anime.search(this.terms);
            if (err)
                return this.$logger.emit(
                    "error",
                    `Could not get search results: ${err}`
                );

            if (!data?.length) {
                this.state = "noresults";
            } else {
                this.result = data;
                this.state = "results";
            }
        },
        getHighResImage(url: string) {
            return url.replace(
                /(https:\/\/cdn.myanimelist\.net\/).*(images.*)\?.*/g,
                "$1$2"
            );
        },
        replaceReadMore(desc: string) {
            return desc.replace(/(read more\.)$/, "");
        },
    },
});
</script>
