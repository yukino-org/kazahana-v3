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
                <select
                    class="
                        capitalize
                        bg-gray-100
                        dark:bg-gray-800
                        focus:outline-none
                        px-2
                        py-1
                        mt-1
                        rounded
                        w-44
                    "
                    @change="handleUpdateChannel($event)"
                >
                    <option
                        v-for="chs in allowedUpdateChannels"
                        :value="chs"
                        :key="chs"
                        :selected="chs === (settings.updateChannel || 'latest')"
                    >
                        {{ chs }}
                    </option>
                </select>

                <p class="text-sm opacity-75 mt-4">Sidebar Position</p>
                <select
                    class="
                        capitalize
                        bg-gray-100
                        dark:bg-gray-800
                        focus:outline-none
                        px-2
                        py-1
                        mt-1
                        rounded
                        w-44
                    "
                    @change="handleSidebarPositions($event)"
                >
                    <option
                        v-for="chs in allowedSidebarPositions"
                        :value="chs"
                        :key="chs"
                        :selected="chs === (settings.sideBarPosition || 'left')"
                    >
                        {{ chs }}
                    </option>
                </select>

                <p class="text-sm opacity-75 mt-4">Discord RPC</p>
                <select
                    class="
                        capitalize
                        bg-gray-100
                        dark:bg-gray-800
                        focus:outline-none
                        px-2
                        py-1
                        mt-1
                        rounded
                        w-44
                    "
                    @change="handleDiscordRpcOptions($event)"
                >
                    <option
                        v-for="chs in allowedDiscordRpcOptions"
                        :value="chs"
                        :key="chs"
                        :selected="chs === (settings.discordRpc || 'enabled')"
                    >
                        {{ chs }}
                    </option>
                </select>

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
import api from "../plugins/api";

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
            settings: any;
            allowedUpdateChannels: string[];
            allowedSidebarPositions: string[];
            allowedDiscordRpcOptions: string[];
        } = {
            settings: null,
            allowedUpdateChannels: ["latest", "beta", "alpha"],
            allowedSidebarPositions: ["left", "right"],
            allowedDiscordRpcOptions: ["enabled", "disabled"],
        };

        return data;
    },
    mounted() {
        this.getSettings();
    },
    methods: {
        async getSettings() {
            this.settings = (await api.store.get("settings")) || {};
        },
        async updateSettings(key: string, value: any) {
            await api.store.set(`settings.${key}`, value);
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
    },
});
</script>
