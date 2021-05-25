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

            <p class="text-sm opacity-75 mt-4">Contents</p>
            <div class="mt-1 grid gap-2">
                <div v-for="chap in info.chapters" :key="chap.url">
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
                        @click="selectChapter(chap)"
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
        <p class="text-center opacity-75" v-else-if="state === 'noresult'">
            No results were found!
        </p>
    </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import api from "../plugins/api";

import PageTitle from "../components/PageTitle.vue";
import Loading from "../components/Loading.vue";
import ExternalLink from "../components/ExternalLink.vue";
import MangaPager from "../components/MangaPager.vue";

export default defineComponent({
    components: {
        PageTitle,
        Loading,
        ExternalLink,
        MangaPager,
    },
    data() {
        const data: {
            state: "pending" | "loading" | "noresult" | "result";
            info: any;
            plugin: string | null;
            link: string | null;
            selected: any;
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

            this.state = "loading";
            const { data, err } = await api.manga.extractors.info(
                this.plugin,
                this.link
            );
            if (err) {
                this.state = "noresult";
                return this.$logger.emit(
                    "error",
                    `Could not fetch anime's information: ${err}`
                );
            }

            this.state = "result";
            this.info = data;
            this.refreshRpc();
        },
        selectChapter(chapter: any) {
            this.selected = chapter;
            if (this.selected) {
                api.rpc({
                    details: "Currently reading",
                    state: `${this.info.title} (Vol. ${
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
        refreshRpc() {
            api.rpc({
                details: "Viewing chapters and volumes of",
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
        },
    },
});
</script>
