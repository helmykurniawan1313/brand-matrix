<script setup>
import { computed, ref } from 'vue';
import AppLayout from '../../Layouts/AppLayout.vue';
import SearchableSelect from '../../Components/SearchableSelect.vue';
import SingleMonthPicker from '../../Components/SingleMonthPicker.vue';
import { useToast } from '../../composables/useToast';

defineOptions({ layout: AppLayout });

const toast = useToast();

const props = defineProps({
    accountDepartmentEmployees: {
        type: Array,
        default: () => [],
    },
    months: {
        type: Array,
        default: () => [],
    },
});

const pmOptions = props.accountDepartmentEmployees.map((employee) => ({ id: employee.id, name: employee.name }));

const sources = [
    { value: 'cycles', label: 'Cycles', hint: 'Growth / Visibility / Engagement / Health scores per cycle' },
    { value: 'performances', label: 'Reels / Video', hint: 'Post-level Views H+7 performance records' },
    { value: 'content_insights', label: 'Content Insights', hint: 'Viewers & Interactions by content type' },
    { value: 'employees', label: 'Employees', hint: 'PM / Conceptor / Editor roster' },
];

const month = ref(props.months.length ? props.months[props.months.length - 1] : '');
const pmFilter = ref('');
const selectedSources = ref(sources.map((s) => s.value));
const monthPickerOpen = ref(false);

const toggleSource = (value) => {
    selectedSources.value = selectedSources.value.includes(value)
        ? selectedSources.value.filter((v) => v !== value)
        : [...selectedSources.value, value];
};

const monthLabel = (ym) => {
    if (!ym) return '';
    const [y, m] = ym.split('-');
    return new Date(Number(y), Number(m) - 1, 1).toLocaleDateString('en-US', { month: 'long', year: 'numeric' });
};

const generating = ref(false);
const generatedPrompt = ref('');
const generateError = ref(null);

const canGenerate = computed(() => !!month.value && selectedSources.value.length > 0 && !generating.value);

const generate = async () => {
    if (!canGenerate.value) return;

    generating.value = true;
    generateError.value = null;
    generatedPrompt.value = '';

    try {
        const response = await fetch('/report-prompt/generate', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                Accept: 'application/json',
                'X-Requested-With': 'XMLHttpRequest',
                'X-XSRF-TOKEN': decodeURIComponent(
                    document.cookie.match(/XSRF-TOKEN=([^;]+)/)?.[1] ?? '',
                ),
            },
            body: JSON.stringify({
                month: month.value,
                project_manager_id: pmFilter.value || null,
                sources: selectedSources.value,
            }),
        });

        if (!response.ok) {
            const errorBody = await response.json().catch(() => null);
            const detail = errorBody?.message
                || (errorBody?.errors ? Object.values(errorBody.errors).flat().join(' ') : null);
            throw new Error(detail || `Failed to generate prompt (${response.status}).`);
        }

        const data = await response.json();
        generatedPrompt.value = data.prompt;
    } catch (e) {
        generateError.value = e.message;
    } finally {
        generating.value = false;
    }
};

const copied = ref(false);
const copyPrompt = async () => {
    try {
        await navigator.clipboard.writeText(generatedPrompt.value);
        copied.value = true;
        toast.success('Prompt copied to clipboard.');
        setTimeout(() => (copied.value = false), 2000);
    } catch {
        toast.error('Failed to copy — select and copy manually.');
    }
};
</script>

