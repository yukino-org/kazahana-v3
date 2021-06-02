<template>
    <button
        class="
            focus:outline-none
            text-red-400
            hover:text-red-500
            transition
            duration-200
            cursor-pointer
            pointer-events-auto
        "
        v-if="url"
        @click.stop.prevent="!!void goToUrl()"
    >
        {{ text }} <Icon icon="external-link-alt" />
    </button>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import { ExternalLink } from "../plugins/api";

export default defineComponent({
    props: {
        text: String,
        url: String,
    },
    methods: {
        async goToUrl() {
            if (!this.url) return;

            const opener = await ExternalLink.getClient();
            opener?.(this.url);
        },
    },
});
</script>
