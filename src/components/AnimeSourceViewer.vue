<template>
    <div>
        <div class="bg-gray-100 dark:bg-gray-800 px-3 py-2 rounded">
            <p
                class="cursor-pointer text-xl font-bold"
                @click.prevent="!!void toggle()"
            >
                <Icon class="opacity-75 mr-1" icon="caret-down" v-if="isOpen" />
                <Icon class="opacity-75 mr-1" icon="caret-right" v-else />
                {{ pluginName }}
            </p>

            <div v-if="isOpen">
                <Loading
                    class="my-4"
                    text="Fetching sources, please wait..."
                    v-if="['waiting', 'resolving'].includes(sources.state)"
                />
                <p
                    class="text-sm text-center opacity-75 my-2"
                    v-else-if="sources.state === 'failed'"
                >
                    Failed to fetch sources!
                </p>
                <p
                    class="text-sm text-center opacity-75 my-2"
                    v-else-if="
                        sources.state === 'resolved' && !sources.data?.length
                    "
                >
                    No sources were found.
                </p>
                <div
                    class="
                        grid grid-cols-1
                        md:grid-cols-2
                        gap-2
                        mt-2
                        items-center
                    "
                    v-else-if="sources.state === 'resolved' && sources.data"
                >
                    <div class="col-span-1" v-for="src in sources.data">
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
                                    class="w-16 md:w-20 rounded"
                                    :src="getValidImageUrl(src.thumbnail)"
                                    :alt="src.title"
                                    v-if="src.thumbnail"
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
import { Extractors, ExtractorsEntity } from "../plugins/api";
import { Await, StateController, util } from "../plugins/util";

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
            sources: StateController<
                Await<ReturnType<ExtractorsEntity["anime"][""]["search"]>>
            >;
        } = {
            isOpen: false,
            sources: util.createStateController(),
        };

        return data;
    },
    methods: {
        toggle() {
            this.isOpen = !this.isOpen;
            if (this.isOpen && !this.sources.data) this.getSources();
        },
        async getSources() {
            if (!this.title || !this.pluginKey || this.sources.data) return;

            try {
                this.sources.state = "resolving";
                const client = await Extractors.getClient();
                const data = await client.anime[this.pluginKey].search(
                    this.title
                );

                this.sources.data = data;
                this.sources.state = "resolved";
            } catch (err: any) {
                this.sources.state = "failed";
                this.$logger.emit(
                    "error",
                    `Could not get search results: ${err?.message}`
                );
            }
        },
        getValidImageUrl: util.getValidImageUrl,
    },
});
</script>
