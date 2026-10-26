<script setup>
import { computed, reactive, ref, watch } from 'vue';
import { router, useForm } from '@inertiajs/vue3';
import AppLayout from '../../Layouts/AppLayout.vue';

import ConfirmDialog from '../../Components/ConfirmDialog.vue';
import { useToast } from '../../composables/useToast';
import { useAuth } from '../../composables/useAuth';
import { STATUS_TONES, resolveBucketColor } from '../../utils/bucketColor';

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
    accountTiers: { type: Array, default: () => [] },
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
    visibility: 'weighted average of reach score + view score — see Formula Weights tab for current weights',
    engagement: 'weighted average of ER-reach score + ER-follower score — see Formula Weights tab for current weights',
    health: 'weighted average of growth score + visibility rate + engagement score — see Formula Weights tab for current weights',
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

// Fixed rotation of status tones — still used for Formula Weights' component
// swatches (which aren't buckets and have no stored color) and as the
// fallback for any bucket tier that has no `color` of its own yet.
const toneAt = (index) => resolveBucketColor(null, index);

// A bucket tier's own color (editable via the swatch picker below), falling
// back to rank-based rotation when unset — this replaces the old fixed
// tierTones/toneAt(rank) lookup for score/label tiers specifically.
const tierTone = (bucket, rank) => resolveBucketColor(bucket, rank);

const colorLabels = {
    sip: 'SIP', bagus: 'Bagus', cukup: 'Cukup', kurang: 'Kurang', parah: 'Parah',
};
const swatchOptions = STATUS_TONES;

const setBucketColor = (form, bucketId, token) => {
    form.color = token;
    form.custom_color_bg = null;
    form.custom_color_ink = null;
    markDirty(bucketId);
};

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

// Tier label ordering for display — smallest account size first. Any tier
// name not in this list (e.g. a custom one an admin adds later) sorts after
// the known ones, alphabetically, rather than disappearing.
const TIER_ORDER = ['Rintisan', 'Kecil', 'Menengah', 'Besar'];
const tierSortIndex = (tier) => {
    const i = TIER_ORDER.indexOf(tier);
    return i === -1 ? TIER_ORDER.length : i;
};

const platformLabels = { instagram: 'Instagram', tiktok: 'TikTok' };

// Sub-groups a metric's buckets by (platform, tier) so admins can see/edit
// one tier's threshold set at a time instead of a single flat list mixing
// every tier's rows together (e.g. "growth" went from 5 rows to 20 once
// Instagram tiering was added — ungrouped, that read as one jumbled list).
// A row with platform=null/tier=null is the global/untiered fallback bucket
// set (see MetricCalculator's 3-level fallback) and renders under "Global".
const scoreGroupsByMetric = computed(() => {
    const groups = {};
    for (const metric of props.scoreMetrics) {
        const byKey = {};
        for (const bucket of scoreBucketsByMetric.value[metric] ?? []) {
            const key = `${bucket.platform ?? ''}:${bucket.tier ?? ''}`;
            if (!byKey[key]) {
                byKey[key] = {
                    key,
                    platform: bucket.platform,
                    tier: bucket.tier,
                    label: bucket.tier
                        ? `${bucket.platform ? platformLabels[bucket.platform] ?? bucket.platform : 'All platforms'} — ${bucket.tier}`
                        : (bucket.platform ? platformLabels[bucket.platform] ?? bucket.platform : 'Global'),
                    buckets: [],
                };
            }
            byKey[key].buckets.push(bucket);
        }
        groups[metric] = Object.values(byKey).sort((a, b) => {
            const platformCmp = (a.platform ?? '').localeCompare(b.platform ?? '');
            if (platformCmp !== 0) return platformCmp;
            return tierSortIndex(a.tier) - tierSortIndex(b.tier);
        });
    }
    return groups;
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
const rangeSegments = (tiers, minKey, forms) => {
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
        // Prefer the live form's color (reflects unsaved edits) over the prop.
        const live = forms?.[tier.id] ?? tier;
        return { tier, startPct, widthPct, tone: tierTone(live, rank) };
    });
};

const scoreRangeSegments = (metric) => rangeSegments(scoreBucketsByMetric.value[metric] ?? [], 'min_rate', scoreForms);
const scoreGroupRangeSegments = (group) => rangeSegments(group.buckets, 'min_rate', scoreForms);
const labelRangeSegments = (metric) => rangeSegments(labelBucketsByMetric.value[metric] ?? [], 'min_score', labelForms);

