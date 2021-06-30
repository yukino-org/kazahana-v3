<template>
    <div>
        <PageTitle title="History" />

        <div>
            <div
                class="
                    mt-6
                    flex flex-row
                    justify-between
                    items-center
                    flex-wrap
                    gap-4
                "
            >
                <p class="text-xl text-indigo-500 font-bold">
                    Recently Browsed
                </p>

                <div
                    class="
                        flex flex-row
                        justify-center
                        items-center
                        flex-wrap
                        gap-4
                    "
                >
                    <button
                        :class="[
                            'opacity-75 hover:opacity-100 transition duration-300 focus:outline-none',
                            filterRecentlyBrowsed && 'text-green-400'
                        ]"
                        @click.stop.prevent="
                            !!void toggleFilterRecentlyBrowsed()
                        "
                        title="Filter duplicate items"
                    >
                        <Icon icon="filter" />
                    </button>

                    <button
                        class="
                            opacity-75
                            hover:opacity-100
                            transition
                            duration-300
                            focus:outline-none
                        "
                        @click.stop.prevent="clearRecentlyBrowsed()"
                        title="Delete all recently browsed"
                    >
                        <Icon icon="trash" />
                    </button>
                </div>
            </div>

            <div>
                <p
                    class="mt-6 text-center opacity-75"
                    v-if="!recentlyBrowsed.length"
                >
                    No browse history was found.
                </p>
                <Swiper
                    :key="+filterRecentlyBrowsed"
                    :slides-per-view="1"
                    :space-between="4"
                    :breakpoints="{
                        550: {
                            slidesPerView: 2
                        },
                        640: {
                            slidesPerView: 3
                        },
                        900: {
                            slidesPerView: 4
                        },
                        1024: {
                            slidesPerView: 6
                        }
                    }"
                    :pagination="{
                        clickable: true
                    }"
                    v-else
                >
                    <SwiperSlide
                        class="mb-8"
                        v-for="(item, i) in getFilteredItems(
                            recentlyBrowsed.sort(
                                (a, b) => b.searchedAt - a.searchedAt
                            ),
                            'terms',
                            filterRecentlyBrowsed
                        )"
                    >
                        <router-link
                            :to="{
                                path: item.route.route,
                                query: {
                                    ...item.route.queries,
                                    autoSearch: '1'
                                }
                            }"
                        >
                            <div
                                class="
                                bg-gray-100
                                dark:bg-gray-800
                                rounded
                                px-4
                                py-2.5
                                hover-pop
                                max-w-52
                                my-2
                            "
                            >
                                <p>
                                    <span class="opacity-75 mr-1"
                                        >{{ i + 1 }}.</span
                                    >
                                    <b>{{ item.terms }}</b>
                                </p>

                                <p class="mt-0.5 text-xs">
                                    <span class="opacity-75 mr-1"
                                        >No. of results:</span
                                    >
                                    <b>{{ item.resultsFound }}</b>
                                </p>

                                <div
                                    class="mt-1"
                                    v-if="
                                        Array.isArray(
                                            item.route.queries.plugins
                                        ) && item.route.queries.plugins.length
                                    "
                                >
                                    <p class="text-xs opacity-75">
                                        Searched Plugins
                                    </p>
                                    <p class="text-sm">
                                        <b>{{
                                            item.route.queries.plugins.join(
                                                ", "
                                            )
                                        }}</b>
                                    </p>
                                </div>

                                <div class="mt-1">
                                    <p class="text-xs opacity-75">
                                        Searched on
                                    </p>
                                    <p class="text-sm">
                                        <b>{{
                                            new Date(
                                                item.searchedAt
                                            ).toLocaleString()
                                        }}</b>
                                    </p>
                                </div>
                            </div>
                        </router-link>
                    </SwiperSlide>
                </Swiper>
            </div>

            <div
                class="
                    mt-8
                    flex flex-row
                    justify-between
                    items-center
                    flex-wrap
                    gap-4
                "
            >
                <p class="text-xl text-indigo-500 font-bold">Recently Viewed</p>

                <div
                    class="
                        flex flex-row
                        justify-center
                        items-center
                        flex-wrap
                        gap-4
                    "
                >
                    <button
                        :class="[
                            'opacity-75 hover:opacity-100 transition duration-300 focus:outline-none',
                            filterRecentlyViewed && 'text-green-400'
                        ]"
                        @click.stop.prevent="
                            !!void toggleFilterRecentlyViewed()
                        "
                        title="Filter duplicate items"
                    >
                        <Icon icon="filter" />
                    </button>

                    <button
                        class="
                            opacity-75
                            hover:opacity-100
                            transition
                            duration-300
                            focus:outline-none
                        "
                        @click.stop.prevent="clearRecentlyViewed()"
                        title="Delete all recently viewed"
                    >
                        <Icon icon="trash" />
                    </button>
                </div>
            </div>

            <div>
                <p
                    class="mt-6 text-center opacity-75"
                    v-if="!recentlyViewed.length"
                >
                    No recently viewed history was found.
                </p>
                <div
                    class="mt-2 grid grid-cols-1 lg:grid-cols-2 gap-2"
                    :key="+filterRecentlyViewed"
                    v-else
                >
                    <router-link
                        class="col-span-1"
                        v-for="(item, i) in getFilteredItems(
                            recentlyViewed.sort(
                                (a, b) => b.viewedAt - a.viewedAt
                            ),
                            'title',
                            filterRecentlyViewed
                        )"
                        :to="{
                            path: item.route.route,
                            query: {
                                ...item.route.queries
                            }
                        }"
                    >
                        <div
                            class="
                                bg-gray-100
                                dark:bg-gray-800
                                rounded
                                p-3
                                hover-pop
                                flex flex-row
                                justify-center
                                items-center
                                gap-4
                            "
                        >
                            <div class="flex-none">
                                <img
                                    class="w-20 rounded"
                                    :src="item.image || placeHolderImage"
                                    :alt="item.title"
                                />
                            </div>

                            <div class="flex-grow">
                                <p>
                                    <span class="opacity-75 mr-1"
                                        >{{ i + 1 }}.</span
                                    >
                                    <b>{{ item.title }}</b>
                                </p>

                                <div class="mt-1">
                                    <p class="text-xs opacity-75">Plugin</p>
                                    <p class="text-sm">
                                        <b>{{ item.plugin }}</b>
                                    </p>
                                </div>

                                <div class="mt-1">
                                    <p class="text-xs opacity-75">Viewed on</p>
                                    <p class="text-sm">
                                        <b>{{
                                            new Date(
                                                item.viewedAt
                                            ).toLocaleString()
                                        }}</b>
                                    </p>
                                </div>
                            </div>
                        </div>
                    </router-link>
                </div>
            </div>
        </div>
    </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import SwiperCore, { Pagination } from "swiper";
