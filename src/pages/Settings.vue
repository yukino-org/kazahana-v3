<template>
    <div>
        <PageTitle title="Settings" />

        <div class="mt-6">
            <Loading
                text="Gettings settings, please wait..."
                v-if="!settings"
            />
            <div v-else>
                <div v-if="supportsUpdateChannel">
                    <p class="text-sm opacity-75">Update Channel</p>
                    <div class="select mt-1 w-full sm:w-1/3">
                        <select
                            class="capitalize"
                            @change="handleUpdateChannel($event)"
                        >
                            <option
                                v-for="chs in allowedUpdateChannels"
                                :value="chs"
                                :selected="
                                    chs === (settings.updateChannel || 'latest')
                                "
                            >
                                {{ chs }}
                            </option>
                        </select>
                    </div>
                </div>

                <div v-if="supportsSidebarPostion">
                    <p class="text-sm opacity-75 mt-4">Sidebar Position</p>
                    <div class="select mt-1 w-full sm:w-1/3">
                        <select
                            class="capitalize"
                            @change="handleSidebarPositions($event)"
                        >
                            <option
                                v-for="chs in allowedSidebarPositions"
                                :value="chs"
                                :selected="
                                    chs === (settings.sideBarPosition || 'left')
                                "
                            >
                                {{ chs }}
                            </option>
                        </select>
                    </div>
                </div>

                <div v-if="supportsPlayerWidth">
                    <p class="text-sm opacity-75 mt-4">Default Player Width</p>
                    <div class="select mt-1 w-full sm:w-1/3">
                        <select
                            class="capitalize"
                            @change="handlePlayerWidthOptions($event)"
                        >
                            <option
                                v-for="chs in allowedPlayerWidths"
                                :value="chs"
                                :selected="
                                    chs === (settings.defaultPlayerWidth || 100)
                                "
                            >
                                {{ chs }}%
                            </option>
                        </select>
                    </div>
                </div>

                <div>
                    <p class="text-sm opacity-75 mt-4">
                        Default Manga Page Width
                    </p>
                    <div class="select mt-1 w-full sm:w-1/3">
                        <select
                            class="capitalize"
                            @change="handleMangaPageWidthOptions($event)"
                        >
                            <option
                                v-for="chs in allowedPlayerWidths"
                                :value="chs"
                                :selected="
                                    chs === (settings.defaultPageWidth || 100)
                                "
                            >
                                {{ chs }}%
                            </option>
                        </select>
                    </div>
                </div>

                <div>
                    <p class="text-sm opacity-75 mt-4">Autoplay</p>
                    <div class="select mt-1 w-full sm:w-1/3">
                        <select
                            class="capitalize"
                            @change="handleAutoplayOptions($event)"
                        >
                            <option
                                v-for="chs in allowedAutoplayOptions"
                                :value="chs"
                                :selected="
                                    chs === (settings.autoPlay || 'disabled')
                                "
                            >
                                {{ chs }}
                            </option>
                        </select>
                    </div>
                </div>

                <div v-if="supportsRpc">
                    <p class="text-sm opacity-75 mt-4">Discord RPC</p>
                    <div class="select mt-1 w-full sm:w-1/3">
                        <select
                            class="capitalize"
                            @change="handleDiscordRpcOptions($event)"
                        >
                            <option
                                v-for="chs in allowedDiscordRpcOptions"
                                :value="chs"
                                :selected="
                                    chs === (settings.discordRpc || 'enabled')
                                "
                            >
                                {{ chs }}
                            </option>
                        </select>
                    </div>
                </div>

                <div v-if="supportsRpc">
                    <p class="text-sm opacity-75 mt-4">
                        Discord RPC (Privacy mode)
                    </p>
                    <div class="select mt-1 w-full sm:w-1/3">
                        <select
                            class="capitalize"
                            @change="handleDiscordRpcPrivacyOptions($event)"
                        >
                            <option
                                v-for="chs in allowedDiscordRpcOptions"
                                :value="chs"
                                :selected="
                                    chs ===
                                    (settings.discordRpcPrivacy || 'disabled')
                                "
                            >
                                {{ chs }}
                            </option>
                        </select>
                    </div>
                </div>

                <div>
                    <button
                        class="
                            mt-6
                            focus:outline-none
                            bg-red-500
                            hover:bg-red-600
                            transition
                            duration-300
                            text-white
                            px-3.5
                            py-1.5
                            rounded
                        "
                        @click.stop.prevent="resetDatabase()"
                    >
                        <Icon icon="trash" /> Reset all data
                    </button>
                </div>

                <p class="opacity-75 mt-6">
                    <Icon class="mr-1" icon="info-circle" /> Click the
                    <Icon icon="redo" /> at the top right of the screen or
                    restart app for the settings to take effect.
                </p>

                <div class="text-xs opacity-50 mt-3">
                    <p class="underline">App Information</p>
                    <p>
                        Name:
                        <b>{{ appInfo.name }}</b>
                    </p>
                    <p>
                        Platform:
                        <b class="capitalize">{{ appInfo.platform }}</b>
                    </p>
                    <p>
                        Version: <b>{{ appInfo.version }}</b>
                    </p>
                    <p>
                        Built Time: <b>{{ appInfo.builtAt }}</b>
                    </p>
                </div>
            </div>
        </div>
    </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import { Rpc, Store } from "../plugins/api";
