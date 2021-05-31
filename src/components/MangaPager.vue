<template>
    <div>
        <Loading
            class="my-8"
            v-if="state === 'pending' || state === 'loading'"
            text="Fetching pages, please wait..."
        />
        <div v-else-if="state === 'result' && info">
            <p class="text-sm opacity-75 mt-4">
                Viewing Vol. {{ volume }} Chap. {{ chapter }}
            </p>

            <div class="mb-4" v-if="currentPage">
                <div
                    class="
                        flex flex-col
                        md:flex-row
                        justify-between
                        items-center
                        gap-3
                        mt-3
                    "
                >
                    <p class="text-xl font-bold mt-1 hidden md:block">
                        Page {{ currentPage }}
                    </p>

                    <div
                        class="
                            flex flex-col
                            md:flex-row
                            justify-center
                            items-center
                            gap-2
                        "
                    >
                        <div
                            class="
                                flex flex-row
                                justify-center
                                items-center
                                order-last
                                md:order-none
                            "
                        >
                            <span class="mr-2 opacity-75">Page width:</span>
                            <div class="select w-40">
                                <select class="capitalize" v-model="pageWidth">
                                    <option
                                        v-for="wid in Array(10)
                                            .fill(null)
                                            .map((x, i) => i * 10 + 10)"
                                        :value="wid"
                                        :key="wid"
                                    >
                                        {{ wid }}%
                                    </option>
                                </select>
                            </div>
                        </div>

                        <div class="ml-3 select">
                            <select v-model="currentPage">
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
                </div>

                <Loading class="mt-4" v-if="!currentPageImage" />
                <div class="mt-4" v-else>
                    <img
                        class="w-full"
                        :src="currentPageImage"
                        :alt="`Page ${currentPage}`"
                        :style="{ width: `${pageWidth}%` }"
                    />
                    <p class="mt-4">
                        Image URL:
                        <span
                            class="
                                bg-gray-100
                                dark:bg-gray-800
                                rounded
                                px-1
                                break-all
                                select-all
                            "
                            >{{ currentPageImage }}</span
                        >
                    </p>
                </div>
            </div>

            <div
                class="
                    mt-2
                    flex flex-row
                    justify-center
                    items-center
                    gap-2
                    flex-wrap
                "
            >
                <button
                    class="
                        text-white
                        bg-indigo-500
                        hover:bg-indigo-600
                        transition
                        duration-200
                        px-3
                        py-2
                        rounded
                        focus:outline-none
                        order-last
                        md:order-none
                    "
                    @click.prevent="prevPage()"
                >
                    <Icon class="mr-1 opacity-75" icon="caret-left" /> Previous
                    Page
                </button>
                <button
                    class="
                        text-white
                        bg-indigo-500
                        hover:bg-indigo-600
                        transition
                        duration-200
                        px-3
                        py-2
                        rounded
                        focus:outline-none
                        order-last
                        md:order-none
                    "
                    @click.prevent="nextPage()"
                >
                    Next Page
                    <Icon class="ml-1 opacity-75" icon="caret-right" />
                </button>
                <div class="select">
                    <select v-model="currentPage">
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
        </div>
        <p class="text-center opacity-75" v-else-if="state === 'noresult'">
            No results were found!
        </p>
    </div>
</template>

<script lang="ts">
import { defineComponent, watch } from "vue";
import { Store, Extractors, ExtractorsEntity } from "../plugins/api";
import { Await, util } from "../plugins/util";

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
            info: Await<
                ReturnType<ExtractorsEntity["manga"][""]["getChapterPages"]>
            > | null;
            images:
                | {
                      page: string;
                      image: string;
                  }[]
                | null;
            currentPage: string | null;
            currentPageImage: string | null;
            pageWidth: number;
        } = {
            state: "pending",
            info: null,
            images: null,
            currentPage: null,
            currentPageImage: null,
            pageWidth: 100,
        };

        return data;
    },
    mounted() {
        this.updateWidth();
        this.getInfo();
        this.watchChapter();
    },
    methods: {
        async updateWidth() {
            const store = await Store.getClient();
            let wid = (await store.get("settings"))?.defaultPageWidth;
            if (wid && !isNaN(wid)) {
                wid = +wid;
                if (wid > 0 && wid <= 100) {
                    this.pageWidth = wid;
                }
            }
        },
        watchChapter() {
            watch(
                () => this.volume,
                (cur, prev) => {
                    if (cur !== prev) {
                        this.images = null;
                        this.currentPageImage = null;
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
                        this.currentPage = null;
                        this.currentPageImage = null;
                        if (cur) {
                            this.getInfo();
                        }
                    }
                }
            );
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

            try {
                this.info = null;
                this.images = null;
                this.state = "loading";
                const client = await Extractors.getClient();
                const data = await client.manga[this.plugin].getChapterPages(
                    this.link
                );

                this.state = "result";
                this.info = data;
                if (this.info.entities[0]) {
                    this.selectPageUrl(this.info.entities[0].page);
                }
            } catch (err) {
                this.$logger.emit(
                    "error",
                    `Could not fetch anime's information: ${err?.message}`
                );
            }
        },
        async getPageImage(page: string) {
            if (!this.plugin) {
                return this.$logger.emit("error", "Invalid 'plugin' on query!");
            }

            if (!this.images) this.images = [];

            const found = this.images.find((x) => x.page === page);
            if (found) return found.image;

            const url = this.info?.entities.find((x) => x.page === page)?.url;
            if (!url) {
                return this.$logger.emit(
                    "error",
                    "No URL was found for that page!"
                );
            }

            try {
                const client = await Extractors.getClient();
                const data = await client.manga[this.plugin].getPageImage?.(
                    url
                );
                if (data) {
                    this.images.push({
                        page,
                        image: data.image,
                    });
                    return data.image;
                }
            } catch (err) {
                this.$logger.emit(
                    "error",
                    `Could not fetch anime's information: ${err?.message}`
                );
            }
        },
        getHostFromUrl(url: string) {
            return url.match(/https?:\/\/(.*?)\//)?.[1] || url;
        },
        async selectPageUrl(page: string) {
            this.currentPage = page;
            this.scrollToImage();
            const img =
                this.info?.type === "page_urls"
                    ? await this.getPageImage(page)
                    : this.info?.entities.find((x) => x.page === page)?.url;
            if (img) this.currentPageImage = img;
        },
        prevPage() {
            if (this.currentPage && this.info) {
                const prevIndex =
                    this.info.entities.findIndex(
                        (x) => x.page === this.currentPage
                    ) - 1;

                const prev = this.info.entities[prevIndex];
                if (prev) this.currentPage = prev.page;
            } else if (this.info) {
                this.currentPage = this.info.entities[0].page;
            }
        },
        nextPage() {
            if (this.currentPage && this.info) {
                const nextIndex =
                    this.info.entities.findIndex(
                        (x) => x.page === this.currentPage
                    ) + 1;

                const next = this.info.entities[nextIndex];
                if (next) this.currentPage = next.page;
            } else if (this.info) {
                this.currentPage = this.info.entities[0].page;
            }
        },
        scrollToImage() {
            const ele = document.getElementById("main-container");
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
