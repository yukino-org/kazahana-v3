<template>
    <div>
        <PageTitle title="Settings" />
        <div>
            <div
                class="
                    mt-6
                    flex flex-row
                    justify-between
                    items-center
                    flex-wrap
                "
            >
                <p class="text-xl text-indigo-500 font-bold">
                    Recently Browsed
                </p>
                <button
                    class="
                        opacity-75
                        hover:opacity-100
                        transition
                        duration-300
                        focus:outline-none
                    "
                    @click="clearRecentlyBrowsed()"
                >
                    <Icon icon="trash" />
                </button>
            </div>

            <div>
                <div
                    class="
                        flex flex-row
                        justify-start
                        items-center
                        gap-2
                        overflow-x-scroll
                    "
                    v-if="recentlyBrowsed.length"
                >
                    <router-link
                        v-for="(item, i) in recentlyBrowsed.sort(
                            (a, b) => b.searchedAt - a.searchedAt
                        )"
                        :to="{
                            path: item.route.route,
                            query: {
                                ...item.route.queries,
                                autoSearch: '1',
                            },
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
                                w-52
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
                                    Array.isArray(item.route.queries.plugins) &&
                                    item.route.queries.plugins.length
                                "
                            >
                                <p class="text-xs opacity-75">
                                    Searched Plugins
                                </p>
                                <p class="text-sm">
                                    <b>{{
                                        item.route.queries.plugins.join(", ")
                                    }}</b>
                                </p>
                            </div>

                            <div class="mt-1">
                                <p class="text-xs opacity-75">Searched on</p>
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
                </div>
                <p class="mt-2 text-center opacity-75" v-else>
                    No browse history was found.
                </p>
            </div>

            <div
                class="
                    mt-6
                    flex flex-row
                    justify-between
                    items-center
                    flex-wrap
                "
            >
                <p class="mt-8 text-xl text-indigo-500 font-bold">
                    Recently Viewed
                </p>
                <button
                    class="
                        opacity-75
                        hover:opacity-100
                        transition
                        duration-300
                        focus:outline-none
                    "
                    @click="clearRecentlyViewed()"
                >
                    <Icon icon="trash" />
                </button>
            </div>

            <div>
                <div
                    class="mt-2 grid grid-cols-1 lg:grid-cols-2 gap-2"
                    v-if="recentlyViewed.length"
                >
                    <router-link
                        class="col-span-1"
                        v-for="(item, i) in recentlyViewed.sort(
                            (a, b) => b.viewedAt - a.viewedAt
                        )"
                        :to="{
                            path: item.route.route,
                            query: {
                                ...item.route.queries,
                            },
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
                <p class="mt-2 text-center opacity-75" v-else>
                    No recently viewed history was found.
                </p>
            </div>
        </div>
    </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import { Rpc, Store } from "../plugins/api";
import { constants, util } from "../plugins/util";
import { RecentlyBrowsedEntity, RecentlyViewedEntity } from "../plugins/types";

import PageTitle from "../components/PageTitle.vue";
import Loading from "../components/Loading.vue";

export default defineComponent({
    name: "History",
    components: {
        PageTitle,
        Loading,
    },
    data() {
        const data: {
            placeHolderImage: string;
            recentlyBrowsed: RecentlyBrowsedEntity[];
            recentlyViewed: RecentlyViewedEntity[];
        } = {
            placeHolderImage:
                constants.assets.images[
                    util.isDarkTheme() ? "darkPlaceholder" : "lightPlaceholder"
                ],
            recentlyBrowsed: [],
            recentlyViewed: [],
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
                (await store.get(constants.storeKeys.recentlyBrowsed)) || [];
        },
        async clearRecentlyBrowsed() {
            const store = await Store.getClient();
            await store.set(constants.storeKeys.recentlyBrowsed, []);
            this.recentlyBrowsed = [];
        },
        async getRecentlyViewed() {
            const store = await Store.getClient();
            this.recentlyViewed =
                (await store.get(constants.storeKeys.recentlyViewed)) || [];
        },
        async clearRecentlyViewed() {
            const store = await Store.getClient();
            await store.set(constants.storeKeys.recentlyViewed, []);
            this.recentlyViewed = [];
        },
        async setRpc() {
            const rpc = await Rpc.getClient();
            rpc?.({
                details: "Viewing their history",
            });
        },
    },
});
</script>
