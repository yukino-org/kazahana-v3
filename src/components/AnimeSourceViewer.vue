<template>
    <div>
        <div class="bg-gray-100 dark:bg-gray-800 px-3 py-2 rounded">
            <p class="cursor-pointer text-xl font-bold" @click="toggle()">
                <Icon class="opacity-75 mr-1" icon="caret-down" v-if="isOpen" />
                <Icon class="opacity-75 mr-1" icon="caret-right" v-else />
                {{ pluginName }}
            </p>

            <div v-if="isOpen">
                <Loading
                    class="mb-1"
                    text="Fetching sources, please wait..."
                    v-if="!sources"
                />
                <div
                    class="text-sm text-center opacity-75 my-2"
                    v-else-if="!sources.length"
                >
                    <p>No sources could be found.</p>
                </div>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-2 mt-2" v-else>
                    <div
                        class="col-span-1"
                        v-for="src in sources"
                        :key="src.url"
                    >
                        <router-link
                            :to="{
                                path: '/anime/source',
                                query: {
                                    plugin: pluginKey,
                                    url: src.url,
                                },
                            }"
                        >
                            <div
                                class="
                                    hover-pop
                                    flex flex-row
                                    justify-center
                                    items-center
                                    rounded
                                    p-2
                                    gap-4
                                    border-2 border-gray-200
                                    dark:border-gray-700
                                "
                            >
                                <img
                                    class="w-20 rounded"
                                    :src="src.thumbnail"
                                    :alt="src.title"
                                />
                                <div class="flex-grow">
                                    <p class="text-lg font-bold">
                                        {{ src.title }}
                                    </p>
                                    <p
                                        class="opacity-75 text-xs"
                                        v-if="src.air"
                                    >
                                        {{ src.air }}
                                    </p>
                                    <ExternalLink
                                        class="text-xs"
                                        :text="`View on ${pluginName}`"
                                        :url="src.url"
                                    />
                                </div>
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
import api from "../plugins/api";

import Loading from "./Loading.vue";
import ExternalLink from "./ExternalLink.vue";

export default defineComponent({
    components: {
        Loading,
        ExternalLink,
    },
    props: {
        title: String,
        pluginKey: String,
        pluginName: String,
    },
    data() {
        const data: {
            isOpen: boolean;
            sources: any[] | null;
        } = {
            isOpen: false,
            sources: null,
        };

        return data;
    },
    methods: {
        toggle() {
            this.isOpen = !this.isOpen;
            if (this.isOpen && !this.sources) this.getSources();
        },
        async getSources() {
            if (!this.title || !this.pluginKey || this.sources) return;

            const { data, err } = await api.anime.extractors.search(
                this.pluginKey,
                this.title
            );
            if (err)
                return this.$logger.emit(
                    "error",
                    `Could not get search results: ${err}`
                );

            this.sources = data;
        },
    },
});
</script>
