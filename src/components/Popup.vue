<template>
    <transition name="fade">
        <div
            class="
                bg-gray-700 bg-opacity-75
                fixed
                top-0
                bottom-0
                right-0
                left-0
                w-full
                h-full
            "
            style="z-index: 498"
            v-if="show"
        ></div>
    </transition>

    <transition name="popup">
        <div
            class="
                fixed
                top-0
                bottom-0
                right-0
                left-0
                w-full
                h-full
                flex
                justify-center
                items-center
                overflow-hidden
            "
            style="
                min-height: calc(100vh - 6rem);
                max-width: calc(100% - 2rem);
                max-height: calc(100vh - 4rem);
                margin: 3rem 1rem;
                z-index: 499;
            "
            v-if="show"
            @click.stop.prevent="!!void close()"
        >
            <div class="overflow-y-auto max-h-full relative">
                <div class="bg-gray-100 dark:bg-gray-900 rounded-lg px-6 py-4">
                    <slot></slot>
                </div>
            </div>
        </div>
    </transition>
</template>

<script lang="ts">
import { defineComponent } from "vue";

export default defineComponent({
    emits: ["close"],
    props: {
        show: {
            type: Boolean,
            default: true
        }
    },
    methods: {
        close() {
            this.$emit("close");
        }
    }
});
</script>

<style scoped>
.popup-enter-active {
    transform: scale(0.9);
    opacity: 0;
    transition: 0.3s ease-in-out;
}

.popup-enter-to {
    transform: scale(1);
    opacity: 1;
}

.popup-leave-active {
    transition: 0.3s ease-in-out;
}

.popup-leave-to {
    transform: scale(0.9);
    opacity: 0;
}
</style>
