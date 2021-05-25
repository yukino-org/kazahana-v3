<template>
    <div class="flex flex-col justify-end items-end">
        <div
            :class="[
                'text-white mb-1 px-2 py-1 rounded cursor-pointer shadow-lg flex flex-row justify-center items-center',
                getBgColor(noti.type),
            ]"
            id="log"
            @click.prevent="removeId(noti.id)"
            v-for="noti in notifications"
            :key="noti.id"
        >
            <Icon
                class="mr-1.5 opacity-75 text-lg"
                :icon="getIcon(noti.type)"
            />
            <p>{{ noti.msg }}</p>
        </div>
    </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";

let id = 0;
const genId = () => {
    id = id > 999 ? 0 : id + 1;
    return id;
};

export default defineComponent({
    data() {
        const data: {
            notifications: {
                type: string;
                msg: string;
                id: number;
            }[];
        } = {
            notifications: [],
        };

        return data;
    },
    mounted() {
        this.$logger.on((type, msg) => {
            const id = genId();
            this.notifications.push({
                type,
                msg,
                id,
            });
            setTimeout(() => {
                this.removeId(id);
            }, 5000);
        });
    },
    methods: {
        removeId(id: number) {
            const i = this.notifications.findIndex((x) => x.id === id);
            if (typeof i === "number") this.notifications.splice(i, 1);
        },
        getBgColor(type: string) {
            switch (type) {
                case "info":
                    return "bg-blue-500";

                case "error":
                    return "bg-red-500";

                case "warn":
                    return "bg-yellow-500";

                default:
                    return "bg-indigo-500";
            }
        },
        getIcon(type: string) {
            switch (type) {
                case "info":
                    return "info-circle";

                case "error":
                case "warn":
                    return "exclamation-circle";

                default:
                    return "question";
            }
        },
    },
});
</script>

<style scoped>
#log {
    animation: slidein 0.2s cubic-bezier(0.43, 0.02, 0.57, 0.97);
}

@keyframes slidein {
    from {
        transform: translateX(20.1rem);
    }

    to {
        transform: translateX(0);
    }
}
</style>
