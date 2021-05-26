<template>
    <div class="text-center">
        <h1 class="text-indigo-500 font-bold text-5xl">Yukino</h1>

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
            <div v-for="link in links" class="mb-2" :key="link.url">
                <button
                    :class="[hrefClassNames, 'focus:outline-none']"
                    @click.prevent="openExternalUrl(link.url)"
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
                    {{ link.name }}</router-link
                >
            </div>

            <div class="flex flex-row gap-3 lg:mt-5">
                <button
                    :class="[
                        hrefClassNames,
                        'focus:outline-none bg-gray-200 dark:bg-gray-700 rounded-full w-8 h-8 flex justify-center items-center',
                    ]"
                    title="Go back"
                    @click.prevent="$router.go(-1)"
                >
                    <Icon icon="arrow-left" />
                </button>

                <button
                    :class="[
                        hrefClassNames,
                        'focus:outline-none bg-gray-200 dark:bg-gray-700 rounded-full w-8 h-8 flex justify-center items-center',
                    ]"
                    title="Go forward"
                    @click.prevent="$router.go(1)"
                >
                    <Icon icon="arrow-right" />
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
                    @click.prevent="switchTheme()"
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
</template>

<script lang="ts">
import { defineComponent } from "vue";
import api from "../plugins/api";

export default defineComponent({
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
                name: "Donate",
                url: "https://www.patreon.com/zyrouge",
                external: true,
                icon: "heart",
            },
            {
                name: "Settings",
                url: "/settings",
                external: false,
                icon: "cog",
            },
        ];

        return {
            links,
        };
    },
    data() {
        const data: {
            hrefClassNames: string[];
            darkMode: boolean;
        } = {
            hrefClassNames: [
                "text-lg",
                "hover:text-indigo-600",
                "dark:hover:text-indigo-400",
                "transition",
                "duration-200",
            ],
            darkMode: false,
        };

        return data;
    },
    mounted() {
        this.configureTheme();
    },
    methods: {
        configureTheme() {
            this.darkMode = localStorage.darkMode === "1";
            if (this.darkMode) {
                document.documentElement.classList.add("dark");
            } else {
                document.documentElement.classList.remove("dark");
            }
        },
        switchTheme() {
            if (localStorage.darkMode === "1") {
                delete localStorage.darkMode;
            } else {
                localStorage.darkMode = "1";
            }
            this.configureTheme();
        },
        openExternalUrl: api.openExternalUrl,
    },
});
</script>
