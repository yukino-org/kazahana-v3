<template>
    <div>
        <PageTitle title="Schedule" />

        <div
            class="
                mt-4
                w-full
                flex flex-row
                justify-center
                items-center
                text-center
                rounded
                overflow-hidden
            "
        >
            <router-link
                class="flex-grow"
                :to="page.path"
                v-for="page in pages"
            >
                <div
                    :class="[
                        'border-b-2',
                        'leading-loose',
                        'cursor-pointer',
                        'hover:bg-gray-100',
                        'dark:hover:bg-gray-800',
                        $route.path === page.path
                            ? 'border-indigo-500 text-indigo-500 border-opacity-100'
                            : 'border-gray-800 dark:border-gray-100 border-opacity-20 dark:border-opacity-20',
                    ]"
                >
                    {{ page.name }}
                </div>
            </router-link>
        </div>

        <router-view></router-view>
    </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import { Rpc } from "../../plugins/api";

import PageTitle from "../../components/PageTitle.vue";
import Week from "./Week.vue";

export default defineComponent({
    name: "Schedule-Week",
    components: {
        PageTitle,
        Week,
    },
    data() {
        const data: {
            pages: {
                name: string;
                path: string;
            }[];
        } = {
            pages: [
                {
                    name: "Season",
                    path: "/schedule",
                },

                {
                    name: "Week",
                    path: "/schedule/week",
                },
            ],
        };

        return data;
    },
    mounted() {
        this.setRpc();
    },
    methods: {
        async setRpc() {
            const rpc = await Rpc.getClient();
            rpc?.({
                details: "Viewing schedule",
            });
        },
    },
});
</script>
