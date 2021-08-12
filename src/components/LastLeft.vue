<template>
    <div>
        <transition name="slidein">
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
                    @click.stop.prevent="!!void navigateToLastWatched()"
                >
                    <p class="text-xs opacity-75">
                        Continue
                        {{
                            info.episode
                                ? "watching"
                                : info.reading
                                ? "reading"
                                : ""
                        }}
                    </p>
                    <p class="font-bold">{{ info.title }}</p>
                    <p class="text-xs opacity-75" v-if="info.episode">
                        <b>{{
                            getFormattedDuration(
                                info.episode.total - info.episode.watched
                            )
                        }}</b>
                        remaining
                    </p>
                    <p class="text-xs opacity-75" v-else-if="info.reading">
                        Read <b>{{ info.reading.read }}</b> of
                        <b>{{ info.reading.total }}</b> pages
                    </p>
                    <p class="text-xs opacity-75">
                        {{
                            info.episode
                                ? "Watched"
                                : info.reading
                                ? "Read"
                                : ""
                        }}
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
                        @click.stop.prevent="!!void toggleDialog()"
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
                        @click.stop.prevent="!!void deleteLastWatched()"
                    >
                        <Icon icon="trash" />
                    </button>
                </div>
            </div>
        </transition>
    </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import { Store } from "../plugins/api";
import { util } from "../plugins/util";
import { LastLeftEntity, StoreKeys, StoreStructure } from "../plugins/types";

export default defineComponent({
    data() {
        const data: {
            info: StoreStructure[StoreKeys.lastWatchedLeft] | null;
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
                const lastWatched: LastLeftEntity | null = await store.get(
                    StoreKeys.lastWatchedLeft
                );
                if (lastWatched) {
                    this.info = lastWatched;
                }
            } catch (err: any) {}
        },
        async deleteLastWatched() {
            try {
                const store = await Store.getClient();
                await store.set(StoreKeys.lastWatchedLeft, null);
                this.info = null;
            } catch (err: any) {}
        },
        async toggleDialog() {
            if (this.info) {
                try {
                    this.info.showPopup = !this.info.showPopup;
                    const store = await Store.getClient();
                    await store.set(
                        StoreKeys.lastWatchedLeft,
                        util.mergeObject({}, this.info)
                    );
                } catch (err: any) {}
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

            const query: Record<string, string> = {};

            if (this.info.episode) {
                Object.assign(query, {
                    episode: this.info.episode.episode,
                    watched: this.info.episode.watched,
                });
            } else if (this.info.reading) {
                Object.assign(query, {
                    page: this.info.reading.read,
                    volume: this.info.reading.volume,
                    chapter: this.info.reading.chapter,
                });
            }

            this.$router.push({
                path: this.info.route.route,
                query: {
                    ...this.info.route.queries,
                    ...query,
                },
            });
        },
    },
});
</script>

<style scoped>
.slidein-enter-active {
    transform: translateX(-30rem);
    transition: 0.5s ease;
}

.slidein-enter-to {
    transform: translateX(0);
}

.slidein-leave-active {
    transition: 0.3s ease;
}

.slidein-leave-to {
    opacity: 0;
}
</style>
