<script setup>
import { computed, nextTick, onBeforeUnmount, onMounted, ref, watch } from 'vue';
import Chart from '../chartSetup';
import MonthRangePicker from './MonthRangePicker.vue';

const props = defineProps({
    insight: {
        type: Object,
        required: true,
    },
    // The insight this one is scored against — null when there's no earlier
    // cycle for this account (or, in range mode, no data in the From month).
    previous: {
        type: Object,
        default: null,
    },
    // Whether the table's own filter is already a picked From month (vs. the
    // default "previous cycle" reading) — only changes initial wording.
    hasRange: {
        type: Boolean,
        default: false,
    },
    // This account's full cycle history (flat allInsights shape), oldest
    // first — everything below the header derives from this plus whichever
    // month range is picked in this modal.
    history: {
        type: Array,
        default: () => [],
    },
});

const emit = defineEmits(['close']);

const num = (v) => Number(v || 0).toLocaleString('en-US');
const fmtPct = (v) => (v === null || v === undefined ? '—' : `${v > 0 ? '+' : ''}${Math.round(v * 10) / 10}%`);
const pctStyle = (v) =>
    v === null || v === undefined
        ? 'color: var(--ink-faint)'
        : v >= 0
          ? 'color: var(--status-sip-ink)'
          : 'color: var(--status-parah-ink)';

const platformLabel = (p) => (p ? p.charAt(0).toUpperCase() + p.slice(1) : '');

const cycleRange = (start, end) => {
    if (!start) return '—';
    const fmt = (d) =>
        new Date(d).toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric' });
    return `${fmt(start)} – ${fmt(end)}`;
};

const pct = (from, to) => {
    if (from === null || from === undefined || to === null || to === undefined || from === 0) return null;
    return ((to - from) / from) * 100;
};

const monthLabel = (ym) => {
    if (!ym) return '';
    const [y, m] = ym.split('-');
    return new Date(Number(y), Number(m) - 1, 1).toLocaleString('en-US', { month: 'short', year: 'numeric' });
};

// --- One month-range picker scopes the whole modal ---
// Empty = the table row's own current/previous pair (today's default:
// latest cycle vs. the one before it, or the table's own picked From month).
// Picking From/To here re-derives EVERYTHING below — the comparison strip,
// Weighted Score tiles, raw numbers, and the trend chart — from this
// account's cycle in each of those two months instead.

const cycleMonths = computed(() => [...new Set(props.history.map((h) => h.month).filter(Boolean))].sort());

const rangeFromMonth = ref('');
const rangeToMonth = ref('');
const hasPickedRange = computed(() => !!rangeFromMonth.value && !!rangeToMonth.value);
const rangePickerOpen = ref(false);
const rangePickerRef = ref(null);

const onClickOutsideRangePicker = (event) => {
    if (rangePickerRef.value && !rangePickerRef.value.contains(event.target)) {
        rangePickerOpen.value = false;
    }
};
onMounted(() => document.addEventListener('click', onClickOutsideRangePicker));
onBeforeUnmount(() => document.removeEventListener('click', onClickOutsideRangePicker));

const clearPickedRange = () => {
    rangeFromMonth.value = '';
    rangeToMonth.value = '';
};

const insightForMonth = (ym) => props.history.find((h) => h.month === ym) ?? null;

// The active "current" and "previous" the whole modal now reads from.
const activeTo = computed(() => (hasPickedRange.value ? insightForMonth(rangeToMonth.value) : props.insight));
const activeFrom = computed(() => (hasPickedRange.value ? insightForMonth(rangeFromMonth.value) : props.previous));

// Per-content-type breakdown for one metric prefix (viewers/interactions),
// each line carrying the current count, the compared-against count (when
// available), and the % change between them.
const breakdown = (prefix) => {
    const current = activeTo.value;
    const from = activeFrom.value;
    if (!current) return [];

    return ['posts', 'reels', 'story'].map((t) => {
        const currentValue = current[`${prefix}_${t}`] ?? 0;
        const previousValue = from ? (from[`${prefix}_${t}`] ?? 0) : null;
        return {
            key: t,
            label: t[0].toUpperCase() + t.slice(1),
            current: currentValue,
            previous: previousValue,
            delta: previousValue === null ? null : pct(previousValue, currentValue),
        };
    });
};

const metrics = [
    { key: 'viewers', label: 'Viewers' },
    { key: 'interactions', label: 'Interactions' },
];

const followerDelta = computed(() =>
    activeFrom.value && activeTo.value ? pct(activeFrom.value.end_follower, activeTo.value.end_follower) : null,
);

const componentLabel = (source) =>
    source === 'views' ? 'Views' : source === 'interactions' ? 'Interactions' : 'Growth';

