<template>
    <div>
        <PageTitle title="Schedule" />

        <TabBar
            class="mt-8"
            :items="pages"
            :selected="selectedPage"
            @tabClick="handlePageChange"
        />

        <router-view></router-view>
    </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import { Rpc } from "../../plugins/api";

import PageTitle from "../../components/PageTitle.vue";
import TabBar, { TabEntity } from "../../components/TabBar.vue";

export default defineComponent({
    name: "Schedule-Main",
    components: {
        PageTitle,
        TabBar,
    },
    data() {
        const data: {
            pages: TabEntity[];
            selectedPage: string;
        } = {
            pages: [
                {
                    id: "/schedule",
                    text: "Season",
                },

                {
                    id: "/schedule/week",
                    text: "Week",
                },
            ],
            selectedPage: this.$route.path,
        };

        return data;
    },
    mounted() {
        this.setRpc();
    },
    methods: {
        handlePageChange(page: TabEntity) {
            this.$router.push(page.id);
            this.selectedPage = page.id;
        },
        async setRpc() {
            const rpc = await Rpc.getClient();
            rpc?.({
                details: "Viewing schedule",
            });
        },
    },
});
</script>
