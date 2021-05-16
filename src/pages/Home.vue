<template>
    <div>
        <PageTitle title="Home" />
    </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";

import PageTitle from "../components/PageTitle.vue";

export default defineComponent({
    name: "Home",
    components: {
        PageTitle,
    },
});
</script>
