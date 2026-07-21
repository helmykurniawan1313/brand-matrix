<script setup>
import { onBeforeUnmount, onMounted, ref } from 'vue';

defineProps({
    items: {
        type: Array,
        required: true,
        // [{ label, onClick, danger }]
    },
});

const open = ref(false);
const containerRef = ref(null);

const toggleOpen = () => {
    open.value = !open.value;
};

const runItem = (item) => {
    open.value = false;
    item.onClick();
};

const onClickOutside = (event) => {
    if (containerRef.value && !containerRef.value.contains(event.target)) {
        open.value = false;
    }
};

onMounted(() => document.addEventListener('click', onClickOutside));
onBeforeUnmount(() => document.removeEventListener('click', onClickOutside));
</script>

<template>
    <div ref="containerRef" class="relative inline-block" @click.stop>
        <button
            type="button"
            class="flex h-8 w-8 items-center justify-center rounded-md transition-colors hover:opacity-70"
            style="color: var(--ink-muted)"
            aria-label="Actions"
            @click="toggleOpen"
        >
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" class="h-4.5 w-4.5">
                <circle cx="12" cy="5" r="1.75" />
                <circle cx="12" cy="12" r="1.75" />
                <circle cx="12" cy="19" r="1.75" />
            </svg>
        </button>

        <div
            v-if="open"
            class="absolute right-0 z-20 mt-1 w-40 overflow-hidden rounded-md border py-1 shadow-lg"
            style="border-color: var(--border); background-color: var(--surface-raised)"
        >
            <button
                v-for="item in items"
                :key="item.label"
                type="button"
                class="block w-full px-3.5 py-2 text-left text-sm font-medium transition-colors hover:opacity-70"
                :style="item.danger ? 'color: var(--status-parah-ink)' : 'color: var(--ink)'"
                @click="runItem(item)"
            >
                {{ item.label }}
            </button>
        </div>
    </div>
</template>
