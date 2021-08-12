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
                    <template v-for="(setting, name) in config">
                        <div
                            class="col-span-1"
                            v-if="
                                typeof setting.supported === 'function'
                                    ? setting.supported(settings)
                                    : setting.supported
                            "
                        >
                            <p class="text-sm opacity-75">{{ setting.name }}</p>

                            <select
                                class="
                                    bg-gray-100
                                    dark:bg-gray-800
                                    capitalize
                                    w-full
                                    mt-1
                                    rounded
                                    border-transparent
                                    focus:outline-none focus:ring-0
                                "
                                @change="handleSettings($event, name)"
                                v-if="setting.values"
                            >
                                <option
                                    v-for="chs in setting.values"
                                    :value="chs"
                                    :selected="chs === settings[name]"
                                >
                                    {{ setting.pretty?.(chs) || chs }}
                                </option>
                            </select>
                            <input
                                class="
                                    bg-gray-100
                                    dark:bg-gray-800
                                    capitalize
                                    w-full
                                    mt-1
                                    rounded
                                    border-transparent
                                    focus:outline-none focus:ring-0
                                "
                                :type="setting.type"
                                v-else-if="setting.type"
                                @input="handleSettings($event, name)"
                                :value="settings[name]"
                            />
                        </div>
                    </template>
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
                    <Icon class="mr-1" icon="info-circle" /> Restart the app for
                    the some settings to take effect.
                </p>
            </div>
        </div>

        <hr class="mt-6" />

        <p class="mt-6 opacity-75 text-sm underline">App Information</p>
        <p>
            <span class="opacity-75 mr-1">Name:</span>
            <b>{{ appInfo.name }}</b>
        </p>
        <p>
            <span class="opacity-75 mr-1">Platform:</span>
            <b class="capitalize">{{ appInfo.os }} ({{ appInfo.platform }})</b>
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
                                class="
                                    bg-gray-200
                                    dark:bg-gray-700
                                    px-1
                                    py-0.5
                                    text-sm
                                    rounded
                                "
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
                                class="
                                    bg-gray-200
                                    dark:bg-gray-700
                                    px-1
                                    py-0.5
                                    text-sm
                                    rounded
                                "
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
                                class="
                                    bg-gray-200
                                    dark:bg-gray-700
                                    px-1
                                    py-0.5
                                    text-sm
                                    rounded
                                "
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
    BottomBarItemsCount,
    EnabledDisabled,
    TenToHundredPercent,
    UpdateChannels,
    SideBarPosition,
    StoreKeys,
    StoreStructure,
} from "../plugins/types";

import PageTitle from "../components/PageTitle.vue";
import Loading from "../components/Loading.vue";
import Popup from "../components/Popup.vue";

const AppInfo = {
    name: app_name,
    platform: app_platform,
    os: app_os,
    version: app_version,
    builtAt: util.prettyDate(new Date(app_builtAt)),
};

type Settings = StoreStructure[StoreKeys.settings];

interface SettingsConfig<T extends keyof Settings> {
    name: string;
    validate(value: any): value is Settings[T];
    values?: Settings[T][] | Readonly<Settings[T][]>;
    type?: "number";
    supported: boolean | ((settings: Settings) => boolean);
    pretty?(value: any): any;
    transform?(value: string): any;
}

const ArrayCheck = <T>(arr: T[] | Readonly<T[]>) => {
    return (value: any): value is T => arr.includes(value);
};

