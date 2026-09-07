<script setup>
import { computed, reactive, ref, watch } from 'vue';
import { router, useForm } from '@inertiajs/vue3';
import AppLayout from '../../Layouts/AppLayout.vue';

import ConfirmDialog from '../../Components/ConfirmDialog.vue';
import { useToast } from '../../composables/useToast';
import { useAuth } from '../../composables/useAuth';

defineOptions({ layout: AppLayout });

const toast = useToast();
const { canEdit } = useAuth();

const props = defineProps({
    scoreBuckets: { type: Array, required: true },
    labelBuckets: { type: Array, required: true },
    scoreMetrics: { type: Array, required: true },
    labelMetrics: { type: Array, required: true },
    formulaWeights: { type: Array, required: true },
    formulaComponents: { type: Object, required: true },
});

const metricTitles = {
    growth: 'Growth Rate',
    reach: 'Reach Rate',
    view: 'View Rate',
    er_reach: 'Engagement Rate (of Reach)',
    er_follower: 'Engagement Rate (of Followers)',
    visibility: 'Visibility',
    engagement: 'Engagement',
    health: 'Health',
    views: 'Views (H+7) Status',
    followers: 'Follower Category',
    account_growth: 'Accounts Table — Growth Rate',
    views_change: 'Growth Analysis — Views Change',
    reach_change: 'Growth Analysis — Reach Change',
    engagement_change: 'Growth Analysis — Engagement Change',
};

const metricHints = {
    growth: '(end − start) / start × 100',
    reach: 'reach / end followers × 100',
    view: 'views / end followers × 100',
    er_reach: 'engagement / reach × 100',
    er_follower: 'engagement / end followers × 100',
    visibility: 'weighted average of reach score + view score',
    engagement: 'weighted average of ER-reach score + ER-follower score',
    health: 'weighted average of growth + visibility + engagement',
    views: 'raw Views H+7 count, from Performance records',
    followers: 'raw follower count, from Performance records',
    account_growth: "latest cycle's growth rate — shown on the Accounts table and Growth modal",
    views_change: '% change in Views between the two picked months, Growth Analysis panel',
    reach_change: '% change in Reach between the two picked months, Growth Analysis panel',
    engagement_change: '% change in Engagement between the two picked months, Growth Analysis panel',
};

const componentLabels = {
    reach_score: 'Reach Score',
    view_score: 'View Score',
    er_reach_score: 'ER-Reach Score',
    er_follower_score: 'ER-Follower Score',
    growth_score: 'Growth Score',
    visibility_rate: 'Visibility Rate',
    engagement_score: 'Engagement Score',
};

// Fixed rotation of status tones for tier chips/range segments — assigned by
// rank (best tier first), never by label text, so an unrecognized label
// (e.g. a custom "Good"/"Cukup" from account_growth) still gets a sensible
// best-to-worst color instead of falling back to gray.
const tierTones = [
    { bg: 'var(--status-sip-bg)', ink: 'var(--status-sip-ink)' },
    { bg: 'var(--status-bagus-bg)', ink: 'var(--status-bagus-ink)' },
    { bg: 'var(--status-cukup-bg)', ink: 'var(--status-cukup-ink)' },
    { bg: 'var(--status-kurang-bg)', ink: 'var(--status-kurang-ink)' },
    { bg: 'var(--status-parah-bg)', ink: 'var(--status-parah-ink)' },
];
const toneAt = (index) => tierTones[Math.min(index, tierTones.length - 1)];

const inputStyle = 'rounded-md border px-2.5 py-1.5 text-sm tabular-nums transition-colors focus:outline-none';
const inputSurface = 'border-color: var(--border); background-color: var(--surface-raised); color: var(--ink)';

// --- Tabs ---

const tabs = [
    { key: 'weights', label: 'Formula Weights', hint: 'How aggregates combine' },
    { key: 'scores', label: 'Score Tiers', hint: 'Rate → 0-100 score' },
    { key: 'labels', label: 'Label Tiers', hint: 'Score → status text' },
];
const activeTab = ref('weights');

const scoreBucketsByMetric = computed(() => {
    const grouped = {};
    for (const metric of props.scoreMetrics) {
        grouped[metric] = props.scoreBuckets
            .filter((b) => b.metric === metric)
            .sort((a, b) => (b.min_rate ?? -Infinity) - (a.min_rate ?? -Infinity));
    }
    return grouped;
});

