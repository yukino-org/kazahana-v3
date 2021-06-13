<template>
    <div>
        <PageTitle title="About" />

        <p class="mt-6 text-lg">
            <strong>Yukino</strong> is made by <strong>Zyrouge</strong> licensed
            under <b>MIT</b>.
        </p>

        <p class="mt-6 opacity-75 text-sm">App Information</p>
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

        <p class="mt-6 opacity-75 text-sm">Need help?</p>
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
                mt-7
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
import { Rpc, ExternalLink, http } from "../plugins/api";
import { constants } from "../plugins/util";

import PageTitle from "../components/PageTitle.vue";
import Loading from "../components/Loading.vue";
import Popup from "../components/Popup.vue";

const AppInfo = {
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
};

export default defineComponent({
    name: "Home",
    components: {
        PageTitle,
        Loading,
        Popup,
    },
    data() {
        const data: {
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
        this.setRpc();
        this.getChangelogs();
    },
    methods: {
        async setRpc() {
            const rpc = await Rpc.getClient();
            rpc?.({
                details: "Viewing about page",
            });
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