const formatThreshold = (value) => {
    if (value === null || value === undefined) return '0';
    const n = Number(value);
    return n >= 1000 ? new Intl.NumberFormat('en-US', { notation: 'compact' }).format(n) : n;
};

// --- Score bucket editing ---

const scoreForms = reactive({});
const initScoreForm = (bucket) => {
    scoreForms[bucket.id] = useForm({
        min_rate: bucket.min_rate,
        score: bucket.score,
        color: bucket.color,
        custom_color_bg: bucket.custom_color_bg,
        custom_color_ink: bucket.custom_color_ink,
    });
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

// Keyed by `${metric}|${groupKey}` so each (metric, platform, tier) group has
// its own "add tier" row/form, instead of one shared draft per metric that
// would lose which group it belonged to once a metric has several groups.
const newScoreForms = reactive({});
const newScoreFormKey = (metric, group) => `${metric}|${group.key}`;
const ensureNewScoreForm = (metric, group) => {
    const key = newScoreFormKey(metric, group);
    if (!newScoreForms[key]) {
        newScoreForms[key] = useForm({
            metric,
            platform: group.platform ?? null,
            tier: group.tier ?? null,
            min_rate: null,
            score: 0,
        });
    }
    return newScoreForms[key];
};
const showNewScoreRow = reactive({});

const addScoreBucket = (metric, group) => {
    const key = newScoreFormKey(metric, group);
    newScoreForms[key].post('/score-buckets', {
        preserveScroll: true,
        onSuccess: () => {
            newScoreForms[key].reset();
            showNewScoreRow[key] = false;
            toast.success('Tier added.');
        },
        onError: () => toast.error('Failed to add tier.'),
    });
};

// Creating a brand-new (platform, tier) group — e.g. the first TikTok set for
// a metric — is just adding its first bucket row (score 0, no floor), which
// then shows up as its own group above once the page's props refresh.
const showNewScoreGroup = reactive({});
const newGroupDraft = reactive({});
props.scoreMetrics.forEach((metric) => {
    newGroupDraft[metric] = { platform: null, tier: null };
});

const createScoreGroup = (metric) => {
    const draft = newGroupDraft[metric];
    const form = useForm({
        metric,
        platform: draft.platform || null,
        tier: draft.tier?.trim() || null,
        min_rate: null,
        score: 0,
    });
    form.post('/score-buckets', {
        preserveScroll: true,
        onSuccess: () => {
            showNewScoreGroup[metric] = false;
            newGroupDraft[metric] = { platform: null, tier: null };
            toast.success('Group created — add its remaining tiers below.');
        },
        onError: () => toast.error('Failed to create group.'),
    });
};

// --- Label bucket editing ---

const labelForms = reactive({});
const initLabelForm = (bucket) => {
    labelForms[bucket.id] = useForm({
        min_score: bucket.min_score,
        label: bucket.label,
        color: bucket.color,
        custom_color_bg: bucket.custom_color_bg,
        custom_color_ink: bucket.custom_color_ink,
    });
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

// --- Live mini-examples ---
// Mirrors ScoreBucketResolver::resolve() (app/Services/ScoreBucketResolver.php)
// exactly: highest min (<= value) wins, null min = floor (-Infinity). Runs
// against the FORM's live values (not the original props), so edits to a
// tier's threshold/score update the example instantly, no save/reload needed.
const resolveTier = (tiers, forms, minKey, valueKey, value) => {
    let winner = null;
    let winnerMin = -Infinity;
    for (const tier of tiers) {
        const live = forms[tier.id] ?? tier;
        const rawMin = live[minKey];
        const min = rawMin === null || rawMin === undefined || rawMin === '' ? -Infinity : Number(rawMin);
        if (min > value) continue;
        if (winner === null || min > winnerMin) {
            winner = live;
            winnerMin = min;
        }
    }
    return winner ? Number(winner[valueKey]) : null;
};

// A representative rate for each score metric's example — chosen to read as
// a plausible, clean mid-range value per metric rather than one number reused
// everywhere (e.g. "7%" reads naturally for growth/view rates but not for a
// reach rate that's typically >100%).
const exampleRateByMetric = {
    growth: 7,
    reach: 120,
    view: 45,
    er_reach: 5,
    er_follower: 8,
};

const scoreExample = (metric, tiers) => {
    if (!tiers.length) return null;
    const rate = exampleRateByMetric[metric] ?? 10;
    const score = resolveTier(tiers, scoreForms, 'min_rate', 'score', rate);
    if (score === null) return null;
    return { rate, score };
};

// Health is the terminal aggregate; visibility/engagement feed into it. This
// is just a plain-language hint, not a computed dependency chain.
const feedsInto = {
    growth: 'Health',
    reach: 'Visibility',
    view: 'Visibility',
    er_reach: 'Engagement',
    er_follower: 'Engagement',
};

const scoreExampleText = (metric, tiers) => {
    const example = scoreExample(metric, tiers);
    if (!example) return null;
    const unit = metric === 'growth' || metric === 'er_reach' || metric === 'er_follower' || metric === 'view' || metric === 'reach' ? '%' : '';
    return `Example: a ${example.rate}${unit} ${metricTitles[metric].toLowerCase()} → scores ${example.score} → feeds into ${feedsInto[metric] ?? '—'}.`;
};

// Representative aggregate score for each label metric's example.
const exampleScoreByMetric = {
    visibility: 82,
    engagement: 70,
    health: 75,
    growth: 65,
    views: 50000,
    followers: 10000,
    account_growth: 7,
    views_change: 15,
    reach_change: 10,
    engagement_change: 12,
};

const labelExampleText = (metric) => {
    const tiers = labelBucketsByMetric.value[metric] ?? [];
    if (!tiers.length) return null;
    const score = exampleScoreByMetric[metric] ?? 50;
    const label = resolveTier(tiers, labelForms, 'min_score', 'label', score);
    if (label === null || label === undefined) return null;
    const noun = ['views', 'followers'].includes(metric) ? 'value' : 'score';
    return `Example: a ${noun} of ${score.toLocaleString()} → labeled ${label}.`;
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
            Each tier fires when a metric's rate is at or above its minimum — the highest matching tier wins. A
            metric scored by account size (e.g. Instagram's Growth/Reach/View/ER-Reach) shows one threshold set per
            tier below — a cycle looks up its own platform + size tier first, then falls back to a platform-wide
            set, then the global set, so a tier left blank just inherits the more general one.
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

                <div class="mt-4 space-y-5">
                    <div
                        v-for="group in scoreGroupsByMetric[metric]"
                        :key="group.key"
                        class="rounded-lg border p-3"
                        style="border-color: var(--border); background-color: var(--bg)"
                    >
                        <p class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">
                            {{ group.label }}
                        </p>

                        <!-- Range bar -->
                        <div class="relative mt-2 h-7 overflow-hidden rounded-md" style="background-color: var(--surface)">
                            <div
                                v-for="seg in scoreGroupRangeSegments(group)"
                                :key="seg.tier.id"
                                class="absolute inset-y-0 flex items-center justify-center border-r text-[10px] font-semibold"
                                style="border-color: var(--bg)"
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

                        <!-- Live worked example — recalculates as tiers below are edited -->
                        <p v-if="scoreExampleText(metric, group.buckets)" class="mt-2 text-xs italic" style="color: var(--ink-muted)">
                            {{ scoreExampleText(metric, group.buckets) }}
                        </p>

                        <div class="mt-3 space-y-2">
                            <div
                                v-for="(bucket, i) in group.buckets"
                                :key="bucket.id"
                                class="flex flex-wrap items-center gap-2 rounded-md border px-3 py-2"
                                style="border-color: var(--border); background-color: var(--surface)"
                            >
                                <span
                                    class="h-2 w-2 shrink-0 rounded-full"
                                    :style="`background-color: ${tierTone(scoreForms[bucket.id], group.buckets.length - 1 - i).ink}`"
                                />
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

                                <!-- Color swatch picker -->
                                <div v-if="canEdit" class="flex items-center gap-1">
                                    <button
                                        v-for="token in swatchOptions"
                                        :key="token"
                                        type="button"
                                        class="h-5 w-5 shrink-0 rounded-full transition-transform"
                                        :style="`background-color: var(--status-${token}-ink); ${scoreForms[bucket.id].color === token ? 'outline: 2px solid var(--ink); outline-offset: 1px;' : ''}`"
                                        :aria-label="`Set color ${colorLabels[token]}`"
                                        :title="colorLabels[token]"
                                        @click="setBucketColor(scoreForms[bucket.id], bucket.id, token)"
                                    />
                                </div>

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
                                v-if="canEdit && !showNewScoreRow[newScoreFormKey(metric, group)]"
                                type="button"
                                class="flex w-full items-center justify-center gap-1.5 rounded-md border border-dashed py-2 text-xs font-semibold transition-colors hover:opacity-70"
                                style="border-color: var(--border-strong); color: var(--accent)"
                                @click="ensureNewScoreForm(metric, group); showNewScoreRow[newScoreFormKey(metric, group)] = true"
                            >
                                + Add tier to {{ group.label }}
                            </button>

                            <div
                                v-if="canEdit && showNewScoreRow[newScoreFormKey(metric, group)]"
                                class="flex items-center gap-2 rounded-md border border-dashed px-3 py-2"
                                style="border-color: var(--accent)"
                            >
                                <span class="text-xs" style="color: var(--ink-faint)">≥</span>
                                <input
                                    v-model.number="newScoreForms[newScoreFormKey(metric, group)].min_rate"
                                    type="number"
                                    step="0.01"
                                    placeholder="floor"
                                    :class="inputStyle"
                                    :style="inputSurface"
                                    class="w-20"
                                />
                                <span class="text-xs" style="color: var(--ink-faint)">→ score</span>
                                <input
                                    v-model.number="newScoreForms[newScoreFormKey(metric, group)].score"
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
                                        :disabled="newScoreForms[newScoreFormKey(metric, group)].processing"
                                        @click="addScoreBucket(metric, group)"
                                    >
                                        Add
                                    </button>
                                    <button
                                        type="button"
                                        class="text-xs font-medium transition-colors hover:opacity-70"
                                        style="color: var(--ink-faint)"
                                        @click="showNewScoreRow[newScoreFormKey(metric, group)] = false"
                                    >
                                        Cancel
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Add a brand-new (platform, tier) group — e.g. the first TikTok set -->
                    <button
                        v-if="canEdit && !showNewScoreGroup[metric]"
                        type="button"
                        class="flex w-full items-center justify-center gap-1.5 rounded-md border border-dashed py-2 text-xs font-semibold transition-colors hover:opacity-70"
                        style="border-color: var(--border-strong); color: var(--ink-muted)"
                        @click="showNewScoreGroup[metric] = true"
                    >
                        + Add platform / tier group
                    </button>
                    <div
                        v-if="canEdit && showNewScoreGroup[metric]"
                        class="flex flex-wrap items-center gap-2 rounded-md border border-dashed px-3 py-2"
                        style="border-color: var(--ink-faint)"
                    >
                        <select v-model="newGroupDraft[metric].platform" :class="inputStyle" :style="inputSurface" class="w-32">
                            <option :value="null">All platforms</option>
                            <option value="instagram">Instagram</option>
                            <option value="tiktok">TikTok</option>
                        </select>
                        <select
                            v-model="newGroupDraft[metric].tier"
                            :class="inputStyle"
                            :style="inputSurface"
                            class="w-40"
                        >
                            <option :value="null">No tier (platform-wide)</option>
                            <option v-for="tier in accountTiers" :key="tier" :value="tier">{{ tier }}</option>
                        </select>
                        <div class="ml-auto flex items-center gap-2">
                            <button
                                type="button"
                                class="text-xs font-semibold transition-colors hover:opacity-70"
                                style="color: var(--accent)"
                                @click="createScoreGroup(metric)"
                            >
                                Create group
                            </button>
                            <button
                                type="button"
                                class="text-xs font-medium transition-colors hover:opacity-70"
                                style="color: var(--ink-faint)"
                                @click="showNewScoreGroup[metric] = false"
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

                <!-- Live worked example — recalculates as tiers below are edited -->
                <p v-if="labelExampleText(metric)" class="mt-2 text-xs italic" style="color: var(--ink-muted)">
                    {{ labelExampleText(metric) }}
                </p>

                <div class="mt-4 space-y-2">
                    <div
                        v-for="(bucket, i) in labelBucketsByMetric[metric]"
                        :key="bucket.id"
                        class="flex flex-wrap items-center gap-2 rounded-md border px-3 py-2"
                        style="border-color: var(--border); background-color: var(--bg)"
                    >
                        <span
                            class="h-2 w-2 shrink-0 rounded-full"
                            :style="`background-color: ${tierTone(labelForms[bucket.id], labelBucketsByMetric[metric].length - 1 - i).ink}`"
                        />
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

                        <!-- Color swatch picker -->
                        <div v-if="canEdit" class="flex items-center gap-1">
                            <button
                                v-for="token in swatchOptions"
                                :key="token"
                                type="button"
                                class="h-5 w-5 shrink-0 rounded-full transition-transform"
                                :style="`background-color: var(--status-${token}-ink); ${labelForms[bucket.id].color === token ? 'outline: 2px solid var(--ink); outline-offset: 1px;' : ''}`"
                                :aria-label="`Set color ${colorLabels[token]}`"
                                :title="colorLabels[token]"
                                @click="setBucketColor(labelForms[bucket.id], bucket.id, token)"
                            />
                        </div>

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
