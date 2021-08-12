<template>
    <div>
        <PageTitle title="Authentication" />

        <Loading class="mt-6" :text="msg" />
    </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import AniList from "../../../plugins/integrations/anilist";
import { StateStates } from "../../../plugins/util";

import PageTitle from "../../../components/PageTitle.vue";
import Loading from "../../../components/Loading.vue";

export default defineComponent({
    name: "Authentication",
    components: {
        PageTitle,
        Loading,
    },
    data() {
        const data: {
            state: StateStates;
            msg: string;
        } = {
            state: "waiting",
            msg: "Processing...",
        };

        return data;
    },
    mounted() {
        this.authenticate();
    },
    methods: {
        async authenticate() {
            try {
                this.state = "resolving";

                const queries = new URLSearchParams(
                    this.$route.fullPath.split("#")[1]
                );

                const access_token = queries.get("access_token");
                const token_type = queries.get("token_type");
                const expires_in = queries.get("expires_in");

                if (!access_token || !token_type || !expires_in) {
                    this.state = "failed";
                    this.msg = "Invalid authentication queries";
                    return;
                }

                await AniList.authenticate({
                    access_token,
                    token_type,
                    expires_in: +expires_in,
                });

                this.$logger.emit("success", "Authentication success!");
                this.state = "resolved";
                this.$router.push("/connections");
            } catch (err: any) {
                this.$logger.emit(
                    "error",
                    `Authentication failed: ${err?.message}`
                );
                this.state = "failed";
                this.msg = "Authentication failed";
            }
        },
    },
});
</script>
