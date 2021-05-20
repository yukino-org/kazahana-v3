<template>
    <div>
        <div>
            <TitleBar v-if="showTitleBar" />
        </div>
        <div :class="[showTitleBar && 'pt-8']">
            <section
                class="
                    grid
                    lg:grid-cols-4
                    gap-8
                    lg:gap-10
                    auto-cols-fr
                    mx-10
                    my-8
                "
            >
                <aside>
                    <SideBar
                        class="
                            py-6
                            lg:col-span-1
                            rounded
                            bg-gray-100
                            dark:bg-gray-800
                        "
                    />
                </aside>
                <main class="py-6 lg:col-span-3">
                    <router-view></router-view>
                </main>
            </section>
            <button
                class="
                    fixed
                    bg-indigo-500
                    hover:bg-indigo-600
                    transition
                    duration-200
                    text-white
                    focus:outline-none
                    px-1
                    py-0.5
                    bottom-14
                    h-14
                    w-14
                    shadow-lg
                "
                id="scroll-btn"
                @click.prevent="goToTop()"
            >
                <Icon class="text-3xl" icon="arrow-up" />
            </button>

            <div class="fixed right-6 top-6 max-w-xs z-50">
                <Notifications />
            </div>
        </div>
    </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";

import TitleBar from "./components/TitleBar.vue";
import SideBar from "./components/SideBar.vue";
import Notifications from "./components/Logger.vue";

export default defineComponent({
    name: "App",
    components: {
        TitleBar,
        SideBar,
        Notifications,
    },
    data() {
        const data: {
            showTitleBar: boolean;
        } = {
            showTitleBar: ["electron"].includes(platform),
        };

        return data;
    },
    mounted() {
        window.addEventListener("scroll", this.onScroll);
    },
    beforeUnmount() {
        window.removeEventListener("scroll", this.onScroll);
    },
    methods: {
        onScroll() {
            const btn = document.getElementById("scroll-btn");
            if (
                document.body.scrollTop > 20 ||
                document.documentElement.scrollTop > 20
            ) {
                btn?.classList.add("active");
            } else {
                btn?.classList.remove("active");
            }
        },
        goToTop() {
            window.scroll({
                top: 0,
                left: 0,
                behavior: "smooth",
            });
        },
    },
});
</script>

<style scoped>
#scroll-btn {
    right: -15rem;
    transition: 0.3s;
}

#scroll-btn.active {
    right: 0;
}
</style>
