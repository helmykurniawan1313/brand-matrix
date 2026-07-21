<script setup>
import { computed, ref } from 'vue';
import { router } from '@inertiajs/vue3';
import StatusBadge from './StatusBadge.vue';

const props = defineProps({
    cycle: {
        type: Object,
        required: true,
    },
    defaultAiProvider: {
        type: String,
        default: 'groq',
    },
});

const emit = defineEmits(['close']);

const providers = [
    { value: 'groq', label: 'Groq' },
    { value: 'gemini', label: 'Gemini' },
];

const summarizing = ref(false);
const summarizeError = ref(null);
const aiSummary = ref(props.cycle.ai_summary ?? null);
const aiSummaryGeneratedAt = ref(props.cycle.ai_summary_generated_at ?? null);
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
        const response = await fetch(`/cycles/${props.cycle.id}/summarize`, {
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
                prompt: customPrompt.value || undefined,
                provider: selectedProvider.value || undefined,
            }),
        });

        const data = await response.json();

        if (!response.ok) {
            throw new Error(data.message ?? 'Failed to generate summary.');
        }

        aiSummary.value = data.ai_summary;
        aiSummaryGeneratedAt.value = data.ai_summary_generated_at;
        router.reload({ only: ['cycles'], preserveScroll: true });
    } catch (error) {
        summarizeError.value = error.message;
    } finally {
        summarizing.value = false;
    }
};

const round = (value, digits = 2) => {
    const factor = 10 ** digits;
    return Math.round(value * factor) / factor;
};

const formatDate = (value) => {
    return new Date(value).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
};

const s = computed(() => props.cycle.scores);

const inputs = computed(() => [
    { label: 'Start Followers', value: props.cycle.start_follower.toLocaleString() },
    { label: 'End Followers', value: props.cycle.end_follower.toLocaleString() },
    { label: 'Reach', value: props.cycle.reach.toLocaleString() },
    { label: 'Views', value: props.cycle.views.toLocaleString() },
    { label: 'Engagement', value: props.cycle.engagement.toLocaleString() },
]);

const rateRows = computed(() => [
    { label: 'Growth', formula: 'end − start', rate: `${s.value.growth > 0 ? '+' : ''}${s.value.growth}`, score: s.value.growth_score },
    { label: 'Growth Rate', formula: '(end − start) / start × 100', rate: `${round(s.value.growth_rate)}%`, score: s.value.growth_score },
    { label: 'Reach Rate', formula: 'reach / end followers', rate: `${round(s.value.reach_rate / 100)}`, score: s.value.reach_score },
    { label: 'View Rate', formula: 'views / end followers', rate: `${round(s.value.view_rate / 100)}`, score: s.value.view_score },
    { label: 'ER (of Reach)', formula: 'engagement / reach × 100', rate: `${round(s.value.er_reach_rate)}%`, score: s.value.er_reach_score },
    { label: 'ER (of Followers)', formula: 'engagement / end followers × 100', rate: `${round(s.value.er_follower_rate)}%`, score: s.value.er_follower_score },
]);

const pdfUrl = computed(() => `/cycles/${props.cycle.id}/pdf`);

const aggregateRows = computed(() => [
    {
        label: 'Visibility',
        formula: 'weighted average of Reach Score + View Score',
        rate: round(s.value.visibility_rate),
        badge: s.value.visibility_label,
    },
    {
        label: 'Engagement',
        formula: 'weighted average of ER-Reach Score + ER-Follower Score',
        rate: round(s.value.engagement_score),
        badge: s.value.engagement_label,
    },
    {
        label: 'Health',
        formula: 'weighted average of Growth + Visibility + Engagement',
        rate: round(s.value.health_rate),
        badge: s.value.health_label,
    },
]);
</script>

