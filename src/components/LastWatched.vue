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
                shadow-lg
                flex flex-row
                justify-center
                items-center
                gap-2
                md:gap-8
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
                    <b>{{ getFormattedDuration(info.total - info.watched) }}</b>
                    remaining
                </p>
                <p class="text-xs opacity-75">
                    Watched
                    <b>{{
                        getFormattedDuration(
                            (Date.now() - info.updatedAt) / 1000
                        )
                    }}</b>
                    ago
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
                    class="
                        bg-gray-800
                        w-8
                        h-8
                        text-sm
                        rounded
                        focus:outline-none
                        flex
                        justify-center
                        items-center
                    "
                    @click.prevent="toggleDialog()"
                >
                    <Icon icon="eye" v-if="info.showPopup" />
                    <Icon icon="eye-slash" v-else />
                </button>
                <button
                    class="
                        bg-gray-800
                        w-8
                        h-8
                        text-sm
                        rounded
                        focus:outline-none
                        flex
                        justify-center
                        items-center
                    "
                    v-if="info.showPopup"
                    @click.prevent="deleteLastWatched()"
                >
                    <Icon icon="trash" />
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
            if (parsed.days) output.push(`${parsed.days}d`);
            if (parsed.hours) output.push(`${parsed.hours}h`);
            output.push(`${parsed.mins}m`);
            output.push(`${parsed.secs}s`);
            return output.join(" ");
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
