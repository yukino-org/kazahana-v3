<template>
    <div>
        <PageTitle title="AniList Profile (Anime)" />

        <Loading
            class="mt-8"
            v-if="['waiting', 'resolving'].includes(userinfo.state)"
            text="Loading user information, please wait..."
        />
        <p
            class="mt-6 opacity-75 text-center"
            v-else-if="userinfo.state === 'failed'"
        >
            User information could not be fetched!
        </p>
        <p
            class="mt-6 opacity-75 text-center"
            v-else-if="userinfo.state === 'resolved' && !userinfo.data"
        >
            Failed to fetch user information!
        </p>
        <div class="mt-6" v-else-if="userinfo.data">
            <div
                class="
                    flex flex-row
                    justify-center
                    items-center
                    flex-wrap
                    gap-4
                "
            >
                <img
                    class="flex-none w-16 h-16 rounded-full"
                    :src="userinfo.data.avatar.medium"
                    :alt="userinfo.data.name"
                    v-if="userinfo.data.avatar.medium"
                />

                <div class="flex-grow">
                    <p class="text-xs opacity-75">Logged in as</p>
                    <p class="text-xl font-bold">
                        {{ userinfo.data.name }}
                        <span class="ml-1 text-xs opacity-75"
                            >({{ userinfo.data.id }})</span
                        >
                    </p>
                </div>
            </div>

            <div class="mt-6">
                <TabBar
                    :items="tabs"
                    :selected="selectedTab"
                    tabClassNames="capitalize"
                    @tabClick="handleTabChange"
                />
            </div>

            <div class="mt-4">
                <Loading
                    class="mt-8"
                    v-if="['waiting', 'resolving'].includes(items.state)"
                    text="Loading anime list, please wait..."
                />
                <p
                    class="mt-6 opacity-75 text-center"
                    v-else-if="items.state === 'failed'"
                >
                    Anime list could not be fetched!
                </p>
                <p
                    class="mt-6 opacity-75 text-center"
                    v-else-if="
                        items.state === 'resolved' && !items.data?.length
                    "
                >
                    Nothing was found here.
                </p>
                <div
                    class="grid grid-cols-1 md:grid-cols-2 gap-2"
                    v-else-if="items.state === 'resolved' && items.data?.length"
                >
                    <router-link
                        class="col-span-1"
                        :to="{
                            path: '/anime',
                            query: {
                                url: `${malBaseURL}/anime/${item.media.idMal}`,
                            },
                        }"
                        v-for="item in items.data"
                    >
                        <div
                            class="
                                flex flex-row
                                justify-center
                                items-center
                                gap-4
                                bg-gray-100
                                dark:bg-gray-800
                                hover-pop
                                p-3
                                rounded
                            "
                        >
                            <img
                                class="flex-none w-20 rounded"
                                :src="item.media.coverImage.medium"
                                :alt="item.media.title.userPreferred"
                            />

                            <div class="flex-grow">
                                <p class="text-lg font-bold">
                                    {{ item.media.title.userPreferred }}
                                </p>
                                <div class="mt-1 flex flex-row flex-wrap gap-1">
                                    <span
                                        class="
                                            text-white text-xs
                                            px-1
                                            py-0.5
                                            rounded-sm
                                            bg-blue-500
                                        "
                                        >Completed: {{ item.progress }}</span
                                    >
                                    <span
                                        class="
                                            text-white text-xs
                                            px-1
                                            py-0.5
                                            rounded-sm
                                            bg-purple-500
                                        "
                                        >Score:
                                        {{ item.media.meanScore / 10 }}</span
                                    >
                                </div>
                                <p
                                    class="mt-1.5 text-xs opacity-75"
                                    v-if="
                                        selectedTab === 'COMPLETED' &&
                                        item.completedAt
                                    "
                                >
                                    Completed at:
                                    {{
                                        new Date(
                                            `${item.completedAt.month}-${item.completedAt.day}-${item.completedAt.year}`
                                        ).toLocaleDateString()
                                    }}
                                </p>
                                <p class="mt-1.5 text-xs opacity-75" v-else>
                                    Started at:
                                    {{
                                        new Date(
                                            `${item.startedAt.month}-${item.startedAt.day}-${item.startedAt.year}`
                                        ).toLocaleDateString()
                                    }}
                                </p>
                                <ExternalLink
                                    class="text-xs relative -top-0.5"
                                    text="View on AniList"
                                    :url="item.media.siteUrl"
                                />
                            </div>
                        </div>
                    </router-link>
                </div>

                <div
                    class="
                        mt-6
                        flex flex-row
                        justify-center
                        items-center
                        gap-4
                        flex-wrap
                    "
                    v-if="items.data"
                >
                    <button
                        class="
                            px-3
                            py-1.5
                            focus:outline-none
                            hover:bg-gray-200
                            dark:hover:bg-gray-800
                            transition
                            duration-200
                            rounded
                        "
                        @click.stop.prevent="!!void prevPage()"
                    >
                        <Icon icon="chevron-left" />
                    </button>

                    <p>Page {{ page + 1 }}</p>

                    <button
                        class="
                            px-3
                            py-1.5
                            focus:outline-none
                            hover:bg-gray-200
                            dark:hover:bg-gray-800
                            transition
                            duration-200
                            rounded
                        "
                        @click.stop.prevent="!!void nextPage()"
                    >
                        <Icon icon="chevron-right" />
                    </button>
                </div>
            </div>
        </div>
    </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import { Rpc } from "../../../plugins/api";