<template>
    <h1 class="font-display text-2xl font-bold tracking-tight" style="color: var(--ink)">Report Prompt Generator</h1>
    <p class="mt-1 text-sm" style="color: var(--ink-muted)">
        Builds a text prompt carrying real data from the picked scope — paste it into an AI chat (Claude, ChatGPT, etc.)
        to generate a PPTX report with charts and illustrations. No AI call happens here — this only assembles the data.
    </p>

    <div class="mt-6 grid gap-6 lg:grid-cols-[22rem_1fr]">
        <!-- Scope + checklist form -->
        <div class="rounded-lg border p-5" style="border-color: var(--border); background-color: var(--surface)">
            <h2 class="text-sm font-semibold" style="color: var(--ink)">Scope</h2>

            <div class="mt-3">
                <label class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Month</label>
                <div class="relative mt-1.5">
                    <button
                        type="button"
                        class="inline-flex w-full items-center gap-1.5 rounded-md border px-3 py-2 text-sm font-medium transition-colors hover:opacity-80"
                        :style="
                            month
                                ? 'border-color: var(--accent); background-color: var(--accent-soft); color: var(--accent)'
                                : 'border-color: var(--border); background-color: var(--bg); color: var(--ink-muted)'
                        "
                        @click="monthPickerOpen = !monthPickerOpen"
                    >
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-3.5 w-3.5 shrink-0">
                            <rect x="3" y="4" width="18" height="18" rx="2" />
                            <path d="M3 10h18M8 2v4M16 2v4" />
                        </svg>
                        <span class="truncate">{{ month ? monthLabel(month) : 'Pick a month…' }}</span>
                    </button>

                    <div v-if="monthPickerOpen" class="absolute left-0 top-full z-20 mt-2 w-64 shadow-xl">
                        <SingleMonthPicker v-model="month" :allowed-months="months" class="!max-w-none" @update:model-value="monthPickerOpen = false" />
                    </div>
                </div>
            </div>

            <div class="mt-4">
                <label class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Project Manager</label>
                <div class="mt-1.5">
                    <SearchableSelect
                        v-model="pmFilter"
                        :options="pmOptions"
                        placeholder="All PMs"
                        clearable
                        clear-label="All PMs"
                    />
                </div>
            </div>

            <h2 class="mt-5 border-t pt-4 text-sm font-semibold" style="border-color: var(--border); color: var(--ink)">Include data</h2>
            <div class="mt-3 space-y-2">
                <button
                    v-for="source in sources"
                    :key="source.value"
                    type="button"
                    class="flex w-full items-start gap-2.5 rounded-md border px-3 py-2.5 text-left transition-colors"
                    :style="
                        selectedSources.includes(source.value)
                            ? 'border-color: var(--accent); background-color: var(--accent-soft)'
                            : 'border-color: var(--border); background-color: var(--bg)'
                    "
                    @click="toggleSource(source.value)"
                >
                    <svg
                        xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"
                        class="mt-0.5 h-4 w-4 shrink-0 rounded-sm border"
                        :style="
                            selectedSources.includes(source.value)
                                ? 'border-color: var(--accent); background-color: var(--accent)'
                                : 'border-color: var(--border-strong)'
                        "
                    >
                        <path v-if="selectedSources.includes(source.value)" d="M5 12l4 4 10-10" style="color: var(--accent-ink)" />
                    </svg>
                    <span>
                        <span class="block text-sm font-medium" style="color: var(--ink)">{{ source.label }}</span>
                        <span class="block text-xs" style="color: var(--ink-muted)">{{ source.hint }}</span>
                    </span>
                </button>
            </div>

            <button
                type="button"
                class="mt-5 w-full rounded-md px-4 py-2.5 text-sm font-semibold transition-opacity hover:opacity-90 disabled:cursor-not-allowed disabled:opacity-50"
                style="background-color: var(--accent); color: var(--accent-ink)"
                :disabled="!canGenerate"
                @click="generate"
            >
                {{ generating ? 'Generating…' : 'Generate Prompt' }}
            </button>
        </div>

        <!-- Output -->
        <div class="rounded-lg border p-5" style="border-color: var(--border); background-color: var(--surface)">
            <div class="flex items-center justify-between gap-3">
                <h2 class="text-sm font-semibold" style="color: var(--ink)">Generated prompt</h2>
                <button
                    v-if="generatedPrompt"
                    type="button"
                    class="inline-flex items-center gap-1.5 rounded-md border px-3 py-1.5 text-xs font-semibold transition-colors hover:opacity-80"
                    style="border-color: var(--border); color: var(--ink)"
                    @click="copyPrompt"
                >
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-3.5 w-3.5">
                        <rect x="9" y="9" width="13" height="13" rx="2" />
                        <path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1" />
                    </svg>
                    {{ copied ? 'Copied!' : 'Copy' }}
                </button>
            </div>

            <div v-if="generateError" class="mt-4 rounded-md p-3 text-sm" style="background-color: var(--status-parah-bg); color: var(--status-parah-ink)">
                {{ generateError }}
            </div>

            <textarea
                v-if="generatedPrompt"
                readonly
                class="mt-4 h-[32rem] w-full resize-none rounded-md border p-3 font-mono text-xs leading-relaxed"
                style="border-color: var(--border); background-color: var(--bg); color: var(--ink)"
                :value="generatedPrompt"
            />

            <div
                v-else
                class="mt-4 flex h-[32rem] flex-col items-center justify-center gap-2 rounded-md border border-dashed text-center"
                style="border-color: var(--border-strong)"
            >
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" class="h-8 w-8" style="color: var(--ink-faint)">
                    <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8l-6-6z" />
                    <path d="M14 2v6h6M9 13h6M9 17h6M9 9h1" />
                </svg>
                <p class="text-sm font-medium" style="color: var(--ink)">Nothing generated yet</p>
                <p class="text-xs" style="color: var(--ink-faint)">Pick a scope and data sources, then generate.</p>
            </div>
        </div>
    </div>
</template>
