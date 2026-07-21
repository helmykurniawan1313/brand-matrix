<script setup>
import { ref, watch } from 'vue';

const props = defineProps({
    // 'YYYY-MM' or ''
    modelFrom: {
        type: String,
        default: '',
    },
    modelTo: {
        type: String,
        default: '',
    },
});

const emit = defineEmits(['update:modelFrom', 'update:modelTo']);

const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

const initialYear = () => {
    const [year] = (props.modelFrom || props.modelTo || '').split('-');
    return year ? Number(year) : new Date().getFullYear();
};

const viewYear = ref(initialYear());

watch(
    () => [props.modelFrom, props.modelTo],
    () => {
        if (!props.modelFrom && !props.modelTo) return;
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

const parseKey = (key) => {
    if (!key) return null;
    const [y, m] = key.split('-').map(Number);
    return y * 12 + (m - 1);
};

const isSelected = (month) => {
    const key = keyFor(month);
    return key === props.modelFrom || key === props.modelTo;
};

const isInRange = (month) => {
    if (!props.modelFrom || !props.modelTo) return false;
    const value = parseKey(keyFor(month));
    const from = parseKey(props.modelFrom);
    const to = parseKey(props.modelTo);
    return value > from && value < to;
};

const selectMonth = (month) => {
    const key = keyFor(month);

    if (!props.modelFrom || (props.modelFrom && props.modelTo)) {
        // Start a fresh selection.
        emit('update:modelFrom', key);
        emit('update:modelTo', '');
        return;
    }

    // One endpoint already picked — set the second, ordering low/high.
    const from = parseKey(props.modelFrom);
    const clicked = parseKey(key);

    if (clicked === from) {
        emit('update:modelFrom', '');
        emit('update:modelTo', '');
        return;
    }

    if (clicked < from) {
        emit('update:modelTo', props.modelFrom);
        emit('update:modelFrom', key);
    } else {
        emit('update:modelTo', key);
    }
};
</script>

<template>
    <div class="w-full max-w-xs rounded-lg border p-4" style="border-color: var(--border); background-color: var(--surface)">
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

        <div class="mt-3 grid grid-cols-4 gap-1.5">
            <button
                v-for="(name, index) in monthNames"
                :key="name"
                type="button"
                class="rounded-md px-2 py-2 text-sm font-medium transition-colors"
                :style="
                    isSelected(index + 1)
                        ? 'background-color: var(--accent); color: var(--accent-ink)'
                        : isInRange(index + 1)
                          ? 'background-color: var(--accent-soft); color: var(--accent)'
                          : 'color: var(--ink)'
                "
                @click="selectMonth(index + 1)"
            >
                {{ name }}
            </button>
        </div>
    </div>
</template>
