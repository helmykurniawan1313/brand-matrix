<script setup>
import { ref } from 'vue';

const props = defineProps({
    filterQuery: {
        type: Object,
        required: true,
    },
    filterLabel: {
        type: String,
        default: 'none (all cycles)',
    },
    defaultAiProvider: {
        type: String,
        default: 'groq',
    },
    endpoint: {
        type: String,
        default: '/cycles-summarize',
    },
    countKey: {
        type: String,
        default: 'cycle_count',
    },
    countNoun: {
        type: String,
        default: 'cycle',
    },
});

const emit = defineEmits(['close', 'generated']);

const providers = [
    { value: 'groq', label: 'Groq' },
    { value: 'gemini', label: 'Gemini' },
];

const summarizing = ref(false);
const summarizeError = ref(null);
const result = ref(null);
const customPrompt = ref('');
const selectedProvider = ref(props.defaultAiProvider);

const formatDateTime = (value) => {
    return new Date(value).toLocaleString('en-US', {
        month: 'short',
        day: 'numeric',
        year: 'numeric',
        hour: 'numeric',
        minute: '2-digit',
    });
};

const summarize = async () => {
    summarizing.value = true;
    summarizeError.value = null;

    try {
        const response = await fetch(props.endpoint, {
            method: 'POST',
            headers: {
                Accept: 'application/json',
                'Content-Type': 'application/json',
                'X-Requested-With': 'XMLHttpRequest',
                'X-XSRF-TOKEN': decodeURIComponent(
                    document.cookie.match(/XSRF-TOKEN=([^;]+)/)?.[1] ?? '',
                ),
            },
            body: JSON.stringify({
                ...props.filterQuery,
                prompt: customPrompt.value || undefined,
                provider: selectedProvider.value || undefined,
            }),
        });

        const data = await response.json();

        if (!response.ok) {
            throw new Error(data.message ?? 'Failed to generate summary.');
        }

        result.value = data;
        emit('generated', data);
    } catch (error) {
        summarizeError.value = error.message;
    } finally {
        summarizing.value = false;
    }
};

const inputStyle =
    'mt-1 w-full rounded-md border px-3 py-2 text-sm transition-colors focus:outline-none focus:ring-2';
</script>

<template>
    <div class="fixed inset-0 z-10 flex items-center justify-center bg-black/50 px-4 backdrop-blur-sm">
        <div
            class="w-full max-w-lg rounded-lg border p-6 shadow-2xl"
            style="background-color: var(--surface-raised); border-color: var(--border)"
        >
            <div class="flex items-start justify-between gap-4">
                <h2 class="font-display text-lg font-bold" style="color: var(--ink)">Summarize with AI</h2>
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

            <p class="mt-3 rounded-md px-3 py-2 text-xs" style="background-color: var(--surface); color: var(--ink-muted)">
                Filters: {{ filterLabel }}
            </p>

            <div class="mt-4 space-y-4">
                <div>
                    <label class="block text-sm font-medium" style="color: var(--ink-muted)">Provider</label>
                    <select
                        v-model="selectedProvider"
                        :class="inputStyle"
                        style="border-color: var(--border); background-color: var(--surface); color: var(--ink)"
                    >
                        <option v-for="provider in providers" :key="provider.value" :value="provider.value">
                            {{ provider.label }}
                        </option>
                    </select>
                </div>

                <div>
                    <label class="block text-sm font-medium" style="color: var(--ink-muted)">Custom instructions (optional)</label>
                    <textarea
                        v-model="customPrompt"
                        rows="2"
                        maxlength="500"
                        placeholder="e.g. focus on engagement trend, keep it short"
                        :class="inputStyle"
                        style="border-color: var(--border); background-color: var(--surface); color: var(--ink)"
                    />
                </div>

                <button
                    type="button"
                    :disabled="summarizing"
                    class="w-full rounded-md px-4 py-2 text-sm font-semibold transition-opacity hover:opacity-90 disabled:opacity-50"
                    style="background-color: var(--accent); color: var(--accent-ink)"
                    @click="summarize"
                >
                    {{ summarizing ? 'Summarizing…' : result ? 'Regenerate' : 'Summarize' }}
                </button>

                <p v-if="summarizeError" class="text-sm" style="color: var(--status-parah-ink)">
                    {{ summarizeError }}
                </p>

                <div v-if="result" class="rounded-md border p-3" style="border-color: var(--border); background-color: var(--surface)">
                    <p class="text-sm leading-relaxed" style="color: var(--ink)">{{ result.summary }}</p>
                    <p class="mt-2 text-xs" style="color: var(--ink-faint)">
                        {{ result[countKey] }} {{ countNoun }}{{ result[countKey] === 1 ? '' : 's' }} &middot;
                        generated {{ formatDateTime(result.generated_at) }}
                    </p>
                </div>
            </div>
        </div>
    </div>
</template>
