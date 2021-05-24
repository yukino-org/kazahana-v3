<template>
    <div>
        <Loading
            class="mt-8"
            v-if="state === 'pending' || state === 'loading'"
            text="Fetching pages, please wait..."
        />
        <div v-else-if="state === 'result' && info">
            <p class="text-sm opacity-75 mt-4">
                Viewing Vol. {{ volume }} Chap. {{ chapter }}
            </p>

            <div class="mb-4" v-if="currentPage">
                <div class="flex flex-row justify-between items-center">
                    <p class="text-xl font-bold mt-1">Page {{ currentPage }}</p>

                    <select
                        class="
                            focus:outline-none
                            rounded
                            px-1.5
                            py-1
                            bg-gray-100
                            dark:bg-gray-800
                            cursor-pointer
                        "
                        v-model="currentPage"
                    >
                        <option disabled :value="undefined">
                            Please select a page
                        </option>
                        <option
                            v-for="page in info.entities"
                            :key="page.page"
                            :value="page.page"
                        >
                            Page {{ page.page }}
                        </option>
                    </select>
                </div>

                <Loading v-if="!getCurrentImage()" />
                <div v-else>
                    <img
                        class="mt-2 w-full"
                        :src="getCurrentImage()"
                        :alt="`Page ${currentPage}`"
                    />
                    <p class="mt-2">
                        Image URL:
                        <span
                            class="bg-gray-100 dark:bg-gray-800 rounded px-1"
                            >{{ getCurrentImage() }}</span
                        >
                    </p>
                </div>
            </div>

            <div class="mt-2 flex flex-row justify-center items-center gap-2">
                <button
                    class="
                        text-white
                        bg-indigo-500
                        hover:bg-indigo-600
                        transition
                        duration-200
                        px-2
                        py-1
                        rounded
                        focus:outline-none
                    "
                    @click="prevPage()"
                >
                    <Icon class="mr-1 opacity-75" icon="caret-left" /> Previous
                </button>
                <button
                    class="
                        text-white
                        bg-indigo-500
                        hover:bg-indigo-600
                        transition
                        duration-200
                        px-2
                        py-1
                        rounded
                        focus:outline-none
                    "
                    @click="nextPage()"
                >
                    Next <Icon class="ml-1 opacity-75" icon="caret-right" />
                </button>
                <select
                    class="
                        focus:outline-none
                        rounded
                        px-1.5
                        py-1
                        bg-gray-100
                        dark:bg-gray-800
                        cursor-pointer
                    "
                    v-model="currentPage"
                >
                    <option disabled :value="undefined">
                        Please select a page
                    </option>
                    <option
                        v-for="page in info.entities"
                        :key="page.page"
                        :value="page.page"
                    >
                        Page {{ page.page }}
                    </option>
                </select>
            </div>
        </div>
        <p class="text-center opacity-75" v-else-if="state === 'noresult'">
            No results were found!
        </p>
    </div>
</template>

<script lang="ts">
import { defineComponent, watch } from "vue";
import api from "../plugins/api";

import Loading from "./Loading.vue";
import ExternalLink from "./ExternalLink.vue";

export default defineComponent({
    components: {
        Loading,
        ExternalLink,
    },
    props: {
        plugin: String,
        volume: String,
        chapter: String,
        link: String,
    },
    data() {
        const data: {
            state: "pending" | "loading" | "noresult" | "result";
            info: any;
            images: any[] | null;
            currentPage: string | null;
        } = {
            state: "pending",
            info: null,
            images: null,
            currentPage: null,
        };

        return data;
    },
    mounted() {
        this.getInfo();
        this.watchChapter();
        this.watchPage();
    },
    methods: {
        watchChapter() {
            watch(
                () => this.volume,
                (cur, prev) => {
                    if (cur !== prev) {
                        this.images = null;
                        if (cur) {
                            this.getInfo();
                        }
                    }
                }
            );

            watch(
                () => this.chapter,
                (cur, prev) => {
                    if (cur !== prev) {
                        if (cur) {
                            this.getInfo();
                        }
                    }
                }
            );
        },
        watchPage() {
            watch(
                () => this.currentPage,
                (cur, prev) => {
                    if (cur !== prev) {
                        if (cur) {
                            if (this.info?.type === "page_urls")
                                this.getPageImage(cur);
                        }
                        this.scrollToImage();
                    }
                }
            );
        },
        getCurrentImage() {
            if (this.info?.type === "page_urls")
                return this.images?.find((x) => x.page === this.currentPage)
                    ?.image;

            return this.info?.entities.find(
                (x: any) => x.page === this.currentPage
            )?.url;
        },
        async getInfo() {
            if (!this.plugin) {
                this.state = "noresult";
                return this.$logger.emit("error", "Invalid 'plugin' on query!");
            }
            if (!this.link) {
                this.state = "noresult";
                return this.$logger.emit("error", "Invalid 'plugin' on query!");
            }

            this.info = null;
            this.state = "loading";
            const { data, err } = await api.manga.extractors.pages(
                this.plugin,
                this.link
            );
            if (err) {
                this.state = "noresult";
                return this.$logger.emit(
                    "error",
                    `Could not fetch anime's information: ${err}`
                );
            }

            this.state = "result";
            this.info = data;
            if (this.info.entities[0]) {
                this.selectPageUrl(this.info.entities[0].page);
                this.scrollToImage();
            }
        },
        async getPageImage(page: string) {
            if (!this.plugin) {
                return this.$logger.emit("error", "Invalid 'plugin' on query!");
            }

            if (!this.images) this.images = [];

            const found = this.images.find((x) => x.page === page);
            if (found) return;

            const url = this.info?.entities.find(
                (x: any) => x.page === page
            )?.url;
            if (!url) {
                return this.$logger.emit(
                    "error",
                    "No URL was found for that page!"
                );
            }

            const { data, err } = await api.manga.extractors.pageImage(
                this.plugin,
                url
            );
            if (err) {
                return this.$logger.emit(
                    "error",
                    `Could not fetch anime's information: ${err}`
                );
            }

            this.images.push({
                page,
                image: data.image,
            });
        },
        getHostFromUrl(url: string) {
            return url.match(/https?:\/\/(.*?)\//)?.[1] || url;
        },
        selectPageUrl(page: any) {
            this.currentPage = page;
        },
        prevPage() {
            if (this.currentPage && this.info) {
                const prevIndex =
                    this.info.entities.findIndex(
                        (x: any) => x.page === this.currentPage
                    ) - 1;

                const prev = this.info.entities[prevIndex];
                if (prev) this.currentPage = prev.page;
            } else {
                this.currentPage = this.info.entities[0].page;
            }
            this.scrollToImage();
        },
        nextPage() {
            if (this.currentPage) {
                const nextIndex =
                    this.info.entities.findIndex(
                        (x: any) => x.page === this.currentPage
                    ) + 1;

                const next = this.info.entities[nextIndex];
                if (next) this.currentPage = next.page;
            } else {
                this.currentPage = this.info.entities[0].page;
            }
            this.scrollToImage();
        },
        scrollToImage() {
            window.scrollTo({
                top: 100,
                behavior: "smooth",
            });
        },
    },
});
</script>
