<template>
    <div>
        <Loading
            class="my-8"
            v-if="['waiting', 'resolving'].includes(info.state)"
            text="Fetching pages, please wait..."
        />
        <p class="text-center opacity-75" v-else-if="info.state === 'failed'">
            Failed to fetch results!
        </p>
        <p
            class="text-center opacity-75"
            v-else-if="info.state === 'resolved' && !info.data"
        >
            No results were found!
        </p>
        <div v-else-if="info.state === 'resolved' && info.data">
            <p class="text-sm opacity-75 mt-4">
                Viewing {{ chapTitle }} (Vol. {{ volume }} Chap. {{ chapter }})
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
                                    v-for="page in info.data.entities"
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
                    <div
                        :class="
                            fullscreen &&
                            `fixed ${
                                hasTitleBar ? 'top-8' : 'top-0'
                            } bottom-0 right-0 left-0 bg-black bg-opacity-[0.85] z-50`
                        "
                        @click.stop.prevent="!!void toggleFullscreen()"
                    >
                        <div
                            class="
                                relative
                                h-full
                                w-full
                                flex flex-row
                                justify-around
                                items-center
                            "
                        >
                            <button
                                class="
                                    focus:outline-none
                                    text-2xl
                                    md:text-5xl
                                    opacity-75
                                    hover:opacity-100
                                    transition
                                    duration-200
                                    absolute
                                    md:static
                                    left-0
                                    md:left-auto
                                    bg-gray-700 bg-opacity-50
                                    md:bg-transparent
                                    px-2
                                    py-1
                                    rounded-r
                                    z-[51]
                                "
                                v-if="fullscreen"
                                @click.stop.prevent="!!void prevPage()"
                            >
                                <Icon icon="chevron-left" />
                            </button>

                            <img
                                :class="
                                    fullscreen
                                        ? 'h-full md:h-[calc(100%-3rem)] w-auto'
                                        : 'w-full'
                                "
                                :src="getValidImageUrl(currentPageImage)"
                                :alt="`Page ${currentPage}`"
                                :title="`Page ${currentPage}`"
                                :style="{
                                    width: !fullscreen
                                        ? `${pageWidth}%`
                                        : undefined,
                                    cursor: fullscreen ? 'zoom-out' : 'zoom-in',
                                }"
                                :key="currentPageImage"
                                @click.stop.prevent="!!void toggleFullscreen()"
                                style="object-fit: contain"
                            />

                            <button
                                class="
                                    focus:outline-none
                                    text-2xl
                                    md:text-5xl
                                    opacity-75
                                    hover:opacity-100
                                    transition
                                    duration-200
                                    absolute
                                    md:static
                                    right-0
                                    md:right-auto
                                    bg-gray-700 bg-opacity-50
                                    md:bg-transparent
                                    px-2
                                    py-1
                                    rounded-l
                                    z-[51]
                                "
                                v-if="fullscreen"
                                @click.stop.prevent="!!void nextPage()"
                            >
                                <Icon icon="chevron-right" />
                            </button>
                        </div>
                    </div>
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
                    @click.stop.prevent="!!void prevPage()"
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
                    @click.stop.prevent="!!void nextPage()"
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
                            v-for="page in info.data.entities"
                            :value="page.page"
                        >
                            Page {{ page.page }}
                        </option>
                    </select>
                </div>
            </div>
        </div>
    </div>
</template>

<script lang="ts">
import { defineComponent, watch } from "vue";
import { Store, Extractors, ExtractorsEntity } from "../plugins/api";
import { Await, StateController, constants, util } from "../plugins/util";
import { LastLeftEntity } from "../plugins/types";

import Loading from "./Loading.vue";
import ExternalLink from "./ExternalLink.vue";

