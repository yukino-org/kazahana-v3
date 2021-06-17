<template>
    <div>
        <div
            :class="[
                'text-center',
                'md:overflow-y-auto',
                'md:max-h-[calc(100vh-11rem)]',
                'slim-scroll',
            ]"
        >
            <h1 class="text-indigo-500 font-bold text-5xl md:text-4xl">
                {{ sideBarTitle }}
            </h1>

            <div
                class="
                    mt-8
                    flex flex-row
                    lg:flex-col
                    justify-center
                    items-center
                    gap-4
                    lg:gap-0
                    flex-wrap
                "
            >
                <div v-for="link in links" class="md:mb-2">
                    <button
                        :class="[hrefClassNames, 'focus:outline-none']"
                        @click.stop.prevent="!!void openExternalUrl(link.url)"
                        v-if="link.external"
                    >
                        <span class="mr-1 opacity-75"
                            ><Icon :icon="link.icon"
                        /></span>
                        {{ link.name }}
                    </button>
                    <router-link
                        :class="hrefClassNames"
                        active-class="text-indigo-500"
                        :to="link.url"
                        v-else
                        ><span class="mr-1 opacity-75"
                            ><Icon :icon="link.icon"
                        /></span>
                        {{ link.name }}
                    </router-link>
                </div>

                <div
                    class="
                        flex flex-row
                        justify-center
                        items-center
                        flex-wrap
                        gap-3
                        lg:mt-5
                        md:mb-2
                    "
                >
                    <button
                        :class="[
                            hrefClassNames,
                            'focus:outline-none bg-gray-200 dark:bg-gray-700 rounded-full w-8 h-8 flex justify-center items-center',
                        ]"
                        title="Go back"
                        @click.stop.prevent="!!void $router.go(-1)"
                    >
                        <Icon icon="arrow-left" />
                    </button>

                    <button
                        :class="[
                            hrefClassNames,
                            'focus:outline-none bg-gray-200 dark:bg-gray-700 rounded-full w-8 h-8 flex justify-center items-center',
                        ]"
                        title="Go forward"
                        @click.stop.prevent="!!void $router.go(1)"
                    >
                        <Icon icon="arrow-right" />
                    </button>

                    <button
                        :class="[
                            hrefClassNames,
                            'focus:outline-none bg-gray-200 dark:bg-gray-700 rounded-full w-8 h-8 flex justify-center items-center',
                        ]"
                        title="Reload page"
                        @click.stop.prevent="!!void reload()"
                        v-if="reload"
                    >
                        <Icon icon="redo" />
                    </button>

                    <button
                        class="
                            focus:outline-none
                            bg-gray-200
                            dark:bg-gray-700
                            px-1
                            py-0.5
                            rounded-full
                        "
                        v-if="!autoDetectTheme"
                        @click.stop.prevent="!!void switchTheme()"
                        style="width: 3rem"
                    >
                        <span
                            :class="[
                                'flex',
                                'flex-row',
                                darkMode ? 'justify-end' : 'justify-start',
                            ]"
                        >
                            {{ darkMode ? "🌙" : "🌞" }}
                        </span>
                    </button>
                </div>
            </div>
        </div>
    </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import { ExternalLink, Store } from "../plugins/api";
import { constants } from "../plugins/util";
import { Settings } from "../plugins/types";

export default defineComponent({
    props: {
        reload: {
            type: Function,
            default: null,
        },
    },
    setup() {
        const links: {
            name: string;
            url: string;
            external: boolean;
            icon: string;
        }[] = [
            {
                name: "Home",
                url: "/",
                external: false,
                icon: "home",
            },
            {
                name: "Search",
                url: "/search",
                external: false,
                icon: "search",
            },
            {
                name: "Schedule",
                url: "/schedule",
                external: false,
                icon: "calendar-alt",
            },
            {
                name: "Bookmarks",
                url: "/bookmark",
                external: false,
                icon: "bookmark",
            },
            {
                name: "History",
                url: "/history",
                external: false,
                icon: "history",
            },
            {
                name: "Settings",
                url: "/settings",
                external: false,
                icon: "cog",
            },
            {
                name: "About",
                url: "/about",
                external: false,
                icon: "question",
            },
        ];

        return {
            links,
        };
    },
    data() {
        const data: {
            sideBarTitle: string;
            hrefClassNames: string[];
            darkMode: boolean;
            autoDetectTheme: boolean;
        } = {
            sideBarTitle: app_name,
            hrefClassNames: [
                "text-lg",
                "hover:text-indigo-600",
                "dark:hover:text-indigo-400",
                "transition",
                "duration-200",
            ],
            autoDetectTheme: this.$constants.props.autoDetectTheme,
            darkMode: this.$constants.props.isDarkTheme,
        };

        return data;
    },
    mounted() {
        this.listenToGlobalConsts();
    },
    methods: {
        listenToGlobalConsts() {
            this.$constants.listen((previous, current) => {
                this.autoDetectTheme = current.autoDetectTheme;
                this.darkMode = current.isDarkTheme;
            });
        },
        async switchTheme() {
            const store = await Store.getClient();

            this.$constants.update({
                isDarkTheme: !this.$constants.props.isDarkTheme,
            });

            const settings: Partial<Settings> = await store.get(
                constants.storeKeys.settings
            );

            settings.darkMode = this.$constants.props.isDarkTheme
                ? "enabled"
                : "disabled";
            await store.set(constants.storeKeys.settings, settings);
        },
        async openExternalUrl(url: string) {
            const opener = await ExternalLink.getClient();
            opener?.(url);
        },
    },
});
</script>
