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
                        <p class="text-sm opacity-75">Auto next</p>
                        <div class="select mt-1 w-full">
                            <select
                                class="capitalize"
                                @change="handleSettings($event, 'autoNext')"
                            >
                                <option
                                    v-for="chs in allowedValues.autoNext"
                                    :value="chs"
                                    :selected="chs === settings.autoNext"
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

        <p class="mt-6 opacity-75 text-sm underline">App Information</p>
        <p>
            <span class="opacity-75 mr-1">Name:</span>
            <b>{{ appInfo.name }}</b>
        </p>
        <p>
            <span class="opacity-75 mr-1">Platform:</span>
            <b class="capitalize">{{ appInfo.platform }}</b>
        </p>
        <p>
            <span class="opacity-75 mr-1">Version:</span>
            <b>{{ appInfo.version }}</b>
        </p>
        <p>
            <span class="opacity-75 mr-1">Built Time:</span>
            <b>{{ appInfo.builtAt }}</b>
        </p>

        <p class="mt-8 opacity-75 text-sm underline">Need help?</p>
        <p>
            Checkout our
            <span
                class="
                    text-indigo-500
                    hover:text-indigo-400
                    transition
                    duration-200
                    cursor-pointer
                "
                @click.stop.prevent="!!void openURL(links.guides)"
                >guides</span
            >
            or join our
            <span
                class="
                    text-indigo-500
                    hover:text-indigo-400
                    transition
                    duration-200
                    cursor-pointer
                "
                @click.stop.prevent="!!void openURL(links.guides)"
                >Discord</span
            >.
            <br />
            Help me buy a coffee by becoming a
            <span
                class="
                    text-indigo-500
                    hover:text-indigo-400
                    transition
                    duration-200
                    cursor-pointer
                "
                @click.stop.prevent="!!void openURL(links.patreon)"
                >patron</span
            >. Donations keeps the project running!
        </p>

        <div
            class="
                mt-8
                flex flex-row
                justify-start
                items-center
                flex-wrap
                gap-2
            "
        >
            <button
                class="
                    focus:outline-none
                    text-white
                    bg-indigo-500
                    hover:bg-indigo-600
                    transition
                    duration-300
                    px-3.5
                    py-1.5
                    rounded
                "
                @click.stop.prevent="!!void openURL(links.website)"
            >
                <Icon class="mr-1" :icon="['far', 'snowflake']" /> Website
            </button>

            <button
                class="
                    focus:outline-none
                    text-white
                    bg-pink-600
                    hover:bg-pink-700
                    transition
                    duration-300
                    px-3.5
                    py-1.5
                    rounded
                "
                @click.stop.prevent="!!void openURL(links.guides)"
            >
                <Icon class="mr-1" icon="book-open" /> Guide
            </button>

            <button
                class="
                    focus:outline-none
                    text-white
                    bg-blue-700
                    hover:bg-blue-800
                    transition
                    duration-300
                    px-3.5
                    py-1.5
                    rounded
                "
                @click.stop.prevent="!!void openURL(links.discordInvite)"
            >
                <Icon class="mr-1" :icon="['fab', 'discord']" /> Discord
            </button>

            <button
                class="
                    focus:outline-none
                    text-white
                    bg-yellow-500
                    hover:bg-yellow-600
                    transition
                    duration-300
                    px-3.5
                    py-1.5
                    rounded
                "
                @click.stop.prevent="!!void openURL(links.patreon)"
            >
                <Icon class="mr-1" :icon="['fab', 'patreon']" /> Patreon
            </button>

            <button
                class="
                    focus:outline-none
                    text-white
                    bg-gray-700
                    hover:bg-gray-600
                    transition
                    duration-300
                    px-3.5
                    py-1.5
                    rounded
                "
                @click.stop.prevent="!!void openURL(links.github)"
            >
                <Icon class="mr-1" :icon="['fab', 'github']" /> GitHub
            </button>

            <button
                class="
                    focus:outline-none
                    text-white
                    bg-blue-400
                    hover:bg-blue-500
                    transition
                    duration-300
                    px-3.5
                    py-1.5
                    rounded
                "
                @click.stop.prevent="!!void toggleChangelogs()"
            >
                <Icon class="mr-1" icon="exchange-alt" /> View Changelogs
            </button>
        </div>

        <Popup :show="changelogs.open" @close="!!void toggleChangelogs()">
            <Loading
                class="px-4 py-3"
                text="Fetching changelogs, please wait..."
                v-if="!changelogs.body"
            />
            <p
                v-else-if="
                    !changelogs.body.features.length &&
                    !changelogs.body.fixes.length &&
                    !changelogs.body.refactors.length
                "
            >
                No changes were found.
            </p>
            <div class="mb-1" v-else>
                <p class="text-xl font-bold">What's new</p>
                <p class="text-xs opacity-75">v{{ appInfo.version }}</p>

                <div class="mt-3" v-if="changelogs.body.features.length">
                    <p class="text-sm opacity-75">Features</p>
                    <ul class="list-inside">
                        <li class="mt-1" v-for="m in changelogs.body.features">
                            <span class="mr-2">•</span>
                            <span
                                class="bg-gray-700 px-1 py-0.5 text-sm rounded"
                                >{{ parseChangelogMsg(m).id }}</span
                            >
                            {{ parseChangelogMsg(m).msg }}
                        </li>
                    </ul>
                </div>

                <div class="mt-3" v-if="changelogs.body.fixes.length">
                    <p class="text-sm opacity-75">Bug fixes</p>
                    <ul class="list-inside">
                        <li class="mt-1" v-for="m in changelogs.body.fixes">
                            <span class="mr-2">•</span>
                            <span
                                class="bg-gray-700 px-1 py-0.5 text-sm rounded"
                                >{{ parseChangelogMsg(m).id }}</span
                            >
                            {{ parseChangelogMsg(m).msg }}
                        </li>
                    </ul>
                </div>

                <div class="mt-3" v-if="changelogs.body.refactors.length">
                    <p class="text-sm opacity-75">Other changes</p>
                    <ul class="list-inside">
                        <li class="mt-1" v-for="m in changelogs.body.refactors">
                            <span class="mr-2">•</span>
                            <span
                                class="bg-gray-700 px-1 py-0.5 text-sm rounded"
                                >{{ parseChangelogMsg(m).id }}</span
                            >
                            {{ parseChangelogMsg(m).msg }}
                        </li>
                    </ul>
                </div>
            </div>
        </Popup>
    </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import { http, ExternalLink, Rpc, Store } from "../plugins/api";
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
import Popup from "../components/Popup.vue";

