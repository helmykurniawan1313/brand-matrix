<script setup>
import { computed, nextTick, onBeforeUnmount, onMounted, ref, watch } from 'vue';

const props = defineProps({
    modelValue: {
        type: [Number, String],
        default: '',
    },
    options: {
        type: Array,
        required: true,
    },
    placeholder: {
        type: String,
        default: 'Select…',
    },
    clearable: {
        type: Boolean,
        default: false,
    },
    clearLabel: {
        type: String,
        default: 'All',
    },
});

const emit = defineEmits(['update:modelValue', 'change']);

const containerRef = ref(null);
const searchInputRef = ref(null);
const open = ref(false);
const query = ref('');

const selectedOption = computed(() => props.options.find((o) => o.id === props.modelValue) ?? null);

const filteredOptions = computed(() => {
    if (!query.value.trim()) return props.options;
    const q = query.value.trim().toLowerCase();
    return props.options.filter((o) => o.name.toLowerCase().includes(q));
});

const toggleOpen = async () => {
    open.value = !open.value;
    if (open.value) {
        query.value = '';
        await nextTick();
        searchInputRef.value?.focus();
    }
};

const select = (option) => {
    emit('update:modelValue', option.id);
    emit('change', option.id);
    open.value = false;
};

const clear = () => {
    emit('update:modelValue', '');
    emit('change', '');
    open.value = false;
};

const onClickOutside = (event) => {
    if (containerRef.value && !containerRef.value.contains(event.target)) {
        open.value = false;
    }
};

onMounted(() => document.addEventListener('click', onClickOutside));
onBeforeUnmount(() => document.removeEventListener('click', onClickOutside));

watch(() => props.modelValue, () => {
    open.value = false;
});
</script>

<template>
    <div ref="containerRef" class="relative">
        <button
            type="button"
            class="flex w-full items-center justify-between rounded-md border px-3 py-2 text-left text-sm transition-colors focus:outline-none focus:ring-2"
            style="border-color: var(--border); background-color: var(--surface); color: var(--ink)"
            @click="toggleOpen"
        >
            <span :style="selectedOption ? '' : 'color: var(--ink-faint)'">
                {{ selectedOption ? selectedOption.name : clearable ? clearLabel : placeholder }}
            </span>
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-4 w-4 shrink-0" style="color: var(--ink-faint)">
                <path d="m6 9 6 6 6-6" />
            </svg>
        </button>

        <div
            v-if="open"
            class="absolute z-20 mt-1 w-full overflow-hidden rounded-md border shadow-lg"
            style="border-color: var(--border); background-color: var(--surface-raised)"
        >
            <div class="border-b p-2" style="border-color: var(--border)">
                <input
                    ref="searchInputRef"
                    v-model="query"
                    type="text"
                    placeholder="Search…"
                    class="w-full rounded-md border px-2.5 py-1.5 text-sm focus:outline-none"
                    style="border-color: var(--border); background-color: var(--surface); color: var(--ink)"
                    @keydown.escape="open = false"
                />
            </div>
            <ul class="max-h-52 overflow-y-auto py-1">
                <li
                    v-if="clearable"
                    class="cursor-pointer px-3 py-2 text-sm transition-colors hover:opacity-80"
                    :style="modelValue === '' ? 'background-color: var(--accent-soft); color: var(--accent)' : 'color: var(--ink-faint)'"
                    @click="clear"
                >
                    {{ clearLabel }}
                </li>
                <li
                    v-for="option in filteredOptions"
                    :key="option.id"
                    class="cursor-pointer px-3 py-2 text-sm transition-colors hover:opacity-80"
                    :style="
                        option.id === modelValue
                            ? 'background-color: var(--accent-soft); color: var(--accent)'
                            : 'color: var(--ink)'
                    "
                    @click="select(option)"
                >
                    {{ option.name }}
                </li>
                <li v-if="filteredOptions.length === 0" class="px-3 py-2 text-sm" style="color: var(--ink-faint)">
                    No matches.
                </li>
            </ul>
        </div>
    </div>
</template>
