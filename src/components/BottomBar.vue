<template>
    <div>
        <div
            :class="[
                'fixed bottom-0 left-0 right-0 h-16 text-indigo-200 dark:text-white z-50 bg-indigo-500 dark:bg-gray-800 flex flex-row justify-evenly items-center border-t border-gray-200 border-opacity-20',
                compactBottomBar ? 'h-14' : 'h-16'
            ]"
        >
            <button
                :class="[
                    'relative focus:outline-none transition duration-200',
                    !item.external &&
                        $route.path === item.url &&
                        'text-white dark:text-indigo-500'
                ]"
                @click.stop.prevent="!!void goto(item.url, item.external)"
                v-for="item in links"
            >
                <Icon class="text-xl" :icon="item.icon" />

                <p class="opacity-50 mt-0.5 text-xs" v-if="!hideBottomBarText">
                    {{ item.name }}
                </p>
            </button>

            <button
                :class="[
                    'relative focus:outline-none transition duration-200',
                    isOpen && 'text-white dark:text-indigo-500'
                ]"
                @click.stop.prevent="!!void toggleMenu()"
            >
                <Icon class="text-lg" icon="bars" />

                <p class="opacity-50 text-xs" v-if="!hideBottomBarText">
                    Options
                </p>
            </button>
        </div>

        <div
            :class="[
                'fixed w-[calc(100vw-8rem)] right-10 bottom-20 text-indigo-200 dark:text-white z-[51] bg-indigo-500 dark:bg-gray-700 px-4 py-2.5 shadow rounded-md grid gap-1',
                isOpen && 'active'
            ]"
            id="bottom-other"
        >
            <button
                :class="[
                    'focus:outline-none py-0.5 text-lg',
                    $route.path === item.url &&
                        'text-white dark:text-indigo-500'
                ]"
                @click.stop.prevent="
                    !!void goto(item.url, item.external).then(() =>
                        toggleMenu()
                    )
                "
                v-for="item in others"
            >
                <Icon class="mr-2" :icon="item.icon" /> {{ item.name }}
            </button>
        </div>
    </div>
</template>

<script lang="ts">
import { defineComponent, computed, ref, Ref } from "vue";
import { ExternalLink } from "../plugins/api";
import { BarRoutes } from "../plugins/router";
import { GlobalStateProps } from "../plugins/types";

export default defineComponent({
    data() {
        const data: {
            isOpen: boolean;
            hideBottomBarText: boolean;
            compactBottomBar: boolean;
            bottomBarItemsCount: Ref<GlobalStateProps["bottomBarItemsCount"]>;
        } = {
            isOpen: false,
            hideBottomBarText: this.$state.props.hideBottomBarText,
            compactBottomBar: this.$state.props.compactBottomBar,
            bottomBarItemsCount: ref(this.$state.props.bottomBarItemsCount)
        };

        return Object.assign(data, {
            links: computed(() =>
                BarRoutes.slice(0, data.bottomBarItemsCount.value - 1)
            ),
            others: computed(() =>
                BarRoutes.slice(data.bottomBarItemsCount.value - 1)
            )
        });
    },
    mounted() {
        this.$bus.subscribe("state-update", this.stateListener);
    },
    beforeDestroy() {
        this.$bus.unsubscribe("state-update", this.stateListener);
    },
    methods: {
        stateListener({
            current
        }: {
            previous: GlobalStateProps;
            current: GlobalStateProps;
        }) {
            this.hideBottomBarText = current.hideBottomBarText;
            this.compactBottomBar = current.compactBottomBar;
            this.bottomBarItemsCount = current.bottomBarItemsCount;
        },
        toggleMenu() {
            this.isOpen = !this.isOpen;
        },
        async goto(url: string, external: boolean) {
            if (external) {
                const opener = await ExternalLink.getClient();
                opener?.(url);
            } else {
                this.$router.push({
                    path: url
                });
            }
        }
    }
});
</script>

<style scoped>
#bottom-other {
    opacity: 0;
    visibility: hidden;
    transform: translateY(0.5rem) scale(0.9);
    transform-origin: 100% 100%;
    transition: 0.3s;
}

#bottom-other.active {
    opacity: 1;
    visibility: visible;
    transform: translateY(0) scale(1);
}
</style>
