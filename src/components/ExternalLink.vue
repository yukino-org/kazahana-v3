<template>
    <span>
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
    </span>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import api from "../plugins/api";

export default defineComponent({
    props: {
        text: String,
        url: String,
    },
    methods: {
        goToUrl() {
            if (!this.url) return;
            api.openExternalUrl(this.url);
        },
    },
});
</script>
