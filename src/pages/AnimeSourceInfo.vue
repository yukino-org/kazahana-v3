<template>
    <div>
        <h1 class="mb-1 text-xl font-bold text-indigo-400">
            {{ plugin || "Unknown" }}
        </h1>
        <Loading
            class="mt-8"
            v-if="state === 'pending' || state === 'loading'"
            text="Fetching information, please wait..."
        />
        <div v-else-if="state === 'result' && info">
            <PageTitle :title="info.title" />

            <div v-if="selected">
                <AnimePlayer
                    class="mt-1"
                    v-if="selected.episode && plugin && selected.url"
                    :episode="selected.episode"
                    :plugin="plugin"
                    :link="selected.url"
                />
                <div
                    class="
                        mt-4
                        flex flex-row
                        justify-center
                        items-center
                        flex-wrap
                        gap-2
                    "
                >
                    <button
                        class="
                            bg-indigo-500
                            hover:bg-indigo-600
                            transition
                            duration-300
                            px-3
                            py-1
                            rounded
                            focus:outline-none
                        "
                        @click.prevent="prevEpisode()"
                    >
                        <Icon class="mr-1 opacity-75" icon="caret-left" />
                        Previous Episode
                    </button>
                    <button
                        class="
                            bg-indigo-500
                            hover:bg-indigo-600
                            transition
                            duration-300
                            px-3
                            py-1
                            rounded
                            focus:outline-none
                        "
                        @click.prevent="nextEpisode()"
                    >
                        Next Episode
                        <Icon class="ml-1 opacity-75" icon="caret-right" />
                    </button>
                </div>
            </div>

            <div>
                <p class="text-sm opacity-75 mt-4">Episodes</p>
                <div
                    class="
                        mt-1
                        grid grid-cols-2
                        md:grid-cols-3
                        lg:grid-cols-4
                        gap-2
                        items-center
                    "
                >
                    <div
                        class="col-span-1"
                        v-for="ep in info.episodes"
                        :key="ep.url"
                    >
                        <div
                            class="
                                hover-pop
                                bg-gray-100
                                dark:bg-gray-800
                                text-center
                                p-1.5
                                cursor-pointer
                                rounded
                            "
                            @click.prevent="selectEpisode(ep)"
                        >
                            <p>
                                Episode <b>{{ ep.episode }}</b>
                            </p>
                            <ExternalLink
                                class="text-xs"
                                :text="`View on ${plugin}`"
                                :url="ep.url"
                            />
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <p class="text-center opacity-75" v-else-if="state === 'noresult'">
            No results were found!
        </p>
    </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import { Extractors, ExtractorsEntity, Rpc } from "../plugins/api";
import { Await } from "../plugins/util";

import PageTitle from "../components/PageTitle.vue";
import Loading from "../components/Loading.vue";
import ExternalLink from "../components/ExternalLink.vue";
import AnimePlayer from "../components/AnimePlayer.vue";

interface SelectedEntity {
    episode: string;
    url: string;
}

export default defineComponent({
    components: {
        PageTitle,
        Loading,
        ExternalLink,
        AnimePlayer,
    },
    data() {
        const data: {
            state: "pending" | "loading" | "noresult" | "result";
            info: Await<
                ReturnType<ExtractorsEntity["anime"][""]["getInfo"]>
            > | null;
            plugin: string | null;
            link: string | null;
            selected: SelectedEntity | null;
        } = {
            state: "pending",
            info: null,
            plugin:
                typeof this.$route.query.plugin === "string"
                    ? this.$route.query.plugin
                    : null,
            link:
                typeof this.$route.query.url === "string"
                    ? this.$route.query.url
                    : null,
            selected: null,
        };

        return data;
    },
    mounted() {
        this.getInfo();
    },
    methods: {
        async getInfo() {
            if (!this.plugin) {
                this.state = "noresult";
                return this.$logger.emit("error", "Invalid 'plugin' on query!");
            }
            if (!this.link) {
                this.state = "noresult";
                return this.$logger.emit("error", "Invalid 'plugin' on query!");
            }

            try {
                this.state = "loading";
                const client = await Extractors.getClient();
                const data = await client.anime[this.plugin].getInfo(this.link);
                this.state = "result";
                this.info = data;
                this.refreshRpc();
            } catch (err) {
                this.state = "noresult";
                this.$logger.emit(
                    "error",
                    `Could not fetch anime's information: ${err}`
                );
            }
        },
        async selectEpisode(ep: SelectedEntity) {
            this.selected = ep;
            if (this.selected && this.info) {
                const rpc = await Rpc.getClient();
                rpc?.({
                    details: "Currently watching",
                    state: `${this.info.title} (Episode ${
                        this.selected.episode
                    }) ${this.plugin ? `(${this.plugin})` : ""}`,
                    buttons: this.link
                        ? [
                              {
                                  label: "View",
                                  url: this.link,
                              },
                          ]
                        : undefined,
                });
            } else {
                this.refreshRpc();
            }
        },
        prevEpisode() {
            if (!this.info || !this.selected) return;
            const cur = this.info.episodes.findIndex(
                (x) => x.episode === this.selected?.episode
            );
            if (typeof cur === "number") {
                const prev = this.info.episodes[cur - 1];
                if (prev) this.selectEpisode(prev);
            }
        },
        nextEpisode() {
            if (!this.info || !this.selected) return;
            const cur = this.info.episodes.findIndex(
                (x) => x.episode === this.selected?.episode
            );
            if (typeof cur === "number") {
                const next = this.info.episodes[cur + 1];
                if (next) this.selectEpisode(next);
            }
        },
        async refreshRpc() {
            const rpc = await Rpc.getClient();
            if (this.info) {
                rpc?.({
                    details: "Viewing episodes of",
                    state: this.info.title,
                    buttons: this.link
                        ? [
                              {
                                  label: "View",
                                  url: this.link,
                              },
                          ]
                        : undefined,
                });
            }
        },
    },
});
</script>
