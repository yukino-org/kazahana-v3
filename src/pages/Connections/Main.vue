<template>
    <div>
        <PageTitle title="Connections" />

        <div class="mt-6 grid gap-4">
            <div
                class="bg-gray-800 rounded px-4 py-3 flex flex-row justify-center items-center flex-wrap gap-4"
                v-for="con in connections"
            >
                <div class="flex-grow flex items-center gap-3">
                    <img
                        class="w-7 h-auto rounded"
                        :src="con.image"
                        :alt="con.name"
                    />
                    <p class="text-xl font-bold">
                        {{ con.name }}
                    </p>
                </div>

                <div
                    class="
                        flex-none
                        flex flex-row
                        justify-end
                        items-center
                        flex-wrap
                        gap-2
                    "
                >
                    <template v-if="con.loggedIn">
                        <router-link
                            class="
                                focus:outline-none
                                bg-indigo-500
                                hover:bg-indigo-600
                                text-white
                                px-3.5
                                py-1.5
                                rounded
                                transition
                                duration-200
                            "
                            :to="con.route"
                        >
                            <Icon icon="user" /> View
                        </router-link>

                        <button
                            class="
                                focus:outline-none
                                bg-red-500
                                hover:bg-red-600
                                text-white
                                px-3.5
                                py-1.5
                                rounded
                                transition
                                duration-200
                            "
                            @click.stop.prevent="
                                !!void executeAndRefresh(con.logout)
                            "
                        >
                            <Icon icon="sign-out-alt" /> Disconnect
                        </button>
                    </template>

                    <template v-else>
                        <button
                            class="
                                focus:outline-none
                                bg-blue-500
                                hover:bg-blue-600
                                text-white
                                px-3.5
                                py-1.5
                                rounded
                                transition
                                duration-200
                            "
                            @click.stop.prevent="!!void openExternal(con.auth)"
                        >
                            <Icon icon="sign-in-alt" /> Connect
                        </button>
                    </template>
                </div>
            </div>
        </div>
    </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import { ExternalLink, Rpc } from "../../plugins/api";
import MyAnimeList from "../../plugins/integrations/myanimelist";
import AniList from "../../plugins/integrations/anilist";
import { constants } from "../../plugins/util";

import PageTitle from "../../components/PageTitle.vue";

interface ConnectionEntity {
    name: string;
    auth: string;
    route: string;
    loggedIn: boolean;
    image: string;
    logout(): Promise<any>;
}

export default defineComponent({
    name: "Connections-Main",
    components: {
        PageTitle
    },
    data() {
        const data: {
            connections: ConnectionEntity[];
        } = {
            connections: []
        };

        return data;
    },
    mounted() {
        this.getConnections();
        this.setRpc();
    },
    methods: {
        async getConnections() {
            this.connections = [];

            const MyAnimeListConn: Omit<ConnectionEntity, "name" | "route"> = {
                auth: await MyAnimeList.auth.getOauthURL(),
                loggedIn: MyAnimeList.isLoggedIn(),
                image: constants.assets.images.myAnimeListLogo,
                logout: MyAnimeList.logout
            };

            this.connections.push({
                name: "MyAnimeList (Anime)",
                route: "/connections/myanimelist/anime",
                ...MyAnimeListConn
            });

            this.connections.push({
                name: "MyAnimeList (Manga)",
                route: "/connections/myanimelist/manga",
                ...MyAnimeListConn
            });

            const AniListConn: Omit<ConnectionEntity, "name" | "route"> = {
                auth: await AniList.auth.getOauthURL(),
                loggedIn: AniList.isLoggedIn(),
                image: constants.assets.images.aniListLogo,
                logout: AniList.logout
            };

            this.connections.push({
                name: "AniList (Anime)",
                route: "/connections/anilist/anime",
                ...AniListConn
            });

            this.connections.push({
                name: "AniList (Manga)",
                route: "/connections/anilist/manga",
                ...AniListConn
            });
        },
        async setRpc() {
            const rpc = await Rpc.getClient();
            rpc?.({
                details: "Viewing their connections"
            });
        },
        async openExternal(url: string) {
            const opener = await ExternalLink.getClient();
            opener?.(url);
        },
        async executeAndRefresh(fn: () => Promise<any>) {
            await fn();
            this.getConnections();
        }
    }
});
</script>
