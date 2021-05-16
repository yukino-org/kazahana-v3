<template>
    <div>
        <div v-if="info">
            <div class="flex flex-row justify-between gap-4">
                <div>
                    <PageTitle class="flex-grow" :title="info.title" />
                    <div
                        class="
                            flex flex-row
                            justify-center
                            items-center
                            text-center
                            mt-8
                            gap-10
                        "
                    >
                        <div>
                            <p>Score</p>
                            <p class="text-3xl font-bold">
                                {{ info.stats.score || "-" }}
                            </p>
                        </div>
                        <div>
                            <p>Rank</p>
                            <p class="text-3xl font-bold">
                                {{ info.stats.rank || "-" }}
                            </p>
                        </div>
                        <div>
                            <p>Popularity</p>
                            <p class="text-3xl font-bold">
                                {{ info.stats.popularity || "-" }}
                            </p>
                        </div>
                    </div>
                </div>
                <div>
                    <!-- // todo -->
                    <img
                        class="rounded"
                        src="https://cdn.myanimelist.net/images/anime/1301/93586.jpg"
                        :alt="info.title"
                        style="width: 16rem"
                    />
                </div>
            </div>
            <div class="mt-8">
                <p class="text-sm opacity-75">About</p>
                <p>{{ info.synonpsis || "-" }}</p>

                <p class="text-sm opacity-75 mt-4">Information</p>
                <p><b>Type:</b> {{ info.info.type || "-" }}</p>
                <p><b>Status:</b> {{ info.info.status || "-" }}</p>
                <p><b>Season:</b> {{ info.season || "-" }}</p>
                <p><b>Premiered:</b> {{ info.info.premiered || "-" }}</p>
                <p><b>Episodes:</b> {{ info.info.episodes || "-" }}</p>
                <p><b>Aired:</b> {{ info.info.aired || "-" }}</p>
                <p><b>Genres:</b> {{ info.info.genres || "-" }}</p>
                <p><b>Duration:</b> {{ info.info.duration || "-" }}</p>
                <p><b>Rating:</b> {{ info.info.rating || "-" }}</p>

                <p class="text-sm opacity-75 mt-4">Characters</p>
                <div class="mt-1 grid grid-cols-1 md:grid-cols-2 gap-2">
                    <div
                        class="col-span-1"
                        v-for="character in info.characters"
                        :key="character.url"
                    >
                        <div
                            class="
                                p-2
                                flex flex-row
                                justify-between
                                items-center
                                gap-4
                                rounded
                                bg-gray-100
                                dark:bg-gray-800
                            "
                        >
                            <div
                                class="
                                    flex flex-row
                                    justify-between
                                    items-center
                                    gap-2
                                "
                            >
                                <img
                                    class="rounded"
                                    :src="character.image"
                                    :alt="character.name"
                                    style="width: 3rem"
                                />
                                <div>
                                    <p class="leading-tight">
                                        {{ character.name }}
                                    </p>
                                    <p class="opacity-75 text-xs">
                                        {{ character.role }}
                                    </p>
                                    <p class="leading-none">
                                        <ExternalLink
                                            class="text-xs"
                                            text="View"
                                            :url="character.url"
                                        />
                                    </p>
                                </div>
                            </div>
                            <div
                                class="
                                    flex flex-row
                                    justify-between
                                    items-center
                                    gap-2
                                    text-right
                                "
                            >
                                <div v-if="character.actor">
                                    <p class="leading-tight">
                                        {{ character.actor.name }}
                                    </p>
                                    <p class="opacity-75 text-xs">
                                        {{ character.actor.language }}
                                    </p>
                                    <p class="leading-none">
                                        <ExternalLink
                                            class="text-xs"
                                            text="View"
                                            :url="character.actor.url"
                                        />
                                    </p>
                                </div>
                                <img
                                    class="rounded"
                                    :src="character.actor.image"
                                    :alt="character.actor.name"
                                    style="width: 3rem"
                                />
                            </div>
                        </div>
                    </div>
                </div>

                <p class="text-sm opacity-75 mt-4">Similar</p>
                <div class="mt-1 grid grid-cols-1 md:grid-cols-2 gap-2">
                    <div
                        class="col-span-1"
                        v-for="anime in info.recommendations"
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
                                justify-start
                                items-center
                                bg-gray-100
                                dark:bg-gray-800
                                rounded
                                p-2
                                gap-4
                                cursor-pointer
                            "
                        >
                            <img
                                class="w-16 rounded"
                                :src="anime.thumbnail"
                                :alt="anime.title"
                            />
                            <div>
                                <p class="text-xl font-bold">
                                    {{ anime.title }}
                                </p>
                                <ExternalLink
                                    class="text-xs"
                                    text="MyAnimeList"
                                    :url="anime.url"
                                />
                            </div>
                        </router-link>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";

import PageTitle from "../components/PageTitle.vue";
import ExternalLink from "../components/ExternalLink.vue";

export default defineComponent({
    name: "Home",
    components: {
        PageTitle,
        ExternalLink,
    },
    data() {
        const data: {
            info: any;
        } = {
            info: null,
        };

        return data;
    },
    mounted() {
        this.getAnimeInfo();
    },
    methods: {
        async getAnimeInfo() {
            const url = this.$route.query.url;
            if (!url) return; // todo

            const { data, err } = await window.api.animeExt.getAnimeInfo(url);
            if (err) return console.log(err); // todo

            this.info = data;
        },
    },
});
</script>
