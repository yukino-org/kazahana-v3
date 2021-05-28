<template>
    <div>
        <PageTitle title="Settings" />

        <div class="mt-6">
            <Loading
                text="Gettings settings, please wait..."
                v-if="!settings"
            />
            <div v-else>
                <p class="text-sm opacity-75">Update Channel</p>
                <div class="select mt-1 w-1/4">
                    <select
                        class="capitalize"
                        @change="handleUpdateChannel($event)"
                    >
                        <option
                            v-for="chs in allowedUpdateChannels"
                            :value="chs"
                            :key="chs"
                            :selected="
                                chs === (settings.updateChannel || 'latest')
                            "
                        >
                            {{ chs }}
                        </option>
                    </select>
                </div>

                <p class="text-sm opacity-75 mt-4">Sidebar Position</p>
                <div class="select mt-1 w-1/4">
                    <select
                        class="capitalize"
                        @change="handleSidebarPositions($event)"
                    >
                        <option
                            v-for="chs in allowedSidebarPositions"
                            :value="chs"
                            :key="chs"
                            :selected="
                                chs === (settings.sideBarPosition || 'left')
                            "
                        >
                            {{ chs }}
                        </option>
                    </select>
                </div>

                <p class="text-sm opacity-75 mt-4">Default Player Width</p>
                <div class="select mt-1 w-1/4">
                    <select
                        class="capitalize"
                        @change="handlePlayerWidthOptions($event)"
                    >
                        <option
                            v-for="chs in allowedPlayerWidths"
                            :value="chs"
                            :key="chs"
                            :selected="
                                chs === (settings.defaultPlayerWidth || 100)
                            "
                        >
                            {{ chs }}%
                        </option>
                    </select>
                </div>

                <p class="text-sm opacity-75 mt-4">Default Manga Page Width</p>
                <div class="select mt-1 w-1/4">
                    <select
                        class="capitalize"
                        @change="handleMangaPageWidthOptions($event)"
                    >
                        <option
                            v-for="chs in allowedPlayerWidths"
                            :value="chs"
                            :key="chs"
                            :selected="
                                chs === (settings.defaultPageWidth || 100)
                            "
                        >
                            {{ chs }}%
                        </option>
                    </select>
                </div>

                <p class="text-sm opacity-75 mt-4">Discord RPC</p>
                <div class="select mt-1 w-1/4">
                    <select
                        class="capitalize"
                        @change="handleDiscordRpcOptions($event)"
                    >
                        <option
                            v-for="chs in allowedDiscordRpcOptions"
                            :value="chs"
                            :key="chs"
                            :selected="
                                chs === (settings.discordRpc || 'enabled')
                            "
                        >
                            {{ chs }}
                        </option>
                    </select>
                </div>

                <p class="text-sm opacity-75 mt-4">
                    Discord RPC (Privacy mode)
                </p>
                <div class="select mt-1 w-1/4">
                    <select
                        class="capitalize"
                        @change="handleDiscordRpcPrivacyOptions($event)"
                    >
                        <option
                            v-for="chs in allowedDiscordRpcOptions"
                            :value="chs"
                            :key="chs"
                            :selected="
                                chs ===
                                (settings.discordRpcPrivacy || 'disabled')
                            "
                        >
                            {{ chs }}
                        </option>
                    </select>
                </div>

                <p class="opacity-75 mt-4">
                    <Icon class="mr-1" icon="info-circle" /> Click the
                    <Icon icon="redo" /> at the top right of the screen or
                    restart app for the settings to take effect.
                </p>
            </div>
        </div>
    </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import { Store } from "../plugins/api";

import PageTitle from "../components/PageTitle.vue";
import Loading from "../components/Loading.vue";

export default defineComponent({
    name: "Search",
    components: {
        PageTitle,
        Loading,
    },
    data() {
        const data: {
            settings: Record<string, any> | null;
            allowedUpdateChannels: string[];
            allowedSidebarPositions: string[];
            allowedDiscordRpcOptions: string[];
            allowedPlayerWidths: number[];
        } = {
            settings: null,
            allowedUpdateChannels: ["latest", "beta", "alpha"],
            allowedSidebarPositions: ["left", "right"],
            allowedDiscordRpcOptions: ["enabled", "disabled"],
            allowedPlayerWidths: Array(10)
                .fill(null)
                .map((x, i) => i * 10 + 10),
        };

        return data;
    },
    mounted() {
        this.getSettings();
    },
    methods: {
        async getSettings() {
            const store = await Store.getClient();
            this.settings = (await store.get("settings")) || {};
        },
        async updateSettings(key: string, value: any) {
            const store = await Store.getClient();
            await store.set(`settings.${key}`, value);
            this.getSettings();
        },
        handleUpdateChannel(event: any) {
            const value = event.target.value;
            if (this.allowedUpdateChannels.includes(value)) {
                this.updateSettings("updateChannel", value);
            }
        },
        handleSidebarPositions(event: any) {
            const value = event.target.value;
            if (this.allowedSidebarPositions.includes(value)) {
                this.updateSettings("sideBarPosition", value);
            }
        },
        handleDiscordRpcOptions(event: any) {
            const value = event.target.value;
            if (this.allowedDiscordRpcOptions.includes(value)) {
                this.updateSettings("discordRpc", value);
            }
        },
        handleDiscordRpcPrivacyOptions(event: any) {
            const value = event.target.value;
            if (this.allowedDiscordRpcOptions.includes(value)) {
                this.updateSettings("discordRpcPrivacy", value);
            }
        },
        handlePlayerWidthOptions(event: any) {
            const value = +event.target.value;
            if (
                value &&
                !isNaN(value) &&
                this.allowedPlayerWidths.includes(value)
            ) {
                this.updateSettings("defaultPlayerWidth", value);
            }
        },
        handleMangaPageWidthOptions(event: any) {
            const value = +event.target.value;
            if (
                value &&
                !isNaN(value) &&
                this.allowedPlayerWidths.includes(value)
            ) {
                this.updateSettings("defaultPageWidth", value);
            }
        },
    },
});
</script>