export default defineComponent({
    name: "Search",
    components: {
        PageTitle,
        Loading,
        Popup,
    },
    data() {
        const config: {
            [P in keyof Settings]: SettingsConfig<P>;
        } = {
            updateChannel: {
                name: "Update Channel",
                validate: ArrayCheck(UpdateChannels),
                values: UpdateChannels,
                supported: this.$state.props.runtime.isElectron,
            },
            incognito: {
                name: "Incognito",
                validate: ArrayCheck(EnabledDisabled),
                values: EnabledDisabled,
                supported: true,
            },
            sideBarPosition: {
                name: "Sidebar Position",
                validate: ArrayCheck(SideBarPosition),
                values: SideBarPosition,
                supported: this.$state.props.runtime.isElectron,
            },
            discordRpc: {
                name: "Discord RPC",
                validate: ArrayCheck(EnabledDisabled),
                values: EnabledDisabled,
                supported: this.$state.props.runtime.isElectron,
            },
            discordRpcPrivacy: {
                name: "Discord RPC (Privacy Mode)",
                validate: ArrayCheck(EnabledDisabled),
                values: EnabledDisabled,
                supported: this.$state.props.runtime.isElectron,
            },
            autoDetectTheme: {
                name: "Use system preferred theme",
                validate: ArrayCheck(EnabledDisabled),
                values: EnabledDisabled,
                supported: true,
            },
            darkMode: {
                name: "Dark Mode",
                validate: ArrayCheck(EnabledDisabled),
                values: EnabledDisabled,
                supported: (settings) =>
                    settings.autoDetectTheme === "disabled",
            },
            autoPlay: {
                name: "Autoplay",
                validate: ArrayCheck(EnabledDisabled),
                values: EnabledDisabled,
                supported: true,
            },
            autoNext: {
                name: "Autoplay Next",
                validate: ArrayCheck(EnabledDisabled),
                values: EnabledDisabled,
                supported: true,
            },
            defaultPlayerWidth: {
                name: "Video Player Width",
                validate: ArrayCheck(TenToHundredPercent),
                values: TenToHundredPercent,
                type: "number",
                supported: this.$state.props.runtime.isElectron,
                pretty: (value) => `${value}%`,
                transform: (value) => Math.trunc(+value || 0),
            },
            defaultPageWidth: {
                name: "Manga Page Width",
                validate: ArrayCheck(TenToHundredPercent),
                values: TenToHundredPercent,
                type: "number",
                supported: true,
                pretty: (value) => `${value}%`,
                transform: (value) => Math.trunc(+value || 0),
            },
            hideBottomBarText: {
                name: "Hide Bottom Bar Text",
                validate: ArrayCheck(EnabledDisabled),
                values: EnabledDisabled,
                supported: this.$state.props.runtime.isCapacitor,
            },
            compactBottomBar: {
                name: "Compact Bottom Bar",
                validate: ArrayCheck(EnabledDisabled),
                values: EnabledDisabled,
                supported: this.$state.props.runtime.isCapacitor,
            },
            bottomBarItemsCount: {
                name: "Bottom Bar Items Count",
                validate: ArrayCheck(BottomBarItemsCount),
                values: BottomBarItemsCount,
                supported: this.$state.props.runtime.isCapacitor,
            },
            defaultSeekLength: {
                name: "Seek Duration (in seconds)",
                validate: (value): value is number =>
                    typeof value === "number" && util.isFiniteNumber(value),
                type: "number",
                supported: true,
                transform: (value) => Math.trunc(+value || 0),
            },
            skipIntroLength: {
                name: "Skip Intro Length (in seconds)",
                validate: (value): value is number =>
                    typeof value === "number" && util.isFiniteNumber(value),
                type: "number",
                supported: true,
                transform: (value) => Math.trunc(+value || 0),
            },
            defaultVolume: {
                name: "Player Volume (1 - 100)",
                validate: (value): value is number =>
                    typeof value === "number" &&
                    util.isFiniteNumber(value) &&
                    value <= 100,
                type: "number",
                transform: (value) =>
                    Math.trunc(
                        +(value.match(/[0-9]?[0-9]?[0-9]/)?.[0] || "0") || 0
                    ),
                supported: true,
            },
            videoPlayerGestures: {
                name: "Video Player Gestures",
                validate: ArrayCheck(EnabledDisabled),
                values: EnabledDisabled,
                supported: true,
            },
        };

        const data: {
            settings: Settings | null;
            config: typeof config;
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
            config,
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
            const settings = await store.get(StoreKeys.settings);

            this.settings = util.mergeObject(
                constants.defaults.settings,
                settings
            );
        },
        async handleSettings<T extends keyof Settings>(event: Event, key: T) {
            if (!this.settings) return;

            const target = event.target as HTMLInputElement | null;
            if (!target?.value) return;

            const config: SettingsConfig<T> = this.config[key] as any;
            const value = config.transform?.(target.value) || target.value;

            if (!config.validate(value))
                return (target.value = this.settings[key] as any);

            const store = await Store.getClient();
            const settings = util.mergeObject({}, this.settings);
            settings[key] = value;
            await store.set(StoreKeys.settings, settings);
            this.settings = settings;
            target.value = this.settings[key] as any;

            if (
                [
                    "autoDetectTheme",
                    "darkMode",
                    "incognito",
                    "sideBarPosition",
                    "hideBottomBarText",
                    "compactBottomBar",
                    "bottomBarItemsCount",
                ].includes(key)
            ) {
                this.$state.update({
                    autoDetectTheme:
                        this.settings.autoDetectTheme === "enabled",
                    isDarkTheme: this.settings.darkMode === "enabled",
                    incognito: this.settings.incognito === "enabled",
                    sideBar: this.settings.sideBarPosition,
                    hideBottomBarText:
                        this.settings.hideBottomBarText === "enabled",
                    compactBottomBar:
                        this.settings.compactBottomBar === "enabled",
                    bottomBarItemsCount: this.settings.bottomBarItemsCount,
                });
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
            } catch (err: any) {}
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

<style scoped>
input[type="number"]::-webkit-outer-spin-button,
input[type="number"]::-webkit-inner-spin-button {
    -webkit-appearance: none;
}
</style>
