<template>
    <div>
        <div class="flex flex-row justify-center items-center gap-4 flex-wrap">
            <div class="flex-grow flex items-center gap-3">
                <img class="w-7 h-auto rounded" :src="logo" alt="MyAnimeList" />
                <p class="text-xl font-bold">
                    MyAnimeList
                    <span class="text-xs mx-1 opacity-75" v-if="info.data"
                        >(
                        {{ info.data.my_list_status.num_episodes_watched }}/{{
                            info.data.num_episodes
                        }})</span
                    >
                </p>
            </div>

            <router-link
                class="
                    px-3
                    py-1.5
                    focus:outline-none
                    bg-blue-500
                    hover:bg-blue-600
                    transition
                    duration-200
                    rounded
                "
                to="/connections"
                v-if="!loggedIn"
                >Login</router-link
            >
            <div
                class="flex flex-row justify-center items-center gap-2"
                v-else-if="info.data"
            >
                <div class="select">
                    <select class="capitalize" @change="updateStatus($event)">
                        <option
                            v-for="status in allowedStatus"
                            :value="status"
                            :selected="
                                status === info.data.my_list_status.status
                            "
                        >
                            {{ status.replace(/_/g, " ") }}
                        </option>
                    </select>
                </div>
            </div>
        </div>
    </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import MyAnimeList, {
    AnimeEntity,
    AnimeStatus,
} from "../../plugins/integrations/myanimelist";
import { StateController, constants, util } from "../../plugins/util";

export default defineComponent({
    props: {
        id: String,
    },
    data() {
        const data: {
            loggedIn: boolean;
            logo: string;
            info: StateController<AnimeEntity>;
            allowedStatus: string[];
        } = {
            loggedIn: false,
            logo: constants.assets.images.myAnimeListLogo,
            info: util.createStateController(),
            allowedStatus: <any>AnimeStatus,
        };

        return data;
    },
    mounted() {
        this.getInfo();
    },
    methods: {
        async getInfo() {
            if (typeof this.$route.query.url !== "string") return;
            if (!MyAnimeList.isLoggedIn()) {
                this.loggedIn = false;
                return;
            }

            this.loggedIn = true;
            this.info.state = "resolving";
            if (this.id) {
                const info = await MyAnimeList.getAnime(this.id);
                if (info) {
                    this.info.state = "resolved";
                    this.info.data = info;
                } else {
                    this.info.state = "failed";
                }
            }
        },
        async updateStatus(event: any) {
            if (!this.id) return;

            const value = event.target.value;
            if (this.allowedStatus.includes(value)) {
                await MyAnimeList.updateAnime(this.id, {
                    status: <any>value,
                });
            }
        },
    },
});
</script>
