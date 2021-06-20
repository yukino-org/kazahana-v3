<template>
    <div>
        <PageTitle title="Settings" />

        <div class="mt-6">
            <Loading
                text="Gettings settings, please wait..."
                v-if="!settings"
            />
            <div v-else>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div
                        class="col-span-1"
                        v-if="supportedSettings.updateChannel"
                    >
                        <p class="text-sm opacity-75">Update Channel</p>
                        <div class="select mt-1 w-full">
                            <select
                                class="capitalize"
                                @change="
                                    handleSettings($event, 'updateChannel')
                                "
                            >
                                <option
                                    v-for="chs in allowedValues.updateChannel"
                                    :value="chs"
                                    :selected="chs === settings.updateChannel"
                                >
                                    {{ chs }}
                                </option>
                            </select>
                        </div>
                    </div>

                    <div class="col-span-1">
                        <p class="text-sm opacity-75">Incognito Mode</p>
                        <div class="select mt-1 w-full">
                            <select
                                class="capitalize"
                                @change="handleSettings($event, 'incognito')"
                            >
                                <option
                                    v-for="chs in allowedValues.incognito"
                                    :value="chs"
                                    :selected="chs === settings.incognito"
                                >
                                    {{ chs }}
                                </option>
                            </select>
                        </div>
                    </div>

                    <div
                        class="col-span-1"
                        v-if="supportedSettings.sidebarPostion"
                    >
                        <p class="text-sm opacity-75">Sidebar Position</p>
                        <div class="select mt-1 w-full">
                            <select
                                class="capitalize"
                                @change="
                                    handleSettings($event, 'sideBarPosition')
                                "
                            >
                                <option
                                    v-for="chs in allowedValues.sideBarPosition"
                                    :value="chs"
                                    :selected="chs === settings.sideBarPosition"
                                >
                                    {{ chs }}
                                </option>
                            </select>
                        </div>
                    </div>

                    <div
                        class="col-span-1"
                        v-if="supportedSettings.playerWidth"
                    >
                        <p class="text-sm opacity-75">Default Player Width</p>
                        <div class="select mt-1 w-full">
                            <select
                                class="capitalize"
                                @change="
                                    handleSettings($event, 'defaultPlayerWidth')
                                "
                            >
                                <option
                                    v-for="chs in allowedValues.defaultPlayerWidth"
                                    :value="chs"
                                    :selected="
                                        chs === settings.defaultPlayerWidth
                                    "
                                >
                                    {{ chs }}%
                                </option>
                            </select>
                        </div>
                    </div>

                    <div class="col-span-1">
                        <p class="text-sm opacity-75">
                            Default Manga Page Width
                        </p>
                        <div class="select mt-1 w-full">
                            <select
                                class="capitalize"
                                @change="
                                    handleSettings($event, 'defaultPageWidth')
                                "
                            >
                                <option
                                    v-for="chs in allowedValues.defaultPageWidth"
                                    :value="chs"
                                    :selected="
                                        chs === settings.defaultPageWidth
                                    "
                                >
                                    {{ chs }}%
                                </option>
                            </select>
                        </div>
                    </div>

                    <div class="col-span-1">
                        <p class="text-sm opacity-75">Autoplay</p>
                        <div class="select mt-1 w-full">
                            <select
                                class="capitalize"
                                @change="handleSettings($event, 'autoPlay')"
                            >
                                <option
                                    v-for="chs in allowedValues.autoPlay"
                                    :value="chs"
                                    :selected="chs === settings.autoPlay"
                                >
                                    {{ chs }}
                                </option>
                            </select>
                        </div>
                    </div>

                    <div class="col-span-1">
                        <p class="text-sm opacity-75">
                            Use system preferred theme
                        </p>
                        <div class="select mt-1 w-full">
                            <select
                                class="capitalize"
                                @change="
                                    handleSettings($event, 'autoDetectTheme')
                                "
                            >
                                <option
                                    v-for="chs in allowedValues.autoDetectTheme"
                                    :value="chs"
                                    :selected="chs === settings.autoDetectTheme"
                                >
                                    {{ chs }}
                                </option>
                            </select>
                        </div>
                    </div>

                    <div
                        class="col-span-1"
                        v-if="settings.autoDetectTheme === 'disabled'"
                    >
                        <p class="text-sm opacity-75">Dark Mode</p>
                        <div class="select mt-1 w-full">
                            <select
                                class="capitalize"
                                @change="handleSettings($event, 'darkMode')"
                            >
                                <option
                                    v-for="chs in allowedValues.darkMode"
                                    :value="chs"
                                    :selected="chs === settings.darkMode"
                                >
                                    {{ chs }}
                                </option>
                            </select>
                        </div>
                    </div>

                    <div class="col-span-1" v-if="supportedSettings.rpc">
                        <p class="text-sm opacity-75">Discord RPC</p>
                        <div class="select mt-1 w-full">
                            <select
                                class="capitalize"
                                @change="handleSettings($event, 'discordRpc')"
                            >
                                <option
                                    v-for="chs in allowedValues.discordRpc"
                                    :value="chs"
                                    :selected="chs === settings.discordRpc"
                                >
                                    {{ chs }}
                                </option>
                            </select>
                        </div>
                    </div>

                    <div class="col-span-1" v-if="supportedSettings.rpc">
                        <p class="text-sm opacity-75">
                            Discord RPC (Privacy mode)
                        </p>
                        <div class="select mt-1 w-full">
                            <select
                                class="capitalize"
                                @change="
                                    handleSettings($event, 'discordRpcPrivacy')
                                "
                            >
                                <option
                                    v-for="chs in allowedValues.discordRpcPrivacy"
                                    :value="chs"
                                    :selected="
                                        chs === settings.discordRpcPrivacy
                                    "
                                >
                                    {{ chs }}
                                </option>
                            </select>
                        </div>
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
            </div>
        </div>
    </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import { Rpc, Store } from "../plugins/api";
