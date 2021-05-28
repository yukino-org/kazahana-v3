<template>
    <div class="text-center">
        <Icon
            class="text-5xl md:text-6xl"
            :icon="['far', 'snowflake']"
            id="loader-snowflake"
        />
        <p class="mt-4">{{ text }}</p>
    </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";

export default defineComponent({
    name: "Loading",
    props: {
        text: {
            type: String,
            default: "Please wait...",
        },
    },
});
</script>

<style scoped>
#loader-snowflake {
    animation: fadeinout 1.2s infinite cubic-bezier(0.65, 0.05, 0.36, 1);
}

@keyframes fadeinout {
    0% {
        opacity: 1;
    }

    50% {
        opacity: 0.9;
    }

    100% {
        opacity: 1;
    }
}
</style>