const labelBucketsByMetric = computed(() => {
    const grouped = {};
    for (const metric of props.labelMetrics) {
        grouped[metric] = props.labelBuckets
            .filter((b) => b.metric === metric)
            .sort((a, b) => (b.min_score ?? -Infinity) - (a.min_score ?? -Infinity));
    }
    return grouped;
});

// --- Range-bar geometry (client-side only, purely visual) ---
// Normalizes a metric's tiers onto a 0-100% bar so gaps/overlaps in coverage
// are visible at a glance. The floor tier (min = null) always starts at 0%;
// the axis max is the highest finite tier's threshold padded by 25%, so the
// top tier still reads as a real (non-infinite) span rather than a sliver.
const rangeSegments = (tiers, minKey) => {
    const finite = tiers.map((t) => t[minKey]).filter((v) => v !== null).map(Number);
    const axisMax = finite.length ? Math.max(...finite) * 1.25 : 1;

    // tiers are sorted best-first (highest min first) — walk reversed so we
    // build segments low-to-high, each spanning from its own min up to the
    // next tier's min (or the axis max for the top tier).
    const ascending = [...tiers].reverse();
    return ascending.map((tier, i) => {
        const min = tier[minKey] === null ? 0 : Number(tier[minKey]);
        const next = ascending[i + 1];
        const max = next ? (next[minKey] === null ? axisMax : Number(next[minKey])) : axisMax;
        const startPct = axisMax > 0 ? (min / axisMax) * 100 : 0;
        const widthPct = axisMax > 0 ? Math.max(((max - min) / axisMax) * 100, 0.5) : 0;
        // Rank from the *original* best-first order so tone matches the tier list below.
        const rank = tiers.length - 1 - i;
        return { tier, startPct, widthPct, tone: toneAt(rank) };
    });
};

const scoreRangeSegments = (metric) => rangeSegments(scoreBucketsByMetric.value[metric] ?? [], 'min_rate');
const labelRangeSegments = (metric) => rangeSegments(labelBucketsByMetric.value[metric] ?? [], 'min_score');

const formatThreshold = (value) => {
    if (value === null || value === undefined) return '0';
    const n = Number(value);
    return n >= 1000 ? new Intl.NumberFormat('en-US', { notation: 'compact' }).format(n) : n;
};

// --- Score bucket editing ---

const scoreForms = reactive({});
const initScoreForm = (bucket) => {
    scoreForms[bucket.id] = useForm({ min_rate: bucket.min_rate, score: bucket.score });
};
props.scoreBuckets.forEach(initScoreForm);

// Inertia reloads props (not the whole page) after add/delete — scoreForms
// must gain an entry for any newly-added bucket and lose one for any deleted
// bucket, or the template's scoreForms[bucket.id] access throws on the next
// render (this was crashing to a white screen on every "Add tier" click).
watch(
    () => props.scoreBuckets,
    (buckets) => {
        const currentIds = new Set(buckets.map((b) => b.id));
        buckets.forEach((bucket) => {
            if (!scoreForms[bucket.id]) initScoreForm(bucket);
        });
        Object.keys(scoreForms).forEach((id) => {
            if (!currentIds.has(Number(id))) delete scoreForms[id];
        });
    },
);

const dirtyTiers = reactive({}); // bucket.id -> bool, drives the "unsaved" affordance
const markDirty = (id) => { dirtyTiers[id] = true; };

const saveScoreBucket = (bucket) => {
    scoreForms[bucket.id].put(`/score-buckets/${bucket.id}`, {
        preserveScroll: true,
        onSuccess: () => {
            dirtyTiers[bucket.id] = false;
            toast.success('Tier saved.');
        },
        onError: () => toast.error('Failed to save tier.'),
    });
};

const deleteScoreBucket = (bucket) => {
    deletingBucket.value = { kind: 'score', bucket };
};

const newScoreForms = reactive({});
props.scoreMetrics.forEach((metric) => {
    newScoreForms[metric] = useForm({ metric, min_rate: null, score: 0 });
});
const showNewScoreRow = reactive({});

