<template>
    <div>
        <div
            class="
                bg-indigo-500
                text-white
                border-opacity-75
                px-3
                py-1.5
                rounded-r
                shadow
                flex flex-row
                justify-center
                items-center
                gap-2
            "
            v-if="info"
        >
            <div
                class="flex-grow cursor-pointer"
                v-if="info.showPopup"
                @click.prevent="navigateToLastWatched()"
            >
                <p class="text-xs opacity-75">Continue watching</p>
                <p class="font-bold">{{ info.title }}</p>
                <p class="text-xs opacity-75">
                    Watched <b>{{ getFormattedDuration(info.watched) }}</b> of
                    <b>{{ getFormattedDuration(info.total) }}</b>
                </p>
                <p class="text-xs opacity-75">
                    Updated at
                    <b>{{ new Date(info.updatedAt).toLocaleString() }}</b>
                </p>
            </div>
            <div
                class="
                    flex-none flex flex-col
                    justify-center
                    items-center
                    gap-1
                "
            >
                <button
                    class="bg-gray-800 w-8 text-2xl rounded focus:outline-none"
                    @click.prevent="toggleDialog()"
                >
                    <Icon icon="caret-left" v-if="info.showPopup" />
                    <Icon icon="caret-right" v-else />
                </button>
                <button
                    class="bg-gray-800 w-8 text-2xl rounded focus:outline-none"
                    @click.prevent="deleteLastWatched()"
                >
                    <Icon icon="times" />
                </button>
            </div>
        </div>
    </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import { Store } from "../plugins/api";
import { util } from "../plugins/util";
import { LastWatchedEntity } from "../plugins/types";

export default defineComponent({
    data() {
        const data: {
            info: LastWatchedEntity | null;
        } = {
            info: null,
        };

        return data;
    },
    mounted() {
        this.getLastWatched();
    },
    methods: {
        async getLastWatched() {
            try {
                const store = await Store.getClient();
                const lastWatched: LastWatchedEntity | null = await store.get(
                    "lastWatchedLeft"
                );
                if (lastWatched) {
                    this.info = lastWatched;
                }
            } catch (err) {}
        },
        async deleteLastWatched() {
            try {
                const store = await Store.getClient();
                await store.set("lastWatchedLeft", null);
                this.info = null;
            } catch (err) {}
        },
        async toggleDialog() {
            if (this.info) {
                try {
                    this.info.showPopup = !this.info.showPopup;
                    const store = await Store.getClient();
                    await store.set("lastWatchedLeft", { ...this.info });
                } catch (err) {}
            }
        },
        getFormattedDuration(sec: number) {
            const parsed = util.parseMs(sec * 1000);
            let output: string[] = [];
            if (parsed.days) output.push(`${parsed.days}`);
            if (parsed.hours) output.push(`${parsed.hours}`);
            output.push(`${parsed.mins}`);
            output.push(`${parsed.secs}`);
            return output.join(":");
        },
        navigateToLastWatched() {
            if (!this.info) return;

            this.$router.push({
                path: this.info.route.route,
                query: {
                    ...this.info.route.queries,
                    episode: this.info.episode,
                    watched: this.info.watched,
                },
            });
        },
    },
});
</script>
