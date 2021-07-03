<template>
    <div
        :class="[
            'fixed top-8 bottom-0 h-[calc(100vh-2rem)] text-indigo-200 dark:text-white z-50 max-w-[calc(100vw-25%)] w-14',
            sideBarPosition === 'left' ? 'left-0' : 'right-0'
        ]"
        id="side-bar"
    >
        <div class="flex flex-col justify-center items-center w-full h-full">
            <div
                :class="[
                    'bg-indigo-500 dark:bg-gray-800 flex flex-col justify-center items-center w-full py-5 gap-4 shadow-lg',
                    sideBarPosition === 'left' ? 'rounded-r-lg' : 'rounded-l-lg'
                ]"
            >
                <button
                    :class="[
                        'relative focus:outline-none hover:text-indigo-100 dark:hover:text-gray-300 transition duration-200',
                        !item.external &&
                            $route.path === item.url &&
                            'text-white dark:text-indigo-500 dark:hover:text-indigo-500'
                    ]"
                    @click.stop.prevent="!!void goto(item.url, item.external)"
                    v-for="item in links"
                    id="side-item"
                >
                    <Icon class="text-xl" :icon="item.icon" />

                    <p
                        class="
                            absolute
                            -top-1
                            left-14
                            z-50
                            text-gray-500
                            dark:text-white
                            bg-gray-200
                            dark:bg-gray-700
                            px-2.5
                            py-1
                            rounded
                        "
                        id="side-tooltip"
                    >
                        {{ item.name }}
                    </p>
                </button>
            </div>
        </div>
    </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import { ExternalLink } from "../plugins/api";
import { BarRoutes } from "../plugins/router";
import { GlobalStateProps } from "../plugins/types";

export default defineComponent({
    data() {
        const data: {
            sideBarPosition: string;
            links: typeof BarRoutes;
        } = {
            sideBarPosition: this.$state.props.sideBar,
            links: BarRoutes
        };

        return data;
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
            this.sideBarPosition = current.sideBar;
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
#side-item #side-tooltip {
    visibility: hidden;
    opacity: 0;
    transform: translateX(-0.5rem) scale(0.9);
    transition: 0.3s;
}

#side-item:hover #side-tooltip {
    visibility: visible;
    opacity: 1;
    transform: translateX(0) scale(1);
}
</style>
