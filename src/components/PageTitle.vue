<template>
    <h1 class="text-4xl font-bold">{{ title }}</h1>
</template>

<script lang="ts">
import { defineComponent } from "vue";

export default defineComponent({
    props: {
        title: String,
    },
});
</script>
