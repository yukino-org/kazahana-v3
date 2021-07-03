<template>
    <div
        class="
            flex flex-row
            justify-center
            flex-wrap
            items-center
            overflow-hidden
            rounded
        "
    >
        <div
            :class="[
                'flex-grow text-center cursor-pointer hover:bg-gray-100 dark:hover:bg-gray-800 dark:hover:bg-opacity-40 px-3 py-1 transition duration-200 border-b-2',
                item.id === selected
                    ? 'border-indigo-500 text-indigo-500 dark:text-indigo-400'
                    : 'border-gray-200 dark:border-gray-800',
                tabClassNames
            ]"
            v-for="item in items"
            @click.stop.prevent="!!void changeValue(item)"
        >
            {{ item.text }}
        </div>
    </div>
</template>

<script lang="ts">
import { defineComponent, PropType } from "vue";

export interface TabEntity {
    id: string;
    icon?: string | string[];
    text: string;
}

export default defineComponent({
    emits: ["tabClick"],
    props: {
        items: Array as PropType<TabEntity[]>,
        selected: String,
        tabClassNames: String as PropType<string | string[]>
    },
    methods: {
        changeValue(item: TabEntity) {
            if (item.id === this.selected) return;
            this.$emit("tabClick", item);
        }
    }
});
</script>