import { constants, util } from "../plugins/util";
import {
    Settings,
    EnabledDisabled,
    EnabledDisabledType,
    TenToHundredPercent,
    TenToHundredPercentType,
    UpdateChannels,
    UpdateChannelsType,
    SideBarPosition,
    SideBarPositionType,
} from "../plugins/types";

import PageTitle from "../components/PageTitle.vue";
import Loading from "../components/Loading.vue";

export default defineComponent({
    name: "Search",
    components: {
        PageTitle,
        Loading,
    },
    data() {
        type SettingValueOfArray<T> = { [P in keyof T]: T[P][] };
        const allowedSettingsValues: SettingValueOfArray<Settings> = {
            updateChannel: UpdateChannels as any as UpdateChannelsType[],
            incognito: EnabledDisabled as any as EnabledDisabledType[],
            sideBarPosition: SideBarPosition as any as SideBarPositionType[],
            discordRpc: EnabledDisabled as any as EnabledDisabledType[],
            discordRpcPrivacy: EnabledDisabled as any as EnabledDisabledType[],
            autoDetectTheme: EnabledDisabled as any as EnabledDisabledType[],
            darkMode: EnabledDisabled as any as EnabledDisabledType[],
            autoPlay: EnabledDisabled as any as EnabledDisabledType[],
            defaultPlayerWidth:
                TenToHundredPercent as any as TenToHundredPercentType[],
            defaultPageWidth:
                TenToHundredPercent as any as TenToHundredPercentType[],
        };

        const isElectron = app_platform === "electron";
        const supportedSettings = {
            updateChannel: isElectron,
            sidebarPostion: isElectron,
            playerWidth: isElectron,
            rpc: isElectron,
        };

        const data: {
            settings: Settings | null;
            allowedValues: typeof allowedSettingsValues;
            supportedSettings: typeof supportedSettings;
        } = {
            settings: null,
            allowedValues: allowedSettingsValues,
            supportedSettings: supportedSettings,
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
            const settings: Partial<Settings> =
                (await store.get(constants.storeKeys.settings)) || {};
            this.settings = util.mergeObject(
                constants.defaults.settings,
                settings
            );
        },
        async updateSettings<T extends keyof Settings>(
            key: T,
            value: Settings[T]
        ) {
            if (!this.settings) return;

            const store = await Store.getClient();
            const settings = { ...this.settings };
            settings[key] = value;
            await store.set(constants.storeKeys.settings, settings);
            this.settings = settings;
        },
        validateSettings<T extends keyof Settings>(
            key: T,
            value: any
        ): value is Settings[T] {
            return (this.allowedValues[key] as any[]).includes(value);
        },
        async handleSettings<T extends keyof Settings>(event: any, key: T) {
            const value = event.target.value;
            if (this.validateSettings(key, value)) {
                await this.updateSettings(key, value);

                if (
                    this.settings &&
                    ["autoDetectTheme", "darkMode", "incognito"].includes(key)
                ) {
                    this.$constants.update({
                        autoDetectTheme:
                            this.settings.autoDetectTheme === "enabled",
                        isDarkTheme: this.settings.darkMode === "enabled",
                        incognito: this.settings.incognito === "enabled",
                    });
                }
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
