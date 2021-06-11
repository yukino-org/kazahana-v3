<template>
    <div>
        <div>
            <Loading
                class="mt-8"
                v-if="['waiting', 'resolving'].includes(schedule.state)"
                text="Fetching schedule, please wait..."
            />
            <p
                class="mt-6 text-center opacity-75"
                v-else-if="schedule.state === 'failed'"
            >
                Failed to load schedule!
            </p>
            <p
                class="mt-6 text-center opacity-75"
                v-else-if="schedule.state === 'resolved' && !schedule.data"
            >
                No results were found!
            </p>
            <div
                class="mt-4"
                v-else-if="schedule.state === 'resolved' && schedule.data"
            >
                <div class="mb-3" v-for="day in schedule.data">
                    <div
                        class="
                            flex flex-row
                            justify-between
                            items-center
                            gap-2
                            cursor-pointer
                            text-indigo-500
                            hover:text-indigo-600
                            dark:hover:text-indigo-400
                            transition
                            duration-200
                        "
                        @click.stop.prevent="!!void setActive(day.date)"
                    >
                        <p class="text-xl font-bold">
                            {{ day.date }}
                            <span
                                class="ml-1.5 text-xs opacity-75"
                                v-if="day.date === today"
                            >
                                — today</span
                            >
                        </p>

                        <p class="opacity-75 text-white">
                            <Icon icon="caret-up" v-if="active === day.date" />
                            <Icon icon="caret-down" v-else />
                        </p>
                    </div>

                    <div
                        class="mt-2 mb-5 grid grid-cols-1 md:grid-cols-2 gap-3"
                        v-if="active === day.date"
                    >
                        <div class="col-span-1" v-for="anime in day.entities">
                            <router-link
                                :to="{
                                    path: '/anime',
                                    query: {
                                        url: anime.url,
                                    },
                                }"
                            >
                                <div
                                    class="
                                        hover-pop
                                        bg-gray-100
                                        dark:bg-gray-800
                                        rounded
                                        p-3
                                    "
                                >
                                    <div
                                        class="
                                            flex flex-row
                                            justify-center
                                            items-center
                                            gap-4
                                        "
                                    >
                                        <img
                                            class="w-20 rounded flex-none"
                                            :src="anime.image"
                                            :alt="anime.name"
                                        />

                                        <div class="flex-grow">
                                            <p class="text-xl font-bold">
                                                {{ anime.name }}
                                            </p>

                                            <div
                                                class="
                                                    mt-1
                                                    flex flex-row flex-wrap
                                                    gap-1
                                                "
                                            >
                                                <span
                                                    class="
                                                        capitalize
                                                        text-white text-xs
                                                        px-1
                                                        py-0.5
                                                        rounded-sm
                                                        bg-red-500
                                                    "
                                                    >Type:
                                                    {{ anime.type }}</span
                                                >
                                                <span
                                                    class="
                                                        text-white text-xs
                                                        px-1
                                                        py-0.5
                                                        rounded-sm
                                                        bg-blue-500
                                                    "
                                                    >Episodes:
                                                    {{ anime.episode }}</span
                                                >
                                                <span
                                                    class="
                                                        text-white text-xs
                                                        px-1
                                                        py-0.5
                                                        rounded-sm
                                                        bg-purple-500
                                                    "
                                                    >Score:
                                                    {{ anime.score }}</span
                                                >
                                            </div>

                                            <p class="mt-1.5 text-xs">
                                                <span class="opacity-75"
                                                    >Date: </span
                                                >{{ anime.date }}
                                            </p>
                                        </div>
                                    </div>

                                    <div
                                        class="opacity-80 mt-2 text-sm"
                                        v-if="anime.description"
                                    >
                                        {{ shorten(anime.description, 250) }}
                                    </div>
                                </div>
                            </router-link>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import { Extractors, ExtractorsEntity } from "../../plugins/api";
import { Await, StateController, util } from "../../plugins/util";

import Loading from "../../components/Loading.vue";
import ExternalLink from "../../components/ExternalLink.vue";

export default defineComponent({
    name: "Schedule-Week",
    components: {
        Loading,
        ExternalLink,
    },
    data() {
        const data: {
            schedule: StateController<
                Await<
                    ReturnType<
                        ExtractorsEntity["integrations"]["MyAnimeList"]["schedule"]
                    >
                >
            >;
            today: string;
            active: string | null;
        } = {
            schedule: util.createStateController(),
            today: new Date().toLocaleString("en-US", { weekday: "long" }),
            active: null,
        };

        return data;
    },
    mounted() {
        this.active = this.today;
        this.getSchedule();
    },
    methods: {
        async getSchedule() {
            try {
                this.schedule.state = "resolving";
                const client = await Extractors.getClient();
                const data = await client.integrations.MyAnimeList.schedule();
                this.schedule.data = data;
                this.schedule.state = "resolved";
            } catch (err) {
                this.schedule.state = "failed";
                this.$logger.emit(
                    "error",
                    `Could not fetch anime's information: ${err?.message}`
                );
            }
        },
        setActive(date: string) {
            this.active = this.active === date ? null : date;
        },
        shorten: util.shorten,
    },
});
</script>