<template>
    <div
        class="fixed inset-0 z-10 flex items-center justify-center bg-black/50 px-4 backdrop-blur-sm"
        data-modal-backdrop
    >
        <div
            class="max-h-[85vh] w-full max-w-2xl overflow-y-auto rounded-lg border p-6 shadow-2xl"
            style="background-color: var(--surface-raised); border-color: var(--border)"
        >
            <div class="flex items-start justify-between gap-4">
                <div>
                    <h2 class="font-display text-lg font-bold" style="color: var(--ink)">
                        {{ cycle.account?.name }}
                    </h2>
                    <p class="mt-0.5 text-sm" style="color: var(--ink-muted)">
                        {{ formatDate(cycle.cycle_start_date) }} – {{ formatDate(cycle.cycle_end_date) }}
                    </p>
                </div>
                <div class="flex shrink-0 items-center gap-1">
                    <a
                        :href="pdfUrl"
                        class="flex h-8 w-8 items-center justify-center rounded-md transition-colors hover:opacity-70"
                        style="color: var(--ink-muted)"
                        aria-label="Download PDF"
                    >
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-5 w-5">
                            <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4M7 10l5 5 5-5M12 15V3" />
                        </svg>
                    </a>
                    <button
                        type="button"
                        class="flex h-8 w-8 items-center justify-center rounded-md transition-colors hover:opacity-70"
                        style="color: var(--ink-muted)"
                        aria-label="Close"
                        @click="emit('close')"
                    >
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-5 w-5">
                            <path d="M18 6 6 18M6 6l12 12" />
                        </svg>
                    </button>
                </div>
            </div>

            <!-- Raw inputs -->
            <div class="mt-5 grid grid-cols-2 gap-3 sm:grid-cols-5">
                <div
                    v-for="item in inputs"
                    :key="item.label"
                    class="rounded-md border px-3 py-2"
                    style="border-color: var(--border); background-color: var(--bg)"
                >
                    <p class="text-[11px] font-medium uppercase tracking-wide" style="color: var(--ink-faint)">
                        {{ item.label }}
                    </p>
                    <p class="mt-0.5 font-display text-base font-bold tabular-nums" style="color: var(--ink)">
                        {{ item.value }}
                    </p>
                </div>
            </div>

            <!-- Rate metrics -->
            <div class="mt-6">
                <h3 class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">
                    Rate Metrics
                </h3>
                <div class="mt-2 overflow-hidden rounded-md border" style="border-color: var(--border)">
                    <table class="min-w-full">
                        <tbody>
                            <tr
                                v-for="(row, index) in rateRows"
                                :key="row.label"
                                :style="index > 0 ? 'border-top: 1px solid var(--border)' : ''"
                            >
                                <td class="px-3 py-2.5">
                                    <p class="text-sm font-medium" style="color: var(--ink)">{{ row.label }}</p>
                                    <p class="font-mono text-[11px]" style="color: var(--ink-faint)">{{ row.formula }}</p>
                                </td>
                                <td class="px-3 py-2.5 text-right text-sm tabular-nums" style="color: var(--ink-muted)">
                                    {{ row.rate }}
                                </td>
                                <td class="px-3 py-2.5 text-right">
                                    <span
                                        class="inline-flex min-w-[3rem] justify-center rounded-md px-2 py-1 text-sm font-semibold tabular-nums"
                                        style="background-color: var(--accent-soft); color: var(--accent)"
                                    >
                                        {{ row.score }}
                                    </span>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Aggregate scores -->
            <div class="mt-6">
                <h3 class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">
                    Aggregate Scores
                </h3>
                <div class="mt-2 grid grid-cols-1 gap-2 sm:grid-cols-3">
                    <div
                        v-for="row in aggregateRows"
                        :key="row.label"
                        class="rounded-md border p-3"
                        style="border-color: var(--border); background-color: var(--bg)"
                    >
                        <div class="flex items-center justify-between">
                            <p class="text-sm font-semibold" style="color: var(--ink)">{{ row.label }}</p>
                            <StatusBadge v-if="row.badge" :status="row.badge" />
                        </div>
                        <p class="mt-1 font-display text-xl font-bold tabular-nums" style="color: var(--ink)">
                            {{ row.rate }}
                        </p>
                        <p class="mt-0.5 font-mono text-[11px]" style="color: var(--ink-faint)">{{ row.formula }}</p>
                    </div>
                </div>
            </div>

            <!-- AI summary -->
            <div class="mt-6">
                <div class="flex items-center justify-between">
                    <h3 class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">
                        AI Summary
                    </h3>
                    <div class="flex items-center gap-1.5">
                        <span class="text-[11px]" style="color: var(--ink-faint)">Provider</span>
                        <select
                            v-model="selectedProvider"
                            class="rounded-md border py-1 pl-2 pr-6 text-xs transition-colors focus:outline-none"
                            style="border-color: var(--border); background-color: var(--surface); color: var(--ink)"
                        >
                            <option v-for="option in providers" :key="option.value" :value="option.value">
                                {{ option.label }}
                            </option>
                        </select>
                    </div>
                </div>

                <div class="mt-2 flex items-start gap-2">
                    <input
                        v-model="customPrompt"
                        type="text"
                        placeholder="Optional: add custom instructions (e.g. focus on engagement, write for a client email)…"
                        maxlength="500"
                        class="flex-1 rounded-md border px-3 py-2 text-sm transition-colors focus:outline-none"
                        style="border-color: var(--border); background-color: var(--surface); color: var(--ink)"
                        @keydown.enter="summarize"
                    />
                    <button
                        type="button"
                        class="inline-flex shrink-0 items-center gap-1.5 rounded-md px-3 py-2 text-xs font-semibold transition-opacity hover:opacity-90 disabled:opacity-50"
                        style="background-color: var(--accent); color: var(--accent-ink)"
                        :disabled="summarizing"
                        @click="summarize"
                    >
                        <svg
                            v-if="summarizing"
                            class="h-3.5 w-3.5 animate-spin"
                            xmlns="http://www.w3.org/2000/svg"
                            viewBox="0 0 24 24"
                            fill="none"
                        >
                            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" />
                            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v4a4 4 0 00-4 4H4z" />
                        </svg>
                        <svg v-else xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-3.5 w-3.5">
                            <path d="M12 3v3M12 18v3M3 12h3M18 12h3M5.6 5.6l2.1 2.1M16.3 16.3l2.1 2.1M5.6 18.4l2.1-2.1M16.3 7.7l2.1-2.1" />
                        </svg>
                        {{ summarizing ? 'Summarizing…' : aiSummary ? 'Regenerate' : 'Summarize by AI' }}
                    </button>
                </div>

                <p v-if="summarizeError" class="mt-2 text-sm" style="color: var(--status-parah-ink)">
                    {{ summarizeError }}
                </p>

                <div
                    v-if="aiSummary"
                    class="mt-2 rounded-md border p-3"
                    style="border-color: var(--border); background-color: var(--bg)"
                >
                    <p class="text-sm leading-relaxed" style="color: var(--ink)">{{ aiSummary }}</p>
                    <p v-if="aiSummaryGeneratedAt" class="mt-2 text-[11px]" style="color: var(--ink-faint)">
                        Generated {{ formatDateTime(aiSummaryGeneratedAt) }}
                    </p>
                </div>
                <p v-else-if="!summarizeError" class="mt-2 text-sm" style="color: var(--ink-faint)">
                    No summary yet. Click "Summarize by AI" to generate one.
                </p>
            </div>
        </div>
    </div>
</template>
