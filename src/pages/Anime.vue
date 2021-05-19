<template>
    <div>
        <Loading
            v-if="state === 'pending'"
            text="Loading anime, please wait..."
        />
        <p class="opacity-75 text-center" v-else-if="state === 'noresult'">
            No results could be fetched!
        </p>
        <div v-else-if="state === 'result' && info">
            <div class="flex flex-row justify-between gap-4">
                <div class="flex-grow text-center">
                    <PageTitle :title="info.title" />
                    <div
                        class="
                            flex flex-row
                            justify-center
                            items-center
                            mt-8
                            gap-10
                        "
                    >
                        <div>
                            <p class="opacity-75">Score</p>
                            <p class="text-3xl font-bold">
                                {{ info.stats.score || "-" }}
                            </p>
                        </div>
                        <div>
                            <p class="opacity-75">Rank</p>
                            <p class="text-3xl font-bold">
                                {{ info.stats.rank || "-" }}
                            </p>
                        </div>
                        <div>
                            <p class="opacity-75">Popularity</p>
                            <p class="text-3xl font-bold">
                                {{ info.stats.popularity || "-" }}
                            </p>
                        </div>
                    </div>
                </div>
                <div>
                    <img
                        class="rounded"
                        :src="info.image"
                        :alt="info.title"
                        style="width: 14rem"
                    />
                </div>
            </div>

            <div class="mt-8">
                <p class="text-sm opacity-75">About</p>
                <p>{{ info.synopsis || "-" }}</p>

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
                                    gap-3
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
                                    <p class="mt-1 opacity-75 text-xs">
                                        {{ character.role }}
                                    </p>
                                    <p>
                                        <ExternalLink
                                            class="text-xs"
                                            text="View on MAL"
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
                                    gap-3
                                    text-right
                                "
                            >
                                <div v-if="character.actor">
                                    <p class="leading-tight">
                                        {{ character.actor.name }}
                                    </p>
                                    <p class="mt-1 opacity-75 text-xs">
                                        {{ character.actor.language }}
                                    </p>
                                    <p>
                                        <ExternalLink
                                            class="text-xs"
                                            text="View on MAL"
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

                <p class="text-sm opacity-75 mt-4">Sources (Anime)</p>
                <div class="mt-1 grid gap-2">
                    <div v-for="plugin in extractors.anime" :key="plugin">
                        <AnimeSourceViewer
                            :title="info.title"
                            :pluginKey="plugin"
                            :pluginName="plugin"
                        />
                    </div>
                </div>

                <p class="text-sm opacity-75 mt-4">Sources (Manga)</p>
                <div class="mt-1 grid gap-2">
                    <div v-for="plugin in extractors.manga" :key="plugin">
                        <MangaSourceViewer
                            :title="info.title"
                            :pluginKey="plugin"
                            :pluginName="plugin"
                        />
                    </div>
                </div>

                <p class="text-sm opacity-75 mt-4">Similar</p>
                <div class="mt-1 grid grid-cols-1 md:grid-cols-2 gap-2">
                    <div
                        class="col-span-1"
                        v-for="anime in info.recommendations"
                        :key="anime.url"
                    >
                        <div
                            class="
                                flex flex-row
                                justify-start
                                items-center
                                bg-gray-100
                                dark:bg-gray-800
                                rounded
                                p-2
                                gap-4
                            "
                        >
                            <img
                                class="w-16 rounded"
                                :src="anime.thumbnail"
                                :alt="anime.title"
                            />
                            <div>
                                <p class="text-lg font-bold">
                                    {{ anime.title }}
                                </p>
                                <ExternalLink
                                    class="text-xs"
                                    text="View on MyAnimeList"
                                    :url="anime.url"
                                />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import api from "../plugins/api";

import PageTitle from "../components/PageTitle.vue";
import ExternalLink from "../components/ExternalLink.vue";
import AnimeSourceViewer from "../components/AnimeSourceViewer.vue";
import MangaSourceViewer from "../components/MangaSourceViewer.vue";
import Loading from "../components/Loading.vue";

export default defineComponent({
    name: "Home",
    components: {
        PageTitle,
        ExternalLink,
        AnimeSourceViewer,
        MangaSourceViewer,
        Loading,
    },
    data() {
        const data: {
            state: "pending" | "result" | "noresult";
            info: any;
            extractors: {
                anime: string[];
                manga: string[];
            };
        } = {
            state: "pending",
            info: null,
            extractors: {
                anime: [],
                manga: [],
            },
        };

        return data;
    },
    mounted() {
        this.getAnimeInfo();
        this.getSources();
    },
    methods: {
        async getAnimeInfo() {
            const url = this.$route.query.url;
            if (!url) {
                this.state = "noresult";
                return this.$logger.emit("error", "Missing 'url' in query!");
            }

            const { data, err } = await api.anime.info(url);
            if (err) {
                this.state = "noresult";
                return this.$logger.emit(
                    "error",
                    `Failed to fetch anime information: ${err}`
                );
            }

            this.info = data;
            this.state = "result";
        },
        async getSources() {
            this.extractors.anime = await api.anime.extractors.all();
            this.extractors.manga = await api.manga.extractors.all();
        },
    },
});
</script>
