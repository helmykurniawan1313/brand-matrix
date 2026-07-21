<script setup>
import { onBeforeUnmount, onMounted, ref } from 'vue';

const props = defineProps({
    modelValue: {
        type: Array,
        required: true,
    },
    options: {
        type: Array,
        required: true,
    },
    placeholder: {
        type: String,
        default: 'Select…',
    },
});

const emit = defineEmits(['update:modelValue']);

const containerRef = ref(null);
const open = ref(false);

const toggleOpen = () => {
    open.value = !open.value;
};

const toggleOption = (option) => {
    const next = props.modelValue.includes(option)
        ? props.modelValue.filter((v) => v !== option)
        : [...props.modelValue, option];
    emit('update:modelValue', next);
};

const removeOption = (option) => {
    emit('update:modelValue', props.modelValue.filter((v) => v !== option));
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
    <div ref="containerRef" class="relative">
        <button
            type="button"
            class="flex w-full min-h-[2.5rem] items-center justify-between gap-2 rounded-md border px-2 py-1.5 text-left text-sm transition-colors focus:outline-none focus:ring-2"
            style="border-color: var(--border); background-color: var(--surface); color: var(--ink)"
            @click="toggleOpen"
        >
            <div class="flex flex-1 flex-wrap gap-1.5">
                <span v-if="modelValue.length === 0" class="px-1 py-0.5" style="color: var(--ink-faint)">
                    {{ placeholder }}
                </span>
                <span
                    v-for="option in modelValue"
                    :key="option"
                    class="inline-flex items-center gap-1 rounded px-2 py-0.5 text-xs font-medium"
                    style="background-color: var(--accent-soft); color: var(--accent)"
                >
                    {{ option }}
                    <span
                        role="button"
                        tabindex="0"
                        class="flex h-3.5 w-3.5 items-center justify-center rounded-full transition-opacity hover:opacity-70"
                        @click.stop="removeOption(option)"
                    >
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" class="h-2.5 w-2.5">
                            <path d="M18 6 6 18M6 6l12 12" />
                        </svg>
                    </span>
                </span>
            </div>
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-4 w-4 shrink-0" style="color: var(--ink-faint)">
                <path d="m6 9 6 6 6-6" />
            </svg>
        </button>

        <div
            v-if="open"
            class="absolute z-20 mt-1 w-full overflow-hidden rounded-md border shadow-lg"
            style="border-color: var(--border); background-color: var(--surface-raised)"
        >
            <ul class="max-h-52 overflow-y-auto py-1">
                <li
                    v-for="option in options"
                    :key="option"
                    class="flex cursor-pointer items-center justify-between px-3 py-2 text-sm transition-colors hover:opacity-80"
                    :style="
                        modelValue.includes(option)
                            ? 'background-color: var(--accent-soft); color: var(--accent)'
                            : 'color: var(--ink)'
                    "
                    @click="toggleOption(option)"
                >
                    {{ option }}
                    <svg v-if="modelValue.includes(option)" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" class="h-4 w-4">
                        <path d="M20 6 9 17l-5-5" />
                    </svg>
                </li>
                <li v-if="options.length === 0" class="px-3 py-2 text-sm" style="color: var(--ink-faint)">
                    No options.
                </li>
            </ul>
        </div>
    </div>
</template>
