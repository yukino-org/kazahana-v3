<template>
    <div>
        <TitleBar v-if="showTitleBar" />

        <SideBar v-if="showSideBar" />
        <BottomBar v-if="showBottomBar" />

        <div
            :class="[
                showTitleBar && 'pt-8',
                showSideBar
                    ? sideBarPosition === 'left'
                        ? 'pl-24 pr-10'
                        : 'pl-10 pr-24'
                    : 'px-8',
                showBottomBar && 'pb-20'
            ]"
        >
            <main
                :class="[
                    'pb-10 lg:col-span-3',
                    showBottomBar ? 'pt-8' : 'pt-10'
                ]"
                id="main-container"
            >
                <router-view
                    v-slot="{ Component: RouterComponent }"
                    :key="pageKey"
                >
                    <transition name="page" mode="out-in">
                        <component :is="RouterComponent" />
                    </transition>
                </router-view>
            </main>
        </div>

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
                md:h-12
                md:w-12
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
                showTitleBar && 'mt-8'
            ]"
        >
            <Notifications />
        </div>

        <div
            :class="[
                'fixed left-0 bottom-8 max-w-md mr-8 z-50',
                showBottomBar ? 'bottom-20' : 'bottom-8'
            ]"
        >
            <transition name="fade">
                <LastLeft v-if="$route.path === '/'" />
            </transition>
        </div>
    </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import { GlobalStateProps } from "./plugins/types";

import TitleBar from "./components/TitleBar.vue";
import SideBar from "./components/SideBar.vue";
import BottomBar from "./components/BottomBar.vue";
import Notifications from "./components/Logger.vue";
import LastLeft from "./components/LastLeft.vue";

export default defineComponent({
    name: "App",
    components: {
        TitleBar,
        SideBar,
        BottomBar,
        Notifications,
        LastLeft
    },
    data() {
        const data: {
            showTitleBar: boolean;
            showSideBar: boolean;
            showBottomBar: boolean;
            pageKey: number;
            sideBarPosition: string;
        } = {
            showTitleBar: this.$state.props.runtime.isElectron,
            showSideBar: this.$state.props.runtime.isElectron,
            showBottomBar: this.$state.props.runtime.isCapacitor,
            pageKey: 0,
            sideBarPosition: this.$state.props.sideBar
        };

        return data;
    },
    mounted() {
        window.addEventListener("scroll", this.onScroll);
        this.$bus.subscribe("state-update", this.stateListener);
    },
    beforeDestroy() {
        window.removeEventListener("scroll", this.onScroll);
        this.$bus.unsubscribe("state-update", this.stateListener);
    },
    methods: {
        stateListener({
            current
        }: {
            previous: GlobalStateProps;
            current: GlobalStateProps;
        }) {
            this.sideBarPosition = current.sideBar;
        },
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
                behavior: "smooth"
            });
        },
        reloadComponent() {
            this.pageKey += 1;
        }
    }
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