const addScoreBucket = (metric) => {
    newScoreForms[metric].post('/score-buckets', {
        preserveScroll: true,
        onSuccess: () => {
            newScoreForms[metric].reset();
            showNewScoreRow[metric] = false;
            toast.success('Tier added.');
        },
        onError: () => toast.error('Failed to add tier.'),
    });
};

// --- Label bucket editing ---

const labelForms = reactive({});
const initLabelForm = (bucket) => {
    labelForms[bucket.id] = useForm({ min_score: bucket.min_score, label: bucket.label });
};
props.labelBuckets.forEach(initLabelForm);

// Same reasoning as scoreForms above — keep labelForms in sync with whatever
// bucket list Inertia hands back after add/delete.
watch(
    () => props.labelBuckets,
    (buckets) => {
        const currentIds = new Set(buckets.map((b) => b.id));
        buckets.forEach((bucket) => {
            if (!labelForms[bucket.id]) initLabelForm(bucket);
        });
        Object.keys(labelForms).forEach((id) => {
            if (!currentIds.has(Number(id))) delete labelForms[id];
        });
    },
);

const saveLabelBucket = (bucket) => {
    labelForms[bucket.id].put(`/label-buckets/${bucket.id}`, {
        preserveScroll: true,
        onSuccess: () => {
            dirtyTiers[bucket.id] = false;
            toast.success('Tier saved.');
        },
        onError: () => toast.error('Failed to save tier.'),
    });
};

const deleteLabelBucket = (bucket) => {
    deletingBucket.value = { kind: 'label', bucket };
};

// Shared delete confirmation for both score and label bucket tiers

const deletingBucket = ref(null);
const deletingBucketProcessing = ref(false);

const cancelDeleteBucket = () => { deletingBucket.value = null; };

const confirmDeleteBucket = () => {
    if (!deletingBucket.value) return;
    const { kind, bucket } = deletingBucket.value;
    const url = kind === 'score' ? `/score-buckets/${bucket.id}` : `/label-buckets/${bucket.id}`;
    deletingBucketProcessing.value = true;

    router.delete(url, {
        preserveScroll: true,
        onSuccess: () => {
            toast.success('Tier deleted.');
            deletingBucket.value = null;
        },
        onError: () => toast.error('Failed to delete tier.'),
        onFinish: () => { deletingBucketProcessing.value = false; },
    });
};

const newLabelForms = reactive({});
props.labelMetrics.forEach((metric) => {
    newLabelForms[metric] = useForm({ metric, min_score: null, label: '' });
});
const showNewLabelRow = reactive({});

const addLabelBucket = (metric) => {
    newLabelForms[metric].post('/label-buckets', {
        preserveScroll: true,
        onSuccess: () => {
            newLabelForms[metric].reset();
            showNewLabelRow[metric] = false;
            toast.success('Tier added.');
        },
        onError: () => toast.error('Failed to add tier.'),
    });
};

// --- Formula weight editing ---

const weightForms = reactive({});
Object.entries(props.formulaComponents).forEach(([aggregate, components]) => {
    const initial = {};
    components.forEach((component) => {
        const existing = props.formulaWeights.find((w) => w.aggregate === aggregate && w.component === component);
        initial[component] = existing ? Number(existing.weight) : Number((1 / components.length).toFixed(4));
    });
    weightForms[aggregate] = useForm({ weights: initial });
});

const weightSum = (aggregate) => Object.values(weightForms[aggregate].weights).reduce((sum, w) => sum + (Number(w) || 0), 0);

const normalizedPercent = (aggregate, component) => {
    const sum = weightSum(aggregate);
    const value = Number(weightForms[aggregate].weights[component]) || 0;
    if (sum <= 0) return 0;
    return Math.round((value / sum) * 1000) / 10;
};

const weightTone = (index) => toneAt(index);

const saveWeights = (aggregate) => {
    weightForms[aggregate].put(`/formula-weights/${aggregate}`, {
        preserveScroll: true,
        onSuccess: () => toast.success('Weights saved.'),
        onError: () => toast.error('Failed to save weights.'),
    });
};
</script>