import { constants } from "../plugins/util";

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
            allowedAutoplayOptions: string[];
            allowedPlayerWidths: number[];
            supportsUpdateChannel: boolean;
            supportsSidebarPostion: boolean;
            supportsPlayerWidth: boolean;
            supportsRpc: boolean;
            appInfo: Record<string, string>;
        } = {
            settings: null,
            allowedUpdateChannels: ["latest", "beta", "alpha"],
            allowedSidebarPositions: ["left", "right"],
            allowedDiscordRpcOptions: ["enabled", "disabled"],
            allowedAutoplayOptions: ["enabled", "disabled"],
            allowedPlayerWidths: Array(10)
                .fill(null)
                .map((x, i) => i * 10 + 10),
            supportsUpdateChannel: ["electron"].includes(app_platform),
            supportsSidebarPostion: ["electron"].includes(app_platform),
            supportsPlayerWidth: ["electron"].includes(app_platform),
            supportsRpc: ["electron"].includes(app_platform),
            appInfo: {
                name: app_name,
                platform: app_platform,
                version: app_version,
                builtAt: new Date(app_builtAt).toLocaleString(undefined, {
                    weekday: "long",
                    day: "numeric",
                    month: "long",
                    year: "numeric",
                    hour: "numeric",
                    minute: "numeric",
                    timeZoneName: "short",
                }),
            },
        };

        return data;
    },
    mounted() {
        this.getSettings();
        this.setRpc();
    },
    methods: {
        async getSettings() {
            const store = await Store.getClient();
            this.settings =
                (await store.get(constants.storeKeys.settings)) || {};
        },
        async updateSettings(key: string, value: any) {
            const store = await Store.getClient();
            const settings =
                (await store.get(constants.storeKeys.settings)) || {};
            settings[key] = value;
            await store.set(constants.storeKeys.settings, settings);
            this.settings = settings;
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
        handleAutoplayOptions(event: any) {
            const value = event.target.value;
            if (this.allowedDiscordRpcOptions.includes(value)) {
                this.updateSettings("autoPlay", value);
            }
        },
        async setRpc() {
            const rpc = await Rpc.getClient();
            rpc?.({
                details: "On settings page",
            });
        },
        async resetDatabase() {
            const store = await Store.getClient();
            const success = await store.clear();
            if (success) this.$logger.emit("success", "Cleared the database!");
            else this.$logger.emit("error", "Failed to clear the database.");
            this.getSettings();
        },
    },
});
</script>
