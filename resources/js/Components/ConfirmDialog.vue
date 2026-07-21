<script setup>
import { ref, watch } from 'vue';

const props = defineProps({
    open: {
        type: Boolean,
        default: false,
    },
    title: {
        type: String,
        default: 'Are you sure?',
    },
    message: {
        type: String,
        default: '',
    },
    confirmLabel: {
        type: String,
        default: 'Delete',
    },
    cancelLabel: {
        type: String,
        default: 'Cancel',
    },
    // If set, the confirm button stays disabled until this checkbox is ticked.
    checkboxLabel: {
        type: String,
        default: null,
    },
    processing: {
        type: Boolean,
        default: false,
    },
});

const emit = defineEmits(['confirm', 'cancel']);

const checked = ref(false);

watch(
    () => props.open,
    (isOpen) => {
        if (isOpen) checked.value = false;
    },
);

const canConfirm = () => !props.checkboxLabel || checked.value;
</script>

<template>
    <div
        v-if="open"
        class="fixed inset-0 z-40 flex items-center justify-center bg-black/50 px-4 backdrop-blur-sm"
    >
        <div
            class="w-full max-w-sm rounded-lg border p-6 shadow-2xl"
            style="background-color: var(--surface-raised); border-color: var(--border)"
        >
            <div class="flex h-10 w-10 items-center justify-center rounded-full" style="background-color: var(--status-parah-bg)">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-5 w-5" style="color: var(--status-parah-ink)">
                    <path d="M12 9v4M12 17h.01M10.29 3.86 1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0Z" />
                </svg>
            </div>

            <h2 class="mt-3 font-display text-lg font-bold" style="color: var(--ink)">{{ title }}</h2>
            <p class="mt-1.5 text-sm leading-relaxed" style="color: var(--ink-muted)">{{ message }}</p>

            <label
                v-if="checkboxLabel"
                class="mt-4 flex items-start gap-2.5 rounded-md border p-3 text-sm"
                style="border-color: var(--border); background-color: var(--bg); color: var(--ink)"
            >
                <input v-model="checked" type="checkbox" class="mt-0.5 h-4 w-4 shrink-0" />
                <span>{{ checkboxLabel }}</span>
            </label>

            <div class="mt-5 flex justify-end gap-3">
                <button
                    type="button"
                    class="rounded-md border px-4 py-2 text-sm font-medium transition-colors hover:opacity-70"
                    style="border-color: var(--border); color: var(--ink-muted)"
                    @click="emit('cancel')"
                >
                    {{ cancelLabel }}
                </button>
                <button
                    type="button"
                    :disabled="!canConfirm() || processing"
                    class="rounded-md px-4 py-2 text-sm font-semibold text-white transition-opacity hover:opacity-90 disabled:opacity-50"
                    style="background-color: var(--status-parah-ink)"
                    @click="emit('confirm')"
                >
                    {{ processing ? 'Deleting…' : confirmLabel }}
                </button>
            </div>
        </div>
    </div>
</template>