<template>
    <div class="flex flex-wrap items-start justify-between gap-4">
        <div>
            <h1 class="font-display text-2xl font-bold tracking-tight" style="color: var(--ink)">Scoring Buckets</h1>
            <p class="mt-1 max-w-2xl text-sm" style="color: var(--ink-muted)">
                Tune how raw metrics become scores and labels across the app — changes apply the next time a
                dashboard page loads.
            </p>
        </div>
    </div>

    <!-- Segmented tab bar -->
    <div class="mt-6 inline-flex gap-1 rounded-lg border p-1" style="border-color: var(--border); background-color: var(--surface)">
        <button
            v-for="tab in tabs"
            :key="tab.key"
            type="button"
            class="rounded-md px-4 py-2 text-left text-sm font-semibold transition-colors"
            :style="
                activeTab === tab.key
                    ? 'background-color: var(--accent); color: var(--accent-ink)'
                    : 'background-color: transparent; color: var(--ink-muted)'
            "
            @click="activeTab = tab.key"
        >
            {{ tab.label }}
            <span
                class="block text-[10px] font-normal normal-case tracking-normal"
                :style="activeTab === tab.key ? 'color: var(--accent-ink); opacity: 0.85' : 'color: var(--ink-faint)'"
            >
                {{ tab.hint }}
            </span>
        </button>
    </div>

    <!-- ============ FORMULA WEIGHTS ============ -->
    <div v-if="activeTab === 'weights'" class="mt-6">
        <p class="max-w-2xl text-sm" style="color: var(--ink-muted)">
            Adjust how much each component contributes to an aggregate. Weights don't need to sum to 1 — they're
            normalized automatically, so entering 2 and 1 behaves the same as 0.67 and 0.33.
        </p>

        <div class="mt-5 grid gap-5 lg:grid-cols-3">
            <section
                v-for="aggregate in Object.keys(formulaComponents)"
                :key="aggregate"
                class="rounded-xl border p-5 shadow-sm"
                style="border-color: var(--border); background-color: var(--surface)"
            >
                <h3 class="font-display text-sm font-bold" style="color: var(--ink)">{{ metricTitles[aggregate] }}</h3>
                <p class="mt-0.5 font-mono text-xs" style="color: var(--ink-faint)">{{ metricHints[aggregate] }}</p>

                <!-- Stacked proportion bar — visualizes the normalized split at a glance -->
                <div class="mt-4 flex h-2.5 overflow-hidden rounded-full" style="background-color: var(--bg)">
                    <div
                        v-for="(component, i) in formulaComponents[aggregate]"
                        :key="component"
                        class="h-full transition-all"
                        :style="`width: ${normalizedPercent(aggregate, component)}%; background-color: ${weightTone(i).ink}`"
                        :title="`${componentLabels[component]}: ${normalizedPercent(aggregate, component)}%`"
                    />
                </div>

                <div class="mt-4 space-y-2">
                    <div
                        v-for="(component, i) in formulaComponents[aggregate]"
                        :key="component"
                        class="flex items-center gap-2 rounded-md border px-3 py-2"
                        style="border-color: var(--border); background-color: var(--bg)"
                    >
                        <span class="h-2 w-2 shrink-0 rounded-full" :style="`background-color: ${weightTone(i).ink}`" />
                        <span class="flex-1 text-sm" style="color: var(--ink)">{{ componentLabels[component] }}</span>
                        <input
                            v-model.number="weightForms[aggregate].weights[component]"
                            type="number"
                            step="0.01"
                            min="0"
                            :disabled="!canEdit"
                            :class="inputStyle"
                            :style="inputSurface"
                            class="w-20 disabled:opacity-60"
                        />
                        <span class="w-12 shrink-0 text-right text-xs font-semibold tabular-nums" style="color: var(--ink-faint)">
                            {{ normalizedPercent(aggregate, component) }}%
                        </span>
                    </div>
                </div>

                <p v-if="weightForms[aggregate].errors.weights" class="mt-2 text-xs" style="color: var(--status-parah-ink)">
                    {{ weightForms[aggregate].errors.weights }}
                </p>

                <button
                    v-if="canEdit"
                    type="button"
                    class="mt-4 w-full rounded-md py-2 text-xs font-semibold transition-opacity hover:opacity-90 disabled:opacity-50"
                    style="background-color: var(--accent); color: var(--accent-ink)"
                    :disabled="weightForms[aggregate].processing"
                    @click="saveWeights(aggregate)"
                >
                    {{ weightForms[aggregate].processing ? 'Saving…' : 'Save weights' }}
                </button>
            </section>
        </div>
    </div>

    <!-- ============ SCORE TIERS ============ -->
    <div v-if="activeTab === 'scores'" class="mt-6">
        <p class="max-w-2xl text-sm" style="color: var(--ink-muted)">
            Each tier fires when a metric's rate is at or above its minimum — the highest matching tier wins. The
            bar below each metric shows tier coverage across its real range; a gap means some values fall through
            to score 0.
        </p>

        <div class="mt-5 grid gap-5 lg:grid-cols-2">
            <section
                v-for="metric in scoreMetrics"
                :key="metric"
                class="rounded-xl border p-5 shadow-sm"
                style="border-color: var(--border); background-color: var(--surface)"
            >
                <div class="flex items-start justify-between gap-3">
                    <div>
                        <h2 class="font-display text-sm font-bold" style="color: var(--ink)">{{ metricTitles[metric] }}</h2>
                        <p class="mt-0.5 font-mono text-xs" style="color: var(--ink-faint)">{{ metricHints[metric] }}</p>
                    </div>
                    <span
                        class="shrink-0 rounded-full px-2 py-0.5 text-[11px] font-semibold tabular-nums"
                        style="background-color: var(--accent-soft); color: var(--accent)"
                    >
                        {{ scoreBucketsByMetric[metric]?.length ?? 0 }} tiers
                    </span>
                </div>

                <!-- Range bar -->
                <div class="relative mt-4 h-7 overflow-hidden rounded-md" style="background-color: var(--bg)">
                    <div
                        v-for="seg in scoreRangeSegments(metric)"
                        :key="seg.tier.id"
                        class="absolute inset-y-0 flex items-center justify-center border-r text-[10px] font-semibold"
                        style="border-color: var(--surface)"
                        :style="`left: ${seg.startPct}%; width: ${seg.widthPct}%; background-color: ${seg.tone.bg}; color: ${seg.tone.ink}`"
                        :title="`≥ ${formatThreshold(seg.tier.min_rate)} → score ${seg.tier.score}`"
                    >
                        <span v-if="seg.widthPct > 8">{{ seg.tier.score }}</span>
                    </div>
                </div>
                <div class="mt-1 flex justify-between text-[10px] tabular-nums" style="color: var(--ink-faint)">
                    <span>0</span>
                    <span>higher →</span>
                </div>

                <div class="mt-4 space-y-2">
                    <div
                        v-for="(bucket, i) in scoreBucketsByMetric[metric]"
                        :key="bucket.id"
                        class="flex items-center gap-2 rounded-md border px-3 py-2"
                        style="border-color: var(--border); background-color: var(--bg)"
                    >
                        <span class="h-2 w-2 shrink-0 rounded-full" :style="`background-color: ${toneAt(i).ink}`" />
                        <span class="text-xs" style="color: var(--ink-faint)">≥</span>
                        <input
                            v-model.number="scoreForms[bucket.id].min_rate"
                            type="number"
                            step="0.01"
                            placeholder="floor"
                            :disabled="!canEdit"
                            :class="inputStyle"
                            :style="inputSurface"
                            class="w-20 disabled:opacity-60"
                            @input="markDirty(bucket.id)"
                        />
                        <span class="text-xs" style="color: var(--ink-faint)">→ score</span>
                        <input
                            v-model.number="scoreForms[bucket.id].score"
                            type="number"
                            step="0.01"
                            :disabled="!canEdit"
                            :class="inputStyle"
                            :style="inputSurface"
                            class="w-20 disabled:opacity-60"
                            @input="markDirty(bucket.id)"
                        />
                        <div v-if="canEdit" class="ml-auto flex items-center gap-1">
                            <button
                                type="button"
                                class="rounded-md px-2 py-1 text-xs font-semibold transition-colors"
                                :style="
                                    dirtyTiers[bucket.id]
                                        ? 'background-color: var(--accent); color: var(--accent-ink)'
                                        : 'color: var(--ink-faint)'
                                "
                                :disabled="scoreForms[bucket.id].processing"
                                @click="saveScoreBucket(bucket)"
                            >
                                Save
                            </button>
                            <button
                                type="button"
                                class="flex h-6 w-6 items-center justify-center rounded-md text-xs transition-colors hover:opacity-70"
                                style="color: var(--status-parah-ink)"
                                aria-label="Delete tier"
                                @click="deleteScoreBucket(bucket)"
                            >
                                ✕
                            </button>
                        </div>
                    </div>

                    <button
                        v-if="canEdit && !showNewScoreRow[metric]"
                        type="button"
                        class="flex w-full items-center justify-center gap-1.5 rounded-md border border-dashed py-2 text-xs font-semibold transition-colors hover:opacity-70"
                        style="border-color: var(--border-strong); color: var(--accent)"
                        @click="showNewScoreRow[metric] = true"
                    >
                        + Add tier
                    </button>

                    <div
                        v-if="canEdit && showNewScoreRow[metric]"
                        class="flex items-center gap-2 rounded-md border border-dashed px-3 py-2"
                        style="border-color: var(--accent)"
                    >
                        <span class="text-xs" style="color: var(--ink-faint)">≥</span>
                        <input
                            v-model.number="newScoreForms[metric].min_rate"
                            type="number"
                            step="0.01"
                            placeholder="floor"
                            :class="inputStyle"
                            :style="inputSurface"
                            class="w-20"
                        />
                        <span class="text-xs" style="color: var(--ink-faint)">→ score</span>
                        <input
                            v-model.number="newScoreForms[metric].score"
                            type="number"
                            step="0.01"
                            :class="inputStyle"
                            :style="inputSurface"
                            class="w-20"
                        />
                        <div class="ml-auto flex items-center gap-2">
                            <button
                                type="button"
                                class="text-xs font-semibold transition-colors hover:opacity-70"
                                style="color: var(--accent)"
                                :disabled="newScoreForms[metric].processing"
                                @click="addScoreBucket(metric)"
                            >
                                Add
                            </button>
                            <button
                                type="button"
                                class="text-xs font-medium transition-colors hover:opacity-70"
                                style="color: var(--ink-faint)"
                                @click="showNewScoreRow[metric] = false"
                            >
                                Cancel
                            </button>
                        </div>
                    </div>
                </div>
            </section>
        </div>
    </div>

    <!-- ============ LABEL TIERS ============ -->
    <div v-if="activeTab === 'labels'" class="mt-6">
        <p class="max-w-2xl text-sm" style="color: var(--ink-muted)">
            Maps an aggregate score (or, for a few metrics, a raw count) to the status text shown throughout the
            app — the same "highest minimum wins" rule as Score Tiers.
        </p>

        <div class="mt-5 grid gap-5 lg:grid-cols-3">
            <section
                v-for="metric in labelMetrics"
                :key="metric"
                class="rounded-xl border p-5 shadow-sm"
                style="border-color: var(--border); background-color: var(--surface)"
            >
                <div class="flex items-start justify-between gap-3">
                    <div>
                        <h2 class="font-display text-sm font-bold" style="color: var(--ink)">{{ metricTitles[metric] }}</h2>
                        <p class="mt-0.5 font-mono text-xs leading-snug" style="color: var(--ink-faint)">{{ metricHints[metric] }}</p>
                    </div>
                    <span
                        class="shrink-0 rounded-full px-2 py-0.5 text-[11px] font-semibold tabular-nums"
                        style="background-color: var(--accent-soft); color: var(--accent)"
                    >
                        {{ labelBucketsByMetric[metric]?.length ?? 0 }} tiers
                    </span>
                </div>

                <!-- Range bar -->
                <div class="relative mt-4 h-7 overflow-hidden rounded-md" style="background-color: var(--bg)">
                    <div
                        v-for="seg in labelRangeSegments(metric)"
                        :key="seg.tier.id"
                        class="absolute inset-y-0 flex items-center justify-center overflow-hidden border-r px-1 text-[10px] font-semibold whitespace-nowrap"
                        style="border-color: var(--surface)"
                        :style="`left: ${seg.startPct}%; width: ${seg.widthPct}%; background-color: ${seg.tone.bg}; color: ${seg.tone.ink}`"
                        :title="`≥ ${formatThreshold(seg.tier.min_score)} → ${seg.tier.label}`"
                    >
                        <span v-if="seg.widthPct > 10">{{ seg.tier.label }}</span>
                    </div>
                </div>

                <div class="mt-4 space-y-2">
                    <div
                        v-for="(bucket, i) in labelBucketsByMetric[metric]"
                        :key="bucket.id"
                        class="flex items-center gap-2 rounded-md border px-3 py-2"
                        style="border-color: var(--border); background-color: var(--bg)"
                    >
                        <span class="h-2 w-2 shrink-0 rounded-full" :style="`background-color: ${toneAt(i).ink}`" />
                        <span class="text-xs" style="color: var(--ink-faint)">≥</span>
                        <input
                            v-model.number="labelForms[bucket.id].min_score"
                            type="number"
                            step="0.01"
                            placeholder="floor"
                            :disabled="!canEdit"
                            :class="inputStyle"
                            :style="inputSurface"
                            class="w-16 disabled:opacity-60"
                            @input="markDirty(bucket.id)"
                        />
                        <input
                            v-model="labelForms[bucket.id].label"
                            type="text"
                            :disabled="!canEdit"
                            :class="inputStyle"
                            :style="inputSurface"
                            class="w-24 disabled:opacity-60"
                            @input="markDirty(bucket.id)"
                        />
                        <div v-if="canEdit" class="ml-auto flex items-center gap-1">
                            <button
                                type="button"
                                class="rounded-md px-2 py-1 text-xs font-semibold transition-colors"
                                :style="
                                    dirtyTiers[bucket.id]
                                        ? 'background-color: var(--accent); color: var(--accent-ink)'
                                        : 'color: var(--ink-faint)'
                                "
                                :disabled="labelForms[bucket.id].processing"
                                @click="saveLabelBucket(bucket)"
                            >
                                Save
                            </button>
                            <button
                                type="button"
                                class="flex h-6 w-6 items-center justify-center rounded-md text-xs transition-colors hover:opacity-70"
                                style="color: var(--status-parah-ink)"
                                aria-label="Delete tier"
                                @click="deleteLabelBucket(bucket)"
                            >
                                ✕
                            </button>
                        </div>
                    </div>

                    <button
                        v-if="canEdit && !showNewLabelRow[metric]"
                        type="button"
                        class="flex w-full items-center justify-center gap-1.5 rounded-md border border-dashed py-2 text-xs font-semibold transition-colors hover:opacity-70"
                        style="border-color: var(--border-strong); color: var(--accent)"
                        @click="showNewLabelRow[metric] = true"
                    >
                        + Add tier
                    </button>

                    <div
                        v-if="canEdit && showNewLabelRow[metric]"
                        class="flex items-center gap-2 rounded-md border border-dashed px-3 py-2"
                        style="border-color: var(--accent)"
                    >
                        <span class="text-xs" style="color: var(--ink-faint)">≥</span>
                        <input
                            v-model.number="newLabelForms[metric].min_score"
                            type="number"
                            step="0.01"
                            placeholder="floor"
                            :class="inputStyle"
                            :style="inputSurface"
                            class="w-16"
                        />
                        <input
                            v-model="newLabelForms[metric].label"
                            type="text"
                            placeholder="Label"
                            :class="inputStyle"
                            :style="inputSurface"
                            class="w-24"
                        />
                        <div class="ml-auto flex items-center gap-2">
                            <button
                                type="button"
                                class="text-xs font-semibold transition-colors hover:opacity-70"
                                style="color: var(--accent)"
                                :disabled="newLabelForms[metric].processing"
                                @click="addLabelBucket(metric)"
                            >
                                Add
                            </button>
                            <button
                                type="button"
                                class="text-xs font-medium transition-colors hover:opacity-70"
                                style="color: var(--ink-faint)"
                                @click="showNewLabelRow[metric] = false"
                            >
                                Cancel
                            </button>
                        </div>
                    </div>
                </div>
            </section>
        </div>
    </div>

    <ConfirmDialog
        :open="!!deletingBucket"
        title="Delete this tier?"
        message="This will permanently remove this scoring tier. This cannot be undone."
        :processing="deletingBucketProcessing"
        @confirm="confirmDeleteBucket"
        @cancel="cancelDeleteBucket"
    />
</template>
