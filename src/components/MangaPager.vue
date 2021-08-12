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
                            <select
                                class="
                                    bg-gray-100
                                    dark:bg-gray-800
                                    rounded
                                    py-1
                                    border-transparent
                                    focus:ring-0 focus:outline-none
                                    capitalize
                                "
                                v-model="pageWidth"
                            >
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

                        <select
                            class="
                                ml-3
                                bg-gray-100
                                dark:bg-gray-800
                                rounded
                                py-1
                                border-transparent
                                focus:ring-0 focus:outline-none
                                capitalize
                            "
                            v-model="currentPage"
                        >
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

                    <p class="mt-2" v-if="currentPageImage">
                        Image URL:
                        <span
                            class="
                                ml-2
                                bg-gray-100
                                dark:bg-gray-800
                                rounded
                                px-1
                                break-all
                                select-all
                                cursor-pointer
                            "
                            @click.stop.prevent="
                                !!void copyCurrentUrlToClipboard()
                            "
                            >{{ shrinkText(currentPageImage) }}</span
                        >
                        <span
                            :class="[
                                'ml-2 cursor-pointer opacity-75 hover:opacity-100 transition duration-200',
                                showCopied && 'opacity-100 text-green-500',
                            ]"
                            @click.stop.prevent="
                                !!void copyCurrentUrlToClipboard()
                            "
                        >
                            <transition name="fade" mode="out-in">
                                <Icon icon="check" v-if="showCopied" />
                                <Icon icon="clipboard" v-else />
                            </transition>
                        </span>
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

                <select
                    class="
                        bg-gray-100
                        dark:bg-gray-800
                        rounded
                        py-2
                        border-transparent
                        focus:ring-0 focus:outline-none
                        capitalize
                    "
                    v-model="currentPage"
                >
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
</template>

<script lang="ts">
import { defineComponent, watch } from "vue";
import { Store, Extractors, ExtractorsEntity } from "../plugins/api";
import { Await, StateController, util } from "../plugins/util";
import { StoreKeys } from "../plugins/types";

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
            currentPage: string;
            currentPageImage: string | null;
            pageWidth: number;
            hasTitleBar: boolean;
            fullscreen: boolean;
            showCopied: boolean;
        } = {
            info: util.createStateController(),
            images: null,
            currentPage: "",
            currentPageImage: null,
            pageWidth: 100,
            hasTitleBar: this.$state.props.runtime.isElectron,
            fullscreen: false,
            showCopied: false,
        };

        return data;
    },
    mounted() {
        this.updateWidth();
        this.getInfo();

        this.dispatchChapter(this.chapter ? +this.chapter : null);
        this.dispatchVolume(this.volume ? +this.volume : null);

        this.watchChapter();
        this.watchPage();
        this.attachKeys();
    },
    beforeDestroy() {
        this.dispatchChapter(null);
        this.dispatchVolume(null);
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
            let wid = (await store.get(StoreKeys.settings))?.defaultPageWidth;
            if (wid && wid > 0 && wid <= 100) {
                this.pageWidth = wid;
            }
        },
        watchChapter() {
            watch(
                [() => this.volume, () => this.chapter, () => this.link],
                () => {
                    this.getInfo();

                    this.dispatchChapter(this.chapter ? +this.chapter : null);
                    this.dispatchVolume(this.volume ? +this.volume : null);
                }
            );
        },
        watchPage() {
            watch(
                () => this.currentPage,
                (cur) => {
                    if (cur) {
                        this.updatePageImage();

                        if (this.info.data && this.chapter) {
                            const i = this.info.data.entities.findIndex(
                                (x) => x.page === this.currentPage
                            );

                            if (i === this.info.data.entities.length - 1) {
                                this.dispatchStatus();
                            }
                        }
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
                this.currentPage = "";
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
                delete this.$route.query.page;

                this.info.state = "resolved";
            } catch (err: any) {
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
                    url,
                    { ...this.info.data?.headers }
                );
                if (data) {
                    this.images.push({
                        page,
                        image: data.image,
                    });
                    return data.image;
                }
            } catch (err: any) {
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

                    await store.set(StoreKeys.lastWatchedLeft, {
                        title: `${this.title}${
                            extra.length ? ` (${extra.join(" ")})` : ""
                        }`,
                        reading: {
                            volume: this.volume || "-",
                            chapter: this.chapter || "-",
                            read: this.currentPage || "-",
                            total:
                                this.info.data?.entities.length.toString() ||
                                "-",
                        },
                        updatedAt: Date.now(),
                        route: {
                            route: this.$route.path,
                            queries: <any>{ ...this.$route.query },
                        },
                        showPopup: true,
                    });
                }
            } catch (err: any) {
                this.$logger.emit(
                    "error",
                    `Failed to updated last watched: ${err?.message}`
                );
            }
        },
        toggleFullscreen() {
            this.fullscreen = !this.fullscreen;
        },
        copyCurrentUrlToClipboard() {
            if (!this.currentPageImage) return;
            util.copyToClipboard(this.currentPageImage);
            this.showCopied = true;
            setTimeout(() => {
                this.showCopied = false;
            }, 5000);
        },
        dispatchChapter(chapter: number | null) {
            this.$bus.dispatch("set-MAL-manga-chapter", chapter);
            this.$bus.dispatch("set-AniList-manga-chapter", chapter);
        },
        dispatchVolume(volume: number | null) {
            this.$bus.dispatch("set-MAL-manga-volume", volume);
            this.$bus.dispatch("set-AniList-manga-volume", volume);
        },
        dispatchStatus() {
            if (!this.chapter) return;

            this.$bus.dispatch("update-MAL-manga-status", {
                chapter: +this.chapter,
                volume: this.volume ? +this.volume : undefined,
                status: "reading",
            });

            this.$bus.dispatch("update-AniList-manga-status", {
                chapter: +this.chapter,
                volume: this.volume ? +this.volume : undefined,
                status: "CURRENT",
            });
        },
        shrinkText: (txt: string) => util.shrinkedText(txt, 80),
        getValidImageUrl: util.getValidImageUrl,
    },
});
</script>
