<template>
    <div>
        <Loading
            v-if="state === 'pending' || state === 'loading'"
            text="Fetching pages, please wait..."
        />
        <div v-else-if="state === 'result' && info">
            <p class="text-sm opacity-75 mt-4">
                Viewing Vol. {{ volume }} Chap. {{ chapter }}
            </p>

            <div
                class="mb-4"
                v-if="currentPage && Object.keys(currentPage).length"
            >
                <div class="flex flex-row justify-between items-center">
                    <p class="text-xl font-bold mt-1">
                        Page {{ currentPage.page }}
                    </p>

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
                            v-for="page in info"
                            :key="page.page"
                            :value="page"
                        >
                            Page {{ page.page }}
                        </option>
                    </select>
                </div>

                <img
                    class="mt-2 w-full"
                    :src="currentPage.image"
                    :alt="`Page ${currentPage.page}`"
                    id="page-img"
                />
                <p class="mt-2">
                    Image URL:
                    <span class="bg-gray-100 dark:bg-gray-800 rounded px-1">{{
                        currentPage.image
                    }}</span>
                </p>
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
                    <option v-for="page in info" :key="page.page" :value="page">
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
            currentPage: any;
        } = {
            state: "pending",
            info: null,
            currentPage: undefined,
        };

        return data;
    },
    mounted() {
        this.getInfo();
        this.watchChapter();
    },
    methods: {
        refreshInfo() {
            this.info = null;
            this.getInfo();
        },
        watchChapter() {
            watch(() => this.volume, (cur, prev) => {
                if (cur !== prev) {
                    this.refreshInfo();
                }
            });

            watch(() => this.chapter, (cur, prev) => {
                if (cur !== prev) {
                    this.refreshInfo();
                }
            });
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
        },
        getHostFromUrl(url: string) {
            return url.match(/https?:\/\/(.*?)\//)?.[1] || url;
        },
        selectPlayUrl(page: any) {
            this.currentPage = page;
        },
        prevPage() {
            if (this.currentPage && typeof this.currentPage.page === "number") {
                const prev = this.info?.find(
                    (x: any) => x.page === this.currentPage.page - 1
                );
                if (prev) this.currentPage = prev;
            } else {
                this.currentPage = this.info.sort(
                    (a: any, b: any) => b.page - a.page
                )[0];
            }
            this.scrollToImage();
        },
        nextPage() {
            if (this.currentPage && typeof this.currentPage.page === "number") {
                const next = this.info?.find(
                    (x: any) => x.page === this.currentPage.page + 1
                );
                if (next) this.currentPage = next;
            } else {
                this.currentPage = this.info.sort(
                    (a: any, b: any) => a.page - b.page
                )[0];
            }
            this.scrollToImage();
        },
        scrollToImage() {
            const ele = document.getElementById("page-img");
            if (ele) {
                window.scrollTo({
                    top: ele.offsetTop,
                    behavior: "smooth",
                });
            }
        },
    },
});
</script>