// Weighted Content Score — same rule as the table: Posts/Reels 50% Views +
// 20% Interactions + 30% (account follower) Growth, Story 80% Views + 20%
// Interactions. A missing input drops out and the remaining weights
// renormalize, so a missing growth figure never silently drags a score to 0.
const contentScoreWeights = {
    posts: [
        { source: 'views', weight: 0.5 },
        { source: 'interactions', weight: 0.2 },
        { source: 'growth', weight: 0.3 },
    ],
    reels: [
        { source: 'views', weight: 0.5 },
        { source: 'interactions', weight: 0.2 },
        { source: 'growth', weight: 0.3 },
    ],
    story: [
        { source: 'views', weight: 0.8 },
        { source: 'interactions', weight: 0.2 },
    ],
};
const contentTypeLabels = { posts: 'Posts', reels: 'Reels', story: 'Story' };

const weightedScoresBetween = (from, to) => {
    const growthRate = pct(from.end_follower, to.end_follower);

    return Object.entries(contentScoreWeights).map(([type, components]) => {
        const values = {
            views: pct(from[`viewers_${type}`], to[`viewers_${type}`]),
            interactions: pct(from[`interactions_${type}`], to[`interactions_${type}`]),
            growth: growthRate,
        };
        const available = components.filter((c) => values[c.source] !== null);
        const weightSum = available.reduce((sum, c) => sum + c.weight, 0);
        const score =
            available.length === 0
                ? null
                : available.reduce((sum, c) => sum + (values[c.source] * c.weight) / weightSum, 0);

        return {
            key: type,
            label: contentTypeLabels[type],
            score,
            components: components.map((c) => ({ source: c.source, weight: c.weight, value: values[c.source] })),
        };
    });
};

const activeWeightedScores = computed(() =>
    activeFrom.value && activeTo.value ? weightedScoresBetween(activeFrom.value, activeTo.value) : null,
);

// --- Trend chart: Weighted Score across every consecutive cycle pair inside
// the picked range (or the full history when nothing's picked). ---

const rangedHistory = computed(() => {
    if (!hasPickedRange.value) return props.history;
    return props.history.filter((h) => h.month >= rangeFromMonth.value && h.month <= rangeToMonth.value);
});

const trendSeries = computed(() => {
    const cycles = rangedHistory.value;
    if (cycles.length < 2) return { labels: [], posts: [], reels: [], story: [] };

    const labels = [];
    const posts = [];
    const reels = [];
    const story = [];

    for (let i = 1; i < cycles.length; i++) {
        const scores = weightedScoresBetween(cycles[i - 1], cycles[i]);
        const byKey = Object.fromEntries(scores.map((s) => [s.key, s.score]));
        labels.push(monthLabel(cycles[i].month));
        posts.push(byKey.posts);
        reels.push(byKey.reels);
        story.push(byKey.story);
    }

    return { labels, posts, reels, story };
});

const canvasRef = ref(null);
let chartInstance = null;

const getCssVar = (name) => getComputedStyle(document.documentElement).getPropertyValue(name).trim();

const destroyChart = () => {
    chartInstance?.destroy();
    chartInstance = null;
};

const renderTrendChart = () => {
    destroyChart();
    if (!canvasRef.value) return;

    const { labels, posts, reels, story } = trendSeries.value;
    if (labels.length === 0) return;

    const inkFaint = getCssVar('--ink-faint') || '#8b979b';
    const border = getCssVar('--border') || '#d8dedc';
    const surface = getCssVar('--surface') || '#ffffff';
    const colors = [getCssVar('--accent') || '#0f766e', '#c2410c', '#7c3aed'];

    const datasets = [
        { label: 'Posts', data: posts },
        { label: 'Reels', data: reels },
        { label: 'Story', data: story },
    ].map((s, i) => ({
        label: s.label,
        data: s.data,
        borderColor: colors[i],
        backgroundColor: colors[i],
        pointBackgroundColor: colors[i],
        pointBorderColor: surface,
        pointBorderWidth: 2,
        pointRadius: 4,
        borderWidth: 2,
        tension: 0.3,
        fill: false,
        spanGaps: true,
    }));

    chartInstance = new Chart(canvasRef.value, {
        type: 'line',
        data: { labels, datasets },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: { display: true, labels: { color: inkFaint, usePointStyle: true } },
                tooltip: {
                    callbacks: {
                        label: (context) =>
                            context.parsed.y === null || context.parsed.y === undefined
                                ? `${context.dataset.label}: —`
                                : `${context.dataset.label}: ${fmtPct(context.parsed.y)}`,
                    },
                },
            },
            scales: {
                x: { ticks: { color: inkFaint }, grid: { display: false } },
                y: {
                    ticks: { color: inkFaint, callback: (value) => `${value}%` },
                    grid: { color: (ctx) => (ctx.tick.value === 0 ? inkFaint : border) },
                },
            },
        },
    });
};

