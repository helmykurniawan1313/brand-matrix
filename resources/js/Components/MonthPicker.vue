<script setup>
import { computed, onBeforeUnmount, onMounted, ref, watch } from 'vue';

const props = defineProps({
    // 'YYYY-MM' or 'all'
    modelValue: {
        type: String,
        default: 'all',
    },
    // Months ('YYYY-MM') that actually have data — used only to label the trigger; all months stay clickable.
    availableMonths: {
        type: Array,
        default: () => [],
    },
});

const emit = defineEmits(['update:modelValue']);

const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

const open = ref(false);
const root = ref(null);

const initialYear = () => {
    if (props.modelValue && props.modelValue !== 'all') {
        return Number(props.modelValue.split('-')[0]);
    }
    return new Date().getFullYear();
};

const viewYear = ref(initialYear());

watch(() => props.modelValue, () => {
    if (props.modelValue && props.modelValue !== 'all') {
        viewYear.value = initialYear();
    }
});

const prevYear = () => {
    viewYear.value -= 1;
};

const nextYear = () => {
    viewYear.value += 1;
};

const keyFor = (month) => `${viewYear.value}-${String(month).padStart(2, '0')}`;

const isSelected = (month) => keyFor(month) === props.modelValue;

const selectMonth = (month) => {
    emit('update:modelValue', keyFor(month));
    open.value = false;
};

const selectAllTime = () => {
    emit('update:modelValue', 'all');
    open.value = false;
};

const formatMonth = (ym) => new Date(`${ym}-01T00:00:00`).toLocaleDateString('en-US', { month: 'long', year: 'numeric' });

const triggerLabel = computed(() => (props.modelValue === 'all' || !props.modelValue ? 'All Time' : formatMonth(props.modelValue)));

const onClickOutside = (event) => {
    if (root.value && !root.value.contains(event.target)) {
        open.value = false;
    }
};

onMounted(() => document.addEventListener('mousedown', onClickOutside));
onBeforeUnmount(() => document.removeEventListener('mousedown', onClickOutside));
</script>

<template>
    <div ref="root" class="relative">
        <button
            type="button"
            class="flex w-full items-center justify-between gap-2 rounded-md border px-3 py-2 text-sm transition-colors focus:outline-none"
            style="border-color: var(--border); background-color: var(--surface); color: var(--ink)"
            @click="open = !open"
        >
            {{ triggerLabel }}
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-4 w-4 shrink-0" style="color: var(--ink-faint)">
                <path d="m6 9 6 6 6-6" />
            </svg>
        </button>

        <div
            v-if="open"
            class="absolute right-0 z-20 mt-1 w-64 rounded-lg border p-4 shadow-lg"
            style="border-color: var(--border); background-color: var(--surface)"
        >
            <button
                type="button"
                class="w-full rounded-md px-3 py-2 text-left text-sm font-medium transition-colors"
                :style="
                    modelValue === 'all'
                        ? 'background-color: var(--accent); color: var(--accent-ink)'
                        : 'color: var(--ink)'
                "
                @click="selectAllTime"
            >
                All Time
            </button>

            <div class="mt-3 flex items-center justify-between border-t pt-3" style="border-color: var(--border)">
                <button
                    type="button"
                    class="flex h-7 w-7 items-center justify-center rounded-md transition-colors hover:opacity-70"
                    style="color: var(--ink-muted)"
                    aria-label="Previous year"
                    @click="prevYear"
                >
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-4 w-4">
                        <path d="m15 18-6-6 6-6" />
                    </svg>
                </button>
                <p class="font-display text-sm font-bold" style="color: var(--ink)">{{ viewYear }}</p>
                <button
                    type="button"
                    class="flex h-7 w-7 items-center justify-center rounded-md transition-colors hover:opacity-70"
                    style="color: var(--ink-muted)"
                    aria-label="Next year"
                    @click="nextYear"
                >
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-4 w-4">
                        <path d="m9 18 6-6-6-6" />
                    </svg>
                </button>
            </div>

            <div class="mt-3 grid grid-cols-4 gap-1.5">
                <button
                    v-for="(name, index) in monthNames"
                    :key="name"
                    type="button"
                    class="rounded-md px-2 py-2 text-sm font-medium transition-colors"
                    :style="
                        isSelected(index + 1)
                            ? 'background-color: var(--accent); color: var(--accent-ink)'
                            : 'color: var(--ink)'
                    "
                    @click="selectMonth(index + 1)"
                >
                    {{ name }}
                </button>
            </div>
        </div>
    </div>
</template>
