<template>
    <div class="fixed top-0 left-0 right-0 w-full h-8" style="z-index: 999">
        <div
            class="
                flex flex-row
                justify-between
                items-center
                text-white
                bg-indigo-500
                dark:bg-gray-800
                shadow
                select-none
                px-5
            "
        >
            <div
                class="flex flex-row justify-center items-center gap-2"
                v-if="isMac"
            >
                <button
                    class="
                        focus:outline-none
                        p-1.5
                        bg-red-500
                        hover:bg-red-600
                        transition
                        duration-200
                        rounded-full
                        shadow-inner
                    "
                    @click="!!void closeWindow()"
                ></button>
                <button
                    class="
                        focus:outline-none
                        p-1.5
                        bg-yellow-500
                        hover:bg-yellow-600
                        transition
                        duration-200
                        rounded-full
                        shadow-inner
                    "
                    @click="!!void minimizeWindow()"
                ></button>
                <button
                    class="
                        focus:outline-none
                        p-1.5
                        bg-green-500
                        hover:bg-green-600
                        transition
                        duration-200
                        rounded-full
                        shadow-inner
                    "
                    @click="!!void maximizeWindow()"
                ></button>
            </div>
            <div class="flex-grow draggable pb-8" v-if="isMac"></div>

            <div
                :class="[
                    'py-1 font-bold flex justify-center items-center gap-1',
                    isMac ? 'flex-row-reverse' : 'flex-row'
                ]"
            >
                <p class="draggable dark:text-indigo-500">
                    {{ title }}
                </p>

                <p
                    class="draggable dark:text-indigo-500 opacity-50 text-xs"
                    v-if="version"
                >
                    ({{ version }})
                </p>

                <div
                    :class="[
                        'flex flex-row justify-center items-center',
                        isMac ? 'mr-4' : 'ml-4'
                    ]"
                >
                    <button
                        class="cursor-pointer focus:outline-none rounded opacity-50 hover:opacity-100 px-2 transition duration-200"
                        @click.stop.prevent="!!void $router.go(-1)"
                        title="Go back"
                    >
                        <Icon icon="arrow-left" />
                    </button>

                    <button
                        class="cursor-pointer focus:outline-none rounded opacity-50 hover:opacity-100 px-2 transition duration-200"
                        @click.stop.prevent="!!void $router.go(1)"
                        title="Go forward"
                    >
                        <Icon icon="arrow-right" />
                    </button>
                </div>
            </div>

            <div class="flex-grow draggable pb-8" v-if="!isMac"></div>
            <div
                class="flex flex-row justify-center items-center"
                v-if="!isMac"
            >
                <div
                    class="
                        titlebar-container
                        cursor-pointer
                        hover:bg-indigo-600
                        dark:hover:bg-gray-700
                    "
                    @click="!!void minimizeWindow()"
                    title="Minimize"
                >
                    <Icon class="text-xs" :icon="['far', 'window-minimize']" />
                </div>
                <div
                    class="
                        titlebar-container
                        cursor-pointer
                        hover:bg-indigo-600
                        dark:hover:bg-gray-700
                    "
                    @click="!!void maximizeWindow()"
                    title="Maximize"
                >
                    <Icon class="text-xs" :icon="['far', 'window-maximize']" />
                </div>
                <div
                    class="
                        titlebar-container
                        cursor-pointer
                        hover:bg-indigo-600
                        dark:hover:bg-gray-700
                    "
                    @click="!!void reloadWindow()"
                    v-if="view_reload"
                    title="Reload"
                >
                    <Icon class="text-xs" icon="sync-alt" />
                </div>
                <div
                    class="
                        titlebar-container
                        cursor-pointer
                        hover:bg-red-600
                        hover:text-white
                    "
                    @click="!!void closeWindow()"
                    title="Close"
                >
                    <Icon class="text-xs" icon="times" />
                </div>
            </div>
        </div>
    </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";

export default defineComponent({
    data() {
        const data: {
            title: string;
            version: string;
            view_reload: boolean;
            isMac: boolean;
        } = {
            title: document.title,
            version: app_version,
            view_reload: !import.meta.env.PROD,
            isMac: this.$state.props.runtime.isMac
        };

        return data;
    },
    methods: {
        minimizeWindow() {
            window.PlatformBridge?.minimizeWindow();
        },
        maximizeWindow() {
            window.PlatformBridge?.maximizeWindow();
        },
        reloadWindow() {
            window.PlatformBridge?.reloadWindow();
        },
        closeWindow() {
            window.PlatformBridge?.closeWindow();
        }
    }
});
</script>

<style scoped>
.draggable {
    -webkit-app-region: drag;
}

.titlebar-container {
    @apply px-3 rounded transition duration-200;
}
</style>