watch([rangeFromMonth, rangeToMonth], async () => {
    await nextTick();
    renderTrendChart();
});

onMounted(async () => {
    await nextTick();
    renderTrendChart();
});

onBeforeUnmount(destroyChart);
</script>

<template>
    <div class="fixed inset-0 z-10 flex items-center justify-center bg-black/50 px-4 backdrop-blur-sm">
        <div
            class="flex max-h-[85vh] w-full max-w-2xl flex-col overflow-hidden rounded-xl border shadow-2xl"
            style="background-color: var(--surface-raised); border-color: var(--border)"
        >
            <!-- Sticky header: identity + the one control that scopes everything below. -->
            <div class="shrink-0 border-b px-6 py-5" style="border-color: var(--border)">
                <div class="flex items-start justify-between gap-4">
                    <div class="min-w-0">
                        <div class="flex flex-wrap items-center gap-2">
                            <h2 class="truncate font-display text-lg font-bold" style="color: var(--ink)">
                                {{ insight.account?.name || '—' }}
                            </h2>
                            <span
                                v-if="insight.cycle?.platform"
                                class="shrink-0 rounded px-1.5 py-0.5 text-[10px] font-semibold uppercase tracking-wide"
                                style="background-color: var(--accent-soft); color: var(--accent)"
                            >
                                {{ platformLabel(insight.cycle.platform) }}
                            </span>
                        </div>
                        <p class="mt-0.5 text-sm tabular-nums" style="color: var(--ink-muted)">
                            {{ cycleRange(activeTo?.cycle_start_date, activeTo?.cycle_end_date) }}
                        </p>
                    </div>
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

                <div class="mt-3 flex flex-wrap items-center gap-2">
                    <div ref="rangePickerRef" class="relative">
                        <button
                            type="button"
                            class="inline-flex items-center gap-1.5 rounded-md border px-2.5 py-1.5 text-xs font-medium transition-colors hover:opacity-80"
                            :style="
                                hasPickedRange
                                    ? 'border-color: var(--accent); background-color: var(--accent-soft); color: var(--accent)'
                                    : 'border-color: var(--border); background-color: var(--surface); color: var(--ink-muted)'
                            "
                            @click="rangePickerOpen = !rangePickerOpen"
                        >
                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-3.5 w-3.5">
                                <rect x="3" y="4" width="18" height="18" rx="2" />
                                <path d="M3 10h18M8 2v4M16 2v4" />
                            </svg>
                            <template v-if="hasPickedRange">
                                {{ monthLabel(rangeFromMonth) }} → {{ monthLabel(rangeToMonth) }}
                            </template>
                            <template v-else>Pick months to compare</template>
                        </button>

                        <div
                            v-if="rangePickerOpen"
                            class="absolute left-0 top-full z-20 mt-2 w-72 overflow-hidden rounded-lg border shadow-xl"
                            style="border-color: var(--border); background-color: var(--surface)"
                        >
                            <MonthRangePicker
                                v-model:model-from="rangeFromMonth"
                                v-model:model-to="rangeToMonth"
                                :allowed-months="cycleMonths"
                                class="!max-w-none !rounded-none !border-0 !shadow-none"
                            />
                            <div class="flex gap-2 border-t p-3" style="border-color: var(--border)">
                                <button
                                    v-if="rangeFromMonth || rangeToMonth"
                                    type="button"
                                    class="flex-1 rounded-md border py-1.5 text-xs font-medium transition-opacity hover:opacity-80"
                                    style="border-color: var(--border); color: var(--ink-muted)"
                                    @click="clearPickedRange"
                                >
                                    Reset
                                </button>
                                <button
                                    type="button"
                                    class="flex-1 rounded-md py-1.5 text-xs font-semibold transition-opacity hover:opacity-90"
                                    style="background-color: var(--accent); color: var(--accent-ink)"
                                    @click="rangePickerOpen = false"
                                >
                                    Done
                                </button>
                            </div>
                        </div>
                    </div>

                    <button
                        v-if="hasPickedRange"
                        type="button"
                        class="text-xs font-medium transition-opacity hover:opacity-70"
                        style="color: var(--ink-muted)"
                        @click="clearPickedRange"
                    >
                        Clear
                    </button>

                    <!-- Compared-against + follower delta folds into the same row as
                         the picker, instead of a separate strip repeating the date. -->
                    <p class="ml-auto flex items-center gap-1.5 text-xs" style="color: var(--ink-faint)">
                        <template v-if="activeFrom">
                            <span>vs {{ cycleRange(activeFrom.cycle_start_date, activeFrom.cycle_end_date) }}</span>
                            <span v-if="followerDelta !== null" class="inline-flex items-center gap-0.5 font-semibold" :style="pctStyle(followerDelta)">
                                · {{ followerDelta >= 0 ? '▲' : '▼' }} {{ fmtPct(followerDelta) }} followers
                            </span>
                        </template>
                        <template v-else>No prior cycle to compare against.</template>
                    </p>
                </div>
            </div>

            <!-- Scrollable body -->
            <div class="min-h-0 flex-1 overflow-y-auto px-6 py-5">
                <!-- Weighted Content Score — the headline metric, given the strongest
                     visual weight in the modal (accent border, larger numerals). -->
                <div v-if="activeWeightedScores">
                    <p class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">
                        Weighted Content Score
                    </p>
                    <div class="mt-2 grid grid-cols-1 gap-3 sm:grid-cols-3">
                        <div
                            v-for="score in activeWeightedScores"
                            :key="score.key"
                            class="rounded-lg border-2 p-3"
                            :style="
                                score.score === null
                                    ? 'border-color: var(--border); background-color: var(--bg)'
                                    : 'border-color: var(--accent); background-color: var(--accent-soft)'
                            "
                        >
                            <p class="text-[10px] font-semibold uppercase tracking-wide" :style="score.score === null ? 'color: var(--ink-faint)' : 'color: var(--accent)'">
                                {{ score.label }}
                            </p>
                            <p class="mt-1 inline-flex items-center gap-1 font-display text-xl font-bold tabular-nums" :style="pctStyle(score.score)">
                                <template v-if="score.score !== null">{{ score.score >= 0 ? '▲' : '▼' }}</template>
                                {{ fmtPct(score.score) }}
                            </p>
                            <div class="mt-2 space-y-1 border-t pt-2" style="border-color: var(--border)">
                                <div v-for="c in score.components" :key="c.source" class="flex items-center justify-between text-xs">
                                    <span style="color: var(--ink-muted)">
                                        {{ componentLabel(c.source) }}
                                        <span style="color: var(--ink-faint)">({{ Math.round(c.weight * 100) }}%)</span>
                                    </span>
                                    <span class="tabular-nums font-medium" :style="pctStyle(c.value)">
                                        {{ c.value === null ? 'n/a' : fmtPct(c.value) }}
                                    </span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Trend: Weighted Score across cycles, following the same picked
                     range. Each point is the % change vs. the cycle right before it. -->
                <div class="mt-5 rounded-lg border p-4" style="border-color: var(--border); background-color: var(--surface)">
                    <h3 class="font-display text-sm font-bold" style="color: var(--ink)">Weighted Score Trend</h3>
                    <p class="text-xs" style="color: var(--ink-faint)">
                        Posts, Reels, and Story, cycle over cycle{{ hasPickedRange ? ', within the picked range' : '' }}.
                    </p>

                    <div v-if="trendSeries.labels.length === 0" class="py-8 text-center text-xs" style="color: var(--ink-faint)">
                        Need at least two cycles in this range to plot a trend.
                    </div>
                    <div v-else class="relative mt-3" style="height: 220px">
                        <canvas ref="canvasRef"></canvas>
                    </div>
                </div>

                <!-- Raw numbers — supporting detail, so it sits below the headline
                     score and the trend, not competing with them for attention. -->
                <div class="mt-5">
                    <p class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">
                        Raw Numbers
                    </p>
                    <div class="mt-2 grid grid-cols-1 gap-3 sm:grid-cols-2">
                        <div
                            v-for="metric in metrics"
                            :key="metric.key"
                            class="rounded-lg border p-4"
                            style="border-color: var(--border); background-color: var(--surface)"
                        >
                            <p class="text-[11px] font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">
                                {{ metric.label }}
                            </p>

                            <div class="mt-3 space-y-2">
                                <div v-for="part in breakdown(metric.key)" :key="part.key">
                                    <div class="flex items-center justify-between text-xs">
                                        <span style="color: var(--ink-muted)">{{ part.label }}</span>
                                        <span class="tabular-nums" style="color: var(--ink)">
                                            <template v-if="part.previous !== null">
                                                <span style="color: var(--ink-faint)">{{ num(part.previous) }} →</span>
                                            </template>
                                            <span class="font-semibold">{{ num(part.current) }}</span>
                                            <span v-if="part.delta !== null" class="ml-1 font-medium" :style="pctStyle(part.delta)">
                                                ({{ fmtPct(part.delta) }})
                                            </span>
                                        </span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>
