<template>
    <span
        class="
            text-red-400
            hover:text-red-500
            transition
            duration-200
            cursor-pointer
        "
        v-if="url"
        @click="goToUrl()"
    >
        {{ text }} <Icon icon="external-link-alt" />
    </span>
</template>

<script lang="ts">
import { defineComponent } from "vue";

export default defineComponent({
    props: {
        text: String,
        url: String,
    },
    methods: {
        goToUrl() {
            if (!this.url) return;
            window.api.openExternalLink(this.url);
        },
    },
});
</script>
