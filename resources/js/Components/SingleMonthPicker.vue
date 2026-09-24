<script setup>
import { ref, watch } from 'vue';

// Picks exactly one 'YYYY-MM' month — visually identical to MonthRangePicker
// but with no "in-between" shading, since there's nothing in between a single
// pick. Used where two specific months are being compared as two points (e.g.
// "May vs Aug"), not a continuous span — a range calendar's shaded fill
// between the two picks would misleadingly imply everything in between is
// also included.
const props = defineProps({
    modelValue: {
        type: String,
        default: '',
    },
    allowedMonths: {
        type: Array,
        default: null,
    },
});

const emit = defineEmits(['update:modelValue']);

const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

const initialYear = () => {
    const [year] = (props.modelValue || '').split('-');
    if (year) return Number(year);

    if (props.allowedMonths?.length) {
        const [latestYear] = [...props.allowedMonths].sort().at(-1).split('-');
        return Number(latestYear);
    }

    return new Date().getFullYear();
};

const viewYear = ref(initialYear());

watch(
    () => props.modelValue,
    () => {
        if (!props.modelValue) return;
        viewYear.value = initialYear();
    },
);

const prevYear = () => {
    viewYear.value -= 1;
};

const nextYear = () => {
    viewYear.value += 1;
};

const keyFor = (month) => `${viewYear.value}-${String(month).padStart(2, '0')}`;

const isSelected = (month) => keyFor(month) === props.modelValue;

const isAllowed = (month) => !props.allowedMonths || props.allowedMonths.includes(keyFor(month));

const selectMonth = (month) => {
    if (!isAllowed(month)) return;

    const key = keyFor(month);
    emit('update:modelValue', key === props.modelValue ? '' : key);
};
</script>

<template>
    <div class="w-full rounded-lg border p-4" style="border-color: var(--border); background-color: var(--surface)">
        <div class="flex items-center justify-between">
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

        <div class="mt-3 grid grid-cols-3 gap-2">
            <button
                v-for="(name, index) in monthNames"
                :key="name"
                type="button"
                class="rounded-md px-2 py-2.5 text-center text-sm font-medium transition-colors"
                :class="{ 'cursor-not-allowed opacity-30': !isAllowed(index + 1) }"
                :disabled="!isAllowed(index + 1)"
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
</template>
