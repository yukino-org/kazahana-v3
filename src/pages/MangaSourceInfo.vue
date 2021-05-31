<template>
    <div>
        <h1 class="mb-1 text-xl font-bold text-indigo-400">
            {{ plugin || "Unknown" }}
        </h1>

        <Loading
            class="mt-8"
            v-if="['waiting', 'resolving'].includes(info.state)"
            text="Fetching information, please wait..."
        />
        <p
            class="mt-6 text-center opacity-75"
            v-else-if="info.state === 'resolved' && !info.data"
        >
            No results were found!
        </p>
        <p
            class="mt-6 text-center opacity-75"
            v-else-if="info.state === 'failed'"
        >
            Failed to fetch manga information!
        </p>
        <div v-else-if="info.state === 'resolved' && info.data">
            <PageTitle :title="info.data.title" />

            <div v-if="selected">
                <MangaPager
                    class="mt-1"
                    v-if="
                        plugin &&
                        selected.volume &&
                        selected.chapter &&
                        selected.url
                    "
                    :plugin="plugin"
                    :volume="selected.volume"
                    :chapter="selected.chapter"
                    :link="selected.url"
                />
            </div>

            <div
                class="
                    flex flex-row
                    justify-between
                    items-center
                    mt-4
                    text-sm
                    opacity-75
                "
            >
                <p>Contents</p>
                <Icon
                    class="cursor-pointer"
                    icon="sort-amount-up"
                    title="Sort"
                    @click.prevent="reverseChapters()"
                />
            </div>
            <div class="mt-1 grid gap-2">
                <div v-for="chap in info.data.chapters" :key="chap.url">
                    <div
                        class="
                            hover-pop
                            bg-gray-100
                            dark:bg-gray-800
                            px-3
                            py-1.5
                            cursor-pointer
                            rounded
                        "
                        @click.prevent="selectChapter(chap)"
                    >
                        <div>
                            <p class="text-lg">
                                <span class="font-bold">{{ chap.title }}</span>
                                <span class="ml-1 opacity-75"
                                    >(Vol. {{ chap.volume }} Chap.
                                    {{ chap.chapter }})</span
                                >
                            </p>
                            <ExternalLink
                                class="text-xs"
                                :text="`View on ${plugin}`"
                                :url="chap.url"
                            />
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import { Extractors, ExtractorsEntity, Rpc } from "../plugins/api";

import PageTitle from "../components/PageTitle.vue";
import Loading from "../components/Loading.vue";
import ExternalLink from "../components/ExternalLink.vue";
import MangaPager from "../components/MangaPager.vue";
import { Await, StateController, util } from "../plugins/util";

type SelectedEntity = Await<
    ReturnType<ExtractorsEntity["manga"][""]["getInfo"]>
>["chapters"][0];

export default defineComponent({
    components: {
        PageTitle,
        Loading,
        ExternalLink,
        MangaPager,
    },
    data() {
        const data: {
            info: StateController<
                Await<ReturnType<ExtractorsEntity["manga"][""]["getInfo"]>>
            >;
            plugin: string | null;
            link: string | null;
            selected: SelectedEntity | null;
        } = {
            info: util.createStateController(),
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
                this.info.state = "failed";
                return this.$logger.emit("error", "Invalid 'plugin' on query!");
            }
            if (!this.link) {
                this.info.state = "failed";
                return this.$logger.emit("error", "Invalid 'plugin' on query!");
            }

            try {
                this.info.state = "resolving";
                const client = await Extractors.getClient();
                const data = await client.manga[this.plugin].getInfo(this.link);
                this.info.data = data;
                this.info.state = "resolved";
                this.refreshRpc();
            } catch (err) {
                this.info.state = "failed";
                this.$logger.emit(
                    "error",
                    `Could not fetch anime's information: ${err?.message}`
                );
            }
        },
        async selectChapter(chapter: SelectedEntity) {
            this.selected = chapter;
            if (this.selected && this.info.data) {
                const rpc = await Rpc.getClient();
                rpc?.({
                    details: "Currently reading",
                    state: `${this.info.data.title} (Vol. ${
                        this.selected.volume
                    } Chap. ${this.selected.chapter}) ${
                        this.plugin ? `(${this.plugin})` : ""
                    }`,
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
        reverseChapters() {
            if (!this.info.data?.chapters) return;
            this.info.data.chapters = this.info.data.chapters.reverse();
        },
        async refreshRpc() {
            const rpc = await Rpc.getClient();
            if (this.info.data) {
                rpc?.({
                    details: "Viewing chapters and volumes of",
                    state: this.info.data.title,
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