export default defineComponent({
    components: {
        Loading,
        ExternalLink,
    },
    props: {
        title: String,
        plugin: String,
        chapTitle: String,
        volume: String,
        chapter: String,
        link: String,
    },
    data() {
        const data: {
            info: StateController<
                Await<
                    ReturnType<ExtractorsEntity["manga"][""]["getChapterPages"]>
                >
            >;
            images:
                | {
                      page: string;
                      image: string;
                  }[]
                | null;
            currentPage: string | null;
            currentPageImage: string | null;
            pageWidth: number;
            hasTitleBar: boolean;
            fullscreen: boolean;
        } = {
            info: util.createStateController(),
            images: null,
            currentPage: null,
            currentPageImage: null,
            pageWidth: 100,
            hasTitleBar: ["electron"].includes(app_platform),
            fullscreen: false,
        };

        return data;
    },
    mounted() {
        this.updateWidth();
        this.getInfo();
        this.watchChapter();
        this.watchPage();
        this.attachKeys();
    },
    methods: {
        attachKeys() {
            document.addEventListener("keydown", (e) => {
                switch (e.key) {
                    case "ArrowLeft":
                        this.prevPage();
                        break;

                    case "ArrowRight":
                        this.nextPage();
                        break;

                    default:
                        break;
                }
            });
        },
        async updateWidth() {
            const store = await Store.getClient();
            let wid = (await store.get(constants.storeKeys.settings))
                ?.defaultPageWidth;
            if (wid && !isNaN(wid)) {
                wid = +wid;
                if (wid > 0 && wid <= 100) {
                    this.pageWidth = wid;
                }
            }
        },
        watchChapter() {
            watch(
                [() => this.volume, () => this.chapter, () => this.link],
                () => {
                    this.getInfo();
                }
            );
        },
        watchPage() {
            watch(
                () => this.currentPage,
                (cur) => {
                    if (cur) {
                        this.updatePageImage();
                    }
                }
            );
        },
        async getInfo() {
            if (!this.plugin) {
                this.info.state = "failed";
                return this.$logger.emit("error", "Invalid 'plugin' on query!");
            }
            if (!this.link) {
                this.info.state = "failed";
                return this.$logger.emit("error", "Invalid 'plugin' on query!");
            }

            try {
                this.info.state = "resolving";
                this.info.data = null;
                this.images = null;
                this.currentPage = null;
                this.currentPageImage = null;

                const client = await Extractors.getClient();
                const data = await client.manga[this.plugin].getChapterPages(
                    this.link
                );

                this.info.data = data;

                const page = this.$route.query.page;
                this.currentPage =
                    typeof page === "string"
                        ? page
                        : this.info.data.entities[0].page;

                this.info.state = "resolved";
            } catch (err) {
                this.info.state = "failed";
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

            const url = this.info.data?.entities.find(
                (x) => x.page === page
            )?.url;
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
        async updatePageImage() {
            if (!this.currentPage) return;

            this.scrollToImage();
            const img =
                this.info.data?.type === "page_urls"
                    ? await this.getPageImage(this.currentPage)
                    : this.info.data?.entities.find(
                          (x) => x.page === this.currentPage
                      )?.url;
            if (img) {
                this.currentPageImage = img;
                this.updateLastRead();
            }
        },
        prevPage() {
            if (this.info.data) {
                if (this.currentPage) {
                    const prevIndex =
                        this.info.data.entities.findIndex(
                            (x) => x.page === this.currentPage
                        ) - 1;

                    const prev = this.info.data.entities[prevIndex];
                    if (prev) this.currentPage = prev.page;
                } else {
                    this.currentPage = this.info.data.entities[0].page;
                }
            }
        },
        nextPage() {
            if (this.info.data) {
                if (this.currentPage) {
                    const nextIndex =
                        this.info.data.entities.findIndex(
                            (x) => x.page === this.currentPage
                        ) + 1;

                    const next = this.info.data.entities[nextIndex];
                    if (next) this.currentPage = next.page;
                } else {
                    this.currentPage = this.info.data.entities[0].page;
                }
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
        async updateLastRead() {
            const store = await Store.getClient();
            try {
                if (!this.$state.props.incognito) {
                    const extra: string[] = [];
                    if (this.volume) extra.push(`Vol. ${this.volume}`);
                    if (this.chapter) extra.push(`Chap. ${this.chapter}`);

                    await store.set(constants.storeKeys.lastWatchedLeft, <
                        LastLeftEntity
                    >{
                        title: `${this.title}${
                            extra.length ? ` (${extra.join(" ")})` : ""
                        }`,
                        reading: {
                            volume: this.volume,
                            chapter: this.chapter,
                            read: this.currentPage,
                            total: this.info.data?.entities.length.toString(),
                        },
                        updatedAt: Date.now(),
                        route: {
                            route: this.$route.path,
                            queries: { ...this.$route.query },
                        },
                        showPopup: true,
                    });
                }
            } catch (err) {
                this.$logger.emit(
                    "error",
                    `Failed to updated last watched: ${err?.message}`
                );
            }
        },
        toggleFullscreen() {
            this.fullscreen = !this.fullscreen;
        },
        getValidImageUrl: util.getValidImageUrl,
    },
});
</script>
