<template>
    <div class="flex flex-col justify-end items-end max-w-sm">
        <transition-group name="slidein" tag="div">
            <div v-for="noti in notifications" :key="noti.id">
                <div
                    :class="[
                        'text-white mb-1 px-2 py-1 rounded cursor-pointer shadow-lg flex flex-row justify-center items-center',
                        getBgColor(noti.type),
                    ]"
                    @click.stop.prevent="!!void removeId(noti.id)"
                >
                    <Icon
                        class="mr-1.5 opacity-75 text-lg"
                        :icon="getIcon(noti.type)"
                    />
                    <p>{{ noti.msg }}</p>
                </div>
            </div>
        </transition-group>
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
            const index = this.notifications.findIndex((x) => x.id === id);
            if (typeof index === "number" && index > -1) {
                this.notifications.splice(index, 1);
            }
        },
        getBgColor(type: string) {
            switch (type) {
                case "info":
                    return "bg-blue-500";

                case "error":
                    return "bg-red-500";

                case "warn":
                    return "bg-yellow-500";

                case "success":
                    return "bg-green-500";

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

                case "success":
                    return "check-circle";

                default:
                    return "question";
            }
        },
    },
});
</script>

<style scoped>
.slidein-enter-active {
    transform: translateX(21rem);
    transition: 0.4s ease;
}

.slidein-enter-to {
    transform: translateX(0);
}

.slidein-leave-active {
    transition: 0.4s ease;
}

.slidein-leave-to {
    opacity: 0;
    transform: translateX(21rem);
}
</style>