const AppInfo = {
    name: app_name,
    platform: app_platform,
    version: app_version,
    builtAt: util.prettyDate(new Date(app_builtAt)),
};

export default defineComponent({
    name: "Search",
    components: {
        PageTitle,
        Loading,
        Popup,
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
            autoNext: EnabledDisabled as any as EnabledDisabledType[],
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
            appInfo: typeof AppInfo;
            links: typeof constants.links;
            changelogs: {
                open: boolean;
                body: null | {
                    features: string[];
                    fixes: string[];
                    refactors: string[];
                };
            };
        } = {
            settings: null,
            allowedValues: allowedSettingsValues,
            supportedSettings: supportedSettings,
            appInfo: AppInfo,
            links: constants.links,
            changelogs: {
                open: false,
                body: null,
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
                    [
                        "autoDetectTheme",
                        "darkMode",
                        "incognito",
                        "sideBarPosition",
                    ].includes(key)
                ) {
                    this.$state.update({
                        autoDetectTheme:
                            this.settings.autoDetectTheme === "enabled",
                        isDarkTheme: this.settings.darkMode === "enabled",
                        incognito: this.settings.incognito === "enabled",
                        sideBar: this.settings.sideBarPosition,
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
        async openURL(url: string) {
            const opener = await ExternalLink.getClient();
            opener?.(url);
        },
        toggleChangelogs() {
            this.changelogs.open = !this.changelogs.open;
            if (this.changelogs.open && !this.changelogs.body) {
                this.getChangelogs();
            }
        },
        async getChangelogs() {
            try {
                const client = await http.getClient();
                const res = await client.get(
                    `https://api.github.com/repos/${constants.github.owner}/${constants.github.repo}/releases/tags/v${app_version}`,
                    {
                        headers: {},
                        responseType: "text",
                    }
                );

                const data = JSON.parse(res);
                const changes = (<any[]>data.assets).find(
                    (x) => x.name === "changelogs.json"
                )?.browser_download_url;

                if (changes) {
                    this.changelogs.body = JSON.parse(
                        await client.get(changes, {
                            headers: {},
                            responseType: "text",
                        })
                    );
                } else {
                    this.changelogs.body = {
                        features: [],
                        fixes: [],
                        refactors: [],
                    };
                }
            } catch (err) {}
        },
        parseChangelogMsg(text: string) {
            const [id, ...msg] = text.split(" ");
            return {
                id,
                msg: msg.join(" "),
            };
        },
    },
});
</script>
