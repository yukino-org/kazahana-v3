<template>
    <div class="fixed top-0 left-0 right-0 w-full h-8 z-50">
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
            "
        >
            <div
                class="pl-5 pr-2 py-1 dark:text-indigo-500 font-bold draggable"
            >
                {{ title }}
                <span class="opacity-50 text-xs" v-if="version"
                    >({{ version }})</span
                >
            </div>
            <div class="flex-grow py-4 draggable"></div>
            <div class="flex flex-row justify-center items-center pr-3">
                <div
                    class="
                        titlebar-container
                        cursor-pointer
                        hover:bg-indigo-600
                        dark:hover:bg-gray-700
                    "
                    id="titlebar-minimize"
                    title="Minimize"
                >
                    <Icon
                        id="titlebar-icon"
                        :icon="['far', 'window-minimize']"
                    />
                </div>
                <div
                    class="
                        titlebar-container
                        cursor-pointer
                        hover:bg-indigo-600
                        dark:hover:bg-gray-700
                    "
                    id="titlebar-maximize"
                    title="Maximize"
                >
                    <Icon
                        id="titlebar-icon"
                        :icon="['far', 'window-maximize']"
                    />
                </div>
                <div
                    class="
                        titlebar-container
                        cursor-pointer
                        hover:bg-indigo-600
                        dark:hover:bg-gray-700
                    "
                    id="titlebar-reload"
                    title="Reload"
                >
                    <Icon id="titlebar-icon" icon="redo" />
                </div>
                <div
                    class="
                        titlebar-container
                        cursor-pointer
                        hover:bg-red-600
                        hover:text-white
                    "
                    id="titlebar-close"
                    title="Close"
                >
                    <Icon id="titlebar-icon" icon="times" />
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
        } = {
            title: document.title,
            version: app_version,
        };

        return data;
    },
});
</script>

<style scoped>
.draggable {
    -webkit-app-region: drag;
}

.titlebar-container {
    @apply px-3 rounded transition duration-200;
}

#titlebar-icon {
    @apply text-xs;
}
</style>
