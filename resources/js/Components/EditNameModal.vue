<script setup>
import { useForm } from '@inertiajs/vue3';

const props = defineProps({
    item: {
        type: Object,
        required: true,
    },
    title: {
        type: String,
        required: true,
    },
    url: {
        type: String,
        required: true,
    },
    label: {
        type: String,
        default: 'Name',
    },
});

const emit = defineEmits(['close', 'saved']);

const form = useForm({ name: props.item.name });

const submit = () => {
    form.put(props.url, {
        preserveScroll: true,
        onSuccess: () => emit('saved'),
    });
};
</script>

<template>
    <div class="fixed inset-0 z-10 flex items-center justify-center bg-black/50 px-4 backdrop-blur-sm">
        <div
            class="w-full max-w-md rounded-lg border p-6 shadow-2xl"
            style="background-color: var(--surface-raised); border-color: var(--border)"
        >
            <div class="flex items-start justify-between gap-4">
                <h2 class="font-display text-lg font-bold" style="color: var(--ink)">{{ title }}</h2>
                <button
                    type="button"
                    class="flex h-8 w-8 shrink-0 items-center justify-center rounded-md transition-colors hover:opacity-70"
                    style="color: var(--ink-muted)"
                    aria-label="Close"
                    @click="emit('close')"
                >
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-5 w-5">
                        <path d="M18 6 6 18M6 6l12 12" />
                    </svg>
                </button>
            </div>

            <form class="mt-5" @submit.prevent="submit">
                <label class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">
                    {{ label }}
                </label>
                <input
                    v-model="form.name"
                    type="text"
                    autofocus
                    class="mt-1.5 w-full rounded-md border px-3 py-2 text-sm transition-colors focus:outline-none"
                    style="border-color: var(--border); background-color: var(--surface); color: var(--ink)"
                />
                <p v-if="form.errors.name" class="mt-1 text-sm" style="color: var(--status-parah-ink)">
                    {{ form.errors.name }}
                </p>

                <div class="mt-6 flex justify-end gap-2">
                    <button
                        type="button"
                        class="rounded-md px-4 py-2 text-sm font-medium transition-colors hover:opacity-70"
                        style="color: var(--ink-muted)"
                        @click="emit('close')"
                    >
                        Cancel
                    </button>
                    <button
                        type="submit"
                        :disabled="form.processing"
                        class="rounded-md px-4 py-2 text-sm font-semibold transition-opacity hover:opacity-90 disabled:opacity-50"
                        style="background-color: var(--accent); color: var(--accent-ink)"
                    >
                        Save
                    </button>
                </div>
            </form>
        </div>
    </div>
</template>
