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
                    mx-6
                    sm:mx-8
                    md:mx-10
                    my-6
                    sm:my-8
                "
            >
                <aside :class="[sideBarPosition === 'right' && 'order-last']">
                    <SideBar
                        class="
                            px-8
                            py-10
                            lg:col-span-1
                            rounded
                            bg-gray-100
                            dark:bg-gray-800
                            lg:sticky
                            lg:top-16
                            overflow-hidden
                        "
                        :reload="reloadComponent"
                    />
                </aside>
                <main class="py-6 lg:col-span-3" id="main-container">
                    <router-view
                        v-slot="{ Component: RouterComponent }"
                        :key="pageKey"
                    >
                        <transition name="page" mode="out-in">
                            <component :is="RouterComponent" />
                        </transition>
                    </router-view>
                </main>
            </section>
            <button
                class="
                    fixed
                    rounded
                    bg-indigo-500
                    hover:bg-indigo-600
                    transition
                    duration-200
                    text-white
                    focus:outline-none
                    px-1
                    py-0.5
                    bottom-2
                    h-10
                    w-10
                    md:h-14
                    md:w-14
                    shadow-lg
                "
                id="scroll-btn"
                @click.stop.prevent="!!void goToTop()"
            >
                <Icon class="text-2xl md:text-3xl" icon="arrow-up" />
            </button>

            <div
                :class="[
                    'fixed right-6 top-6 max-w-xs z-50',
                    showTitleBar && 'mt-8',
                ]"
            >
                <Notifications />
            </div>
        </div>

        <div class="fixed left-0 bottom-8 max-w-md mr-8 z-50">
            <transition name="fade">
                <LastLeft v-if="$route.path === '/'" />
            </transition>
        </div>
    </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import { Store } from "./plugins/api";
import { constants } from "./plugins/util";

import TitleBar from "./components/TitleBar.vue";
import SideBar from "./components/SideBar.vue";
import Notifications from "./components/Logger.vue";
import LastLeft from "./components/LastLeft.vue";

export default defineComponent({
    name: "App",
    components: {
        TitleBar,
        SideBar,
        Notifications,
        LastLeft,
    },
    data() {
        const data: {
            showTitleBar: boolean;
            sideBarPosition: string;
            pageKey: number;
        } = {
            showTitleBar: ["electron"].includes(app_platform),
            sideBarPosition: "left",
            pageKey: 0,
        };

        return data;
    },
    mounted() {
        window.addEventListener("scroll", this.onScroll);
        this.applySettings();
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
        async applySettings() {
            const store = await Store.getClient();
            this.sideBarPosition =
                (await store.get(constants.storeKeys.settings))
                    ?.sideBarPosition || "left";
        },
        reloadComponent() {
            this.pageKey += 1;
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
    right: 0.5rem;
}

.page-enter-from {
    opacity: 0;
}

.page-enter-active {
    transform: translateY(-1rem);
    transition: 0.4s ease;
}

.page-enter-to {
    transform: translateY(0);
}

.page-leave-active {
    transition: 0.4s ease;
}

.page-leave-to {
    opacity: 0;
    transform: translateY(1rem);
}
</style>
