<template>
    <div class="text-center">
        <h1 class="text-indigo-500 font-bold text-5xl">Yukino</h1>
        <button
            class="
                mt-8
                focus:outline-none
                bg-gray-200
                dark:bg-gray-600
                px-1
                py-0.5
                rounded-full
            "
            @click="switchTheme()"
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
        <div
            class="
                mt-8
                flex flex-row
                lg:flex-col
                justify-center
                items-center
                gap-4
                lg:gap-0
            "
        >
            <div v-for="link in links" class="mb-2" :key="link.url">
                <a :class="hrefClassNames" :href="link.url" v-if="link.external"
                    ><span class="mr-1 opacity-75"
                        ><Icon :icon="link.icon"
                    /></span>
                    {{ link.name }}</a
                >
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
        </div>
    </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";

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
    },
});
</script>
