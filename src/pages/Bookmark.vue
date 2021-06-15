<template>
    <div>
        <PageTitle title="Bookmarks" />

        <div>
            <div
                class="
                    mt-4
                    w-full
                    flex flex-row
                    justify-center
                    items-center
                    text-center
                    rounded
                    overflow-hidden
                "
            >
                <div class="flex-grow" v-for="page in pages">
                    <div
                        :class="[
                            'capitalize',
                            'border-b-2',
                            'leading-loose',
                            'cursor-pointer',
                            'hover:bg-gray-100',
                            'dark:hover:bg-gray-800',
                            'transition',
                            'duration-300',
                            selected === page
                                ? 'border-indigo-500 text-indigo-500 border-opacity-100'
                                : 'border-gray-800 dark:border-gray-100 border-opacity-20 dark:border-opacity-20',
                        ]"
                        @click="changeSelected(page)"
                    >
                        {{ page }}
                    </div>
                </div>
            </div>

            <div>
                <p class="mt-6 text-center opacity-75" v-if="!items.length">
                    No
                    {{ selected === "bookmarked" ? "bookmarks" : "favorites" }}
                    were found.
                </p>
                <div class="mt-6 grid grid-cols-1 md:grid-cols-2 gap-2" v-else>
                    <router-link
                        v-for="(item, i) in items"
                        :to="{
                            path: item.route.route,
                            query: {
                                ...item.route.queries,
                            },
                        }"
                    >
                        <div
                            class="
                                col-span-1
                                bg-gray-100
                                dark:bg-gray-800
                                rounded
                                hover-pop
                                p-3
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
                                <p class="flex-grow">
                                    <span class="opacity-75 mr-1"
                                        >{{ i + 1 }}.</span
                                    >
                                    <b>{{ item.title }}</b>

                                    <span
                                        class="
                                            float-right
                                            mr-2
                                            opacity-75
                                            hover:opacity-100
                                            hover:text-red-500
                                            transition
                                            duration-200
                                        "
                                        @click.stop.prevent="
                                            !!void removeItem(i)
                                        "
                                    >
                                        <Icon icon="trash" />
                                    </span>
                                </p>

                                <div class="mt-1">
                                    <p class="text-xs opacity-75">Plugin</p>
                                    <p class="text-sm">
                                        <b>{{ item.plugin }}</b>
                                    </p>
                                </div>

                                <div class="mt-1">
                                    <p class="text-xs opacity-75">
                                        Bookmarked on
                                    </p>
                                    <p class="text-sm">
                                        <b>{{
                                            new Date(
                                                item.bookmarkedAt
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
import { Rpc, Store } from "../plugins/api";
import { constants, util } from "../plugins/util";
import { BookmarkedEntity } from "../plugins/types";

import PageTitle from "../components/PageTitle.vue";
import Loading from "../components/Loading.vue";

const tabs = ["bookmarked", "favorite"] as const;

export default defineComponent({
    name: "Bookmark",
    components: {
        PageTitle,
        Loading,
    },
    data() {
        const data: {
            placeHolderImage: string;
            items: BookmarkedEntity[];
            pages: typeof tabs;
            selected: typeof tabs[number];
        } = {
            placeHolderImage:
                constants.assets.images[
                    util.isDarkTheme() ? "darkPlaceholder" : "lightPlaceholder"
                ],
            items: [],
            pages: tabs,
            selected: tabs.includes(<any>this.$route.query.selected)
                ? <typeof tabs[number]>this.$route.query.selected
                : "bookmarked",
        };

        return data;
    },
    mounted() {
        this.setRpc();
        this.getSelected();
    },
    methods: {
        async getSelected() {
            const store = await Store.getClient();

            const allBookmarked: BookmarkedEntity[] =
                (await store.get(constants.storeKeys[this.selected])) || [];

            this.items = allBookmarked;
        },
        async removeItem(index: number) {
            const rmed = this.items.splice(index, 1);
            if (rmed.length) {
                const store = await Store.getClient();
                // perf: need a better way
                const unproxied = JSON.parse(JSON.stringify(this.items));
                await store.set(constants.storeKeys[this.selected], unproxied);
            }
        },
        changeSelected(type: typeof tabs[number]) {
            this.$router.push({
                query: {
                    selected: type,
                },
            });
            this.selected = type;
            this.items = [];
            this.getSelected();
        },
        async setRpc() {
            const rpc = await Rpc.getClient();
            rpc?.({
                details: "Viewing their bookmarks",
            });
        },
    },
});
</script>
