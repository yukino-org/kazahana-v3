<template>
    <div>
        <PageTitle title="Authentication" />

        <Loading class="mt-6" :text="msg" />
    </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import MyAnimeList from "../../../plugins/integrations/myanimelist";
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

                const code = this.$route.query.code;
                if (typeof code !== "string") {
                    this.state = "failed";
                    this.msg = "No token was found in query";
                    return;
                }

                const token = await MyAnimeList.authenticate(code);
                if (!token.success) {
                    this.$logger.emit(
                        "error",
                        `Authentication failed: ${token?.error}`
                    );
                    this.state = "failed";
                    this.msg = "Failed to retrieve token";
                    return;
                }

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