import MyAnimeList from "../../../plugins/integrations/myanimelist";
import AniList, { Status } from "../../../plugins/integrations/anilist";
import { Await, NotNull, StateController, util } from "../../../plugins/util";

import PageTitle from "../../../components/PageTitle.vue";
import Loading from "../../../components/Loading.vue";
import ExternalLink from "../../../components/ExternalLink.vue";
import TabBar, { TabEntity } from "../../../components/TabBar.vue";

export default defineComponent({
    name: "Authentication",
    components: {
        PageTitle,
        Loading,
        TabBar,
        ExternalLink,
    },
    data() {
        const data: {
            userinfo: StateController<
                NotNull<Await<ReturnType<typeof AniList.userInfo>>>
            >;
            tabs: TabEntity[];
            selectedTab: string;
            items: StateController<
                NotNull<Await<ReturnType<typeof AniList.animelist>>>
            >;
            page: number;
            malBaseURL: string;
        } = {
            userinfo: util.createStateController(),
            tabs: Status.map((x) => ({
                id: x,
                text: `${x[0].toUpperCase()}${x.slice(1).toLowerCase()}`,
            })),
            selectedTab:
                typeof this.$route.query.selected === "string"
                    ? this.$route.query.selected
                    : Status[0],
            items: util.createStateController(),
            page: 0,
            malBaseURL: MyAnimeList.webURL,
        };

        return data;
    },
    mounted() {
        this.getInfo();
        this.getItems();
        this.setRpc();
    },
    methods: {
        async getInfo() {
            try {
                this.userinfo.state = "resolving";

                if (!AniList.isLoggedIn()) {
                    return this.$router.push("/connections");
                }

                const info = await AniList.userInfo();
                if (!info) {
                    this.userinfo.state = "failed";
                    return;
                }

                this.userinfo.data = info;
                this.userinfo.state = "resolved";
            } catch (err: any) {
                this.userinfo.state = "failed";
                this.$logger.emit(
                    "error",
                    `Failed to fetch user information: ${err?.message}`
                );
            }
        },
        async getItems() {
            try {
                this.items.state = "resolving";
                this.items.data = null;
                const items = await AniList.animelist(
                    <any>this.selectedTab,
                    this.page
                );
                this.items.state = "resolved";
                this.items.data = items || null;
            } catch (err: any) {
                this.items.state = "failed";
                this.$logger.emit(
                    "error",
                    `Failed to fetch anime list: ${err?.message}`
                );
            }
        },
        prevPage() {
            const page = this.page - 1;
            if (page >= 0) {
                this.page = page;
                this.getItems();
            }
        },
        nextPage() {
            this.page = this.page + 1;
            this.getItems();
        },
        async setRpc() {
            const rpc = await Rpc.getClient();
            rpc?.({
                details: "Viewing their AniList profile (Anime)",
            });
        },
        handleTabChange(tab: TabEntity) {
            this.selectedTab = tab.id;
            this.$router.replace({
                query: {
                    selected: tab.id,
                },
            });
            this.getItems();
        },
    },
});
</script>
