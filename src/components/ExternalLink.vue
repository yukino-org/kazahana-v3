<template>
    <a
        href="#"
        class="
            text-red-400
            hover:text-red-500
            transition
            duration-200
            cursor-pointer
        "
        v-if="url"
        @click.prevent="goToUrl()"
    >
        {{ text }} <Icon icon="external-link-alt" />
    </a>
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