import { Swiper, SwiperSlide } from "swiper/vue";
import { Rpc, Store } from "../plugins/api";
import { constants, util } from "../plugins/util";
import { StoreKeys, StoreStructure } from "../plugins/types";

import PageTitle from "../components/PageTitle.vue";
import Loading from "../components/Loading.vue";

SwiperCore.use([Pagination]);

export default defineComponent({
    name: "History",
    components: {
        PageTitle,
        Loading,
        Swiper,
        SwiperSlide
    },
    data() {
        const data: {
            placeHolderImage: string;
            recentlyBrowsed: StoreStructure[StoreKeys.recentlyBrowsed];
            filterRecentlyBrowsed: boolean;
            recentlyViewed: StoreStructure[StoreKeys.recentlyViewed];
            filterRecentlyViewed: boolean;
        } = {
            placeHolderImage:
                constants.assets.images[
                    util.isDarkTheme() ? "darkPlaceholder" : "lightPlaceholder"
                ],
            recentlyBrowsed: [],
            filterRecentlyBrowsed: false,
            recentlyViewed: [],
            filterRecentlyViewed: false
        };

        return data;
    },
    mounted() {
        this.setRpc();
        this.getRecentlyBrowsed();
        this.getRecentlyViewed();
    },
    methods: {
        async getRecentlyBrowsed() {
            const store = await Store.getClient();
            this.recentlyBrowsed =
                (await store.get(StoreKeys.recentlyBrowsed)) || [];
        },
        async clearRecentlyBrowsed() {
            const store = await Store.getClient();
            await store.set(StoreKeys.recentlyBrowsed, []);
            this.recentlyBrowsed = [];
        },
        toggleFilterRecentlyBrowsed() {
            this.filterRecentlyBrowsed = !this.filterRecentlyBrowsed;
        },
        async getRecentlyViewed() {
            const store = await Store.getClient();
            this.recentlyViewed =
                (await store.get(StoreKeys.recentlyViewed)) || [];
        },
        async clearRecentlyViewed() {
            const store = await Store.getClient();
            await store.set(StoreKeys.recentlyViewed, []);
            this.recentlyViewed = [];
        },
        toggleFilterRecentlyViewed() {
            this.filterRecentlyViewed = !this.filterRecentlyViewed;
        },
        getFilteredItems<T>(items: T[], key: keyof T, filter: boolean) {
            if (!filter) return items;

            const newItems: Record<string, T> = {};
            items.forEach(x => {
                const val = (x[key] as any) as string;
                if (!newItems[val]) {
                    newItems[val] = x;
                }
            });
            return Object.values(newItems);
        },
        async setRpc() {
            const rpc = await Rpc.getClient();
            rpc?.({
                details: "Viewing their history"
            });
        }
    }
});
</script>
