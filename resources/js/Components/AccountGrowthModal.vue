<script setup>
import { computed, nextTick, onBeforeUnmount, ref, watch } from 'vue';
import Chart from '../chartSetup';
import StatusBadge from './StatusBadge.vue';

const props = defineProps({
    account: {
        type: Object,
        required: true,
    },
    defaultAiProvider: {
        type: String,
        default: 'groq',
    },
    initialPlatform: {
        type: String,
        default: 'instagram',
    },
});

const emit = defineEmits(['close']);

const loading = ref(true);
const error = ref(null);
const cycles = ref([]);
const emptyCountAndViews = () => ({ total_posts: 0, total_views: 0 });
const emptySummary = () => ({
    total_posts: 0,
    total_views: 0,
    avg_views: null,
    with_cycle: emptyCountAndViews(),
    without_cycle: emptyCountAndViews(),
});
const postSummary = ref({ instagram: emptySummary(), tiktok: emptySummary() });

const tabs = [
    { key: 'instagram', label: 'Instagram' },
    { key: 'tiktok', label: 'TikTok' },
    { key: 'ai-summary', label: 'AI Summary' },
];

const activeTab = ref(props.initialPlatform === 'tiktok' ? 'tiktok' : 'instagram');

const platformCycles = (platform) => cycles.value.filter((c) => (c.platform ?? 'instagram') === platform);

// Range filter for the CHARTS only — scopes every chart together (one control, above
// everything it affects, never silently truncated). The KPI headline/delta always
// reads the true latest cycle regardless of this filter, since "vs last cycle" means
// the actual last cycle, not whatever the chart window happens to include.
const rangeOptions = [
    { value: 6, label: 'Last 6 cycles' },
    { value: 12, label: 'Last 12 cycles' },
    { value: 'all', label: 'All cycles' },
];
const range = ref(12);

const allActiveCycles = computed(() => platformCycles(activeTab.value));
const activeCycles = computed(() => {
    if (range.value === 'all') return allActiveCycles.value;
    return allActiveCycles.value.slice(-range.value);
});
const latestCycle = computed(() => allActiveCycles.value.at(-1) ?? null);
const previousCycle = computed(() => allActiveCycles.value.at(-2) ?? null);

const activePlatformSummary = () => postSummary.value[activeTab.value] ?? emptySummary();

const formatCount = (value) => new Intl.NumberFormat('en-US').format(value ?? 0);

const formatCountOrDash = (value) => (value === null || value === undefined ? '—' : formatCount(value));

// Compact form for stat-tile values: 1,284 / 12.9K / 4.2M, matching the "auto-compact" contract.
const formatCompact = (value) => {
    if (value === null || value === undefined) return '—';
    return new Intl.NumberFormat('en-US', { notation: 'compact', maximumFractionDigits: 1 }).format(value);
};

// Delta between the latest cycle and the one before it — direction + magnitude,
// used by stat tiles so a single number doesn't have to carry "is this good?" alone.
const deltaFor = (key) => {
    if (!latestCycle.value || !previousCycle.value) return null;
    const current = latestCycle.value[key];
    const previous = previousCycle.value[key];
    if (current === null || previous === null || previous === undefined || current === undefined) return null;
    if (previous === 0) return null;
    return ((current - previous) / previous) * 100;
};

const formatDelta = (delta) => {
    if (delta === null) return null;
    const rounded = Math.round(delta * 10) / 10;
    return `${rounded > 0 ? '+' : ''}${rounded}%`;
};

// volumeTiles: Reach / Views / Engagement / Story Performance as stat tiles with
// a delta arrow instead of four separate single-series line charts — the reader
// needs "is it up or down since last cycle," not four more mini line-charts.
const volumeTiles = computed(() => [
    { key: 'reach', label: 'Reach' },
    { key: 'views', label: 'Views' },
    { key: 'engagement', label: 'Engagement' },
    { key: 'story_performance', label: 'Story Performance' },
]);

// Posts & Views gets its own full-width row (it's two stacked single-series charts,
// so it needs the room); Scores and Engagement Rate are single combined charts and
// pair comfortably in a row together.
const wideChartSection = { key: 'posts', title: 'Posts & Views per Cycle', description: 'How much was posted, and how many views it earned, cycle by cycle.' };
const chartSections = [
    { key: 'scores', title: 'Scores', description: 'Visibility, Engagement, and Health scores side by side.' },
    { key: 'engagement-rate', title: 'Engagement Rate', description: 'Engagement measured against reach vs. against followers.' },
];

const chartConfigs = {
    followers: [
        { key: 'end_follower', label: 'Followers', suffix: '', single: true },
    ],
    posts: [
        // Posts (small counts) and Views (tens of thousands) sit on wildly different
        // scales — one combined line chart would flatten Posts to a near-invisible
        // line at the bottom, so these stay two separate single-series charts.
        { key: 'post_count', label: 'Posts', suffix: '', single: true },
        { key: 'view_count', label: 'Views', suffix: '', single: true },
    ],
    scores: [
        {
            key: 'aggregate-scores',
            label: 'Visibility / Engagement / Health',
            combined: true,
            series: [
                { key: 'visibility_rate', label: 'Visibility' },
                { key: 'engagement_score', label: 'Engagement' },
                { key: 'health_rate', label: 'Health' },
            ],
            suffix: '',
        },
    ],
    'engagement-rate': [
        {
            key: 'er-comparison',
            label: 'ER of Reach vs ER of Followers',
            combined: true,
            series: [
                { key: 'er_reach_rate', label: 'ER of Reach' },
                { key: 'er_follower_rate', label: 'ER of Followers' },
            ],
            suffix: '%',
        },
    ],
};

const canvasRefs = {};
const charts = {};

const getCssVar = (name) => getComputedStyle(document.documentElement).getPropertyValue(name).trim();

// Fixed categorical order (never cycled) — accent first, then two more app-consistent hues.
const palette = () => [
    getCssVar('--accent') || '#0f766e',
    '#c2410c',
    '#7c3aed',
];

const formatValue = (value, suffix) => (suffix ? `${value}${suffix}` : new Intl.NumberFormat('en-US').format(value));

const setCanvasRef = (key, el) => {
    canvasRefs[key] = el;
};

const destroyAllCharts = () => {
    Object.keys(charts).forEach((key) => {
        charts[key]?.destroy();
        delete charts[key];
    });
};

const renderChart = (config, dataCycles) => {
    const canvas = canvasRefs[config.key];
    if (!canvas) return;

    const inkFaint = getCssVar('--ink-faint') || '#8b979b';
    const border = getCssVar('--border') || '#d8dedc';
    const colors = palette();
    const labels = dataCycles.map((c) => c.label);

    const series = config.combined ? config.series : [{ key: config.key, label: config.label }];

    const datasets = series.map((s, i) => ({
        label: s.label,
        data: dataCycles.map((c) => c[s.key]),
        borderColor: colors[i % colors.length],
        backgroundColor: colors[i % colors.length],
        pointBackgroundColor: colors[i % colors.length],
        pointBorderColor: getCssVar('--surface') || '#ffffff',
        pointBorderWidth: 2,
        pointRadius: 4,
        borderWidth: 2,
        tension: 0.3,
        fill: false,
    }));

    charts[config.key] = new Chart(canvas, {
        type: 'line',
        data: { labels, datasets },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                // A single series names itself in the section title — no legend box needed.
                legend: { display: series.length > 1, labels: { color: inkFaint, usePointStyle: true } },
                tooltip: {
                    callbacks: {
                        label: (context) => `${context.dataset.label}: ${formatValue(context.parsed.y, config.suffix)}`,
                    },
                },
            },
            scales: {
                x: {
                    ticks: { color: inkFaint },
                    grid: { display: false },
                },
                y: {
                    ticks: {
                        color: inkFaint,
                        callback: (value) => formatValue(value, config.suffix),
                    },
                    grid: { color: border },
                },
            },
        },
    });
};

const renderAllCharts = async () => {
    destroyAllCharts();
    if (activeTab.value !== 'instagram' && activeTab.value !== 'tiktok') return;
    await nextTick();
    allChartConfigs().forEach((config) => renderChart(config, activeCycles.value));
};

watch(activeTab, renderAllCharts);
watch(range, renderAllCharts);

// AI Summary tab

const providers = [
    { value: 'groq', label: 'Groq' },
    { value: 'gemini', label: 'Gemini' },
];

const summarizing = ref(false);
const summarizeError = ref(null);
const summaryResult = ref(null);
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

const summarizeAccount = async () => {
    summarizing.value = true;
    summarizeError.value = null;

    try {
        const response = await fetch(`/accounts/${props.account.id}/summarize`, {
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

        summaryResult.value = data;
    } catch (e) {
        summarizeError.value = e.message;
    } finally {
        summarizing.value = false;
    }
};

// PDF export

const exporting = ref(false);
const exportError = ref(null);

const allChartConfigs = () => Object.values(chartConfigs).flat();

const captureChartImage = (config, dataCycles) => {
    return new Promise((resolve) => {
        const offscreen = document.createElement('canvas');
        offscreen.width = 900;
        offscreen.height = 400;

        const inkFaint = '#8b979b';
        const border = '#d8dedc';
        const colors = palette();
        const labels = dataCycles.map((c) => c.label);
        const series = config.combined ? config.series : [{ key: config.key, label: config.label }];

        const datasets = series.map((s, i) => ({
            label: s.label,
            data: dataCycles.map((c) => c[s.key]),
            borderColor: colors[i % colors.length],
            backgroundColor: colors[i % colors.length],
            pointBackgroundColor: colors[i % colors.length],
            pointRadius: 3,
            tension: 0.3,
            fill: false,
        }));

        const tempChart = new Chart(offscreen, {
            type: 'line',
            data: { labels, datasets },
            options: {
                responsive: false,
                animation: false,
                backgroundColor: 'white',
                plugins: {
                    legend: { display: series.length > 1, labels: { color: '#12181a' } },
                },
                scales: {
                    x: { ticks: { color: inkFaint }, grid: { color: border } },
                    y: {
                        ticks: { color: inkFaint, callback: (value) => formatValue(value, config.suffix) },
                        grid: { color: border },
                    },
                },
            },
            plugins: [
                {
                    id: 'whiteBackground',
                    beforeDraw: (chartInstance) => {
                        const ctx = chartInstance.canvas.getContext('2d');
                        ctx.save();
                        ctx.globalCompositeOperation = 'destination-over';
                        ctx.fillStyle = 'white';
                        ctx.fillRect(0, 0, chartInstance.width, chartInstance.height);
                        ctx.restore();
                    },
                },
            ],
        });

        requestAnimationFrame(() => {
            const image = offscreen.toDataURL('image/png');
            tempChart.destroy();
            resolve(image);
        });
    });
};

const downloadPdf = async () => {
    exporting.value = true;
    exportError.value = null;

    try {
        const dataCycles = activeCycles.value;
        const images = await Promise.all(
            allChartConfigs().map(async (config) => ({
                label: config.label,
                image: await captureChartImage(config, dataCycles),
            })),
        );

        const response = await fetch(`/accounts/${props.account.id}/pdf`, {
            method: 'POST',
            headers: {
                Accept: 'application/pdf',
                'Content-Type': 'application/json',
                'X-Requested-With': 'XMLHttpRequest',
                'X-XSRF-TOKEN': decodeURIComponent(
                    document.cookie.match(/XSRF-TOKEN=([^;]+)/)?.[1] ?? '',
                ),
            },
            body: JSON.stringify({
                charts: images,
                ai_summary: summaryResult.value?.summary ?? undefined,
                // Headline numbers the modal leads with — same data the KPI tiles and
                // Volume section show, so the PDF isn't just charts with no numbers.
                summary: {
                    platform: activeTab.value === 'tiktok' ? 'TikTok' : 'Instagram',
                    followers: latestCycle.value?.end_follower ?? null,
                    followers_delta: deltaFor('end_follower'),
                    health_label: latestCycle.value?.health_label ?? null,
                    health_rate: latestCycle.value?.health_rate ?? null,
                    growth_rate: latestCycle.value?.growth_rate ?? null,
                    avg_views: activePlatformSummary().avg_views ?? null,
                    total_posts: activePlatformSummary().total_posts ?? null,
                    latest_cycle_label: latestCycle.value?.label ?? null,
                    volume: volumeTiles.value.map((tile) => ({
                        label: tile.label,
                        value: latestCycle.value?.[tile.key] ?? null,
                        delta: deltaFor(tile.key),
                    })),
                },
            }),
        });

        if (!response.ok) {
            throw new Error('Failed to generate PDF.');
        }

        const blob = await response.blob();
        const url = URL.createObjectURL(blob);
        const link = document.createElement('a');
        link.href = url;
        link.download = `${props.account.name}-growth.pdf`;
        link.click();
        URL.revokeObjectURL(url);
    } catch (e) {
        exportError.value = e.message;
    } finally {
        exporting.value = false;
    }
};

const load = async () => {
    loading.value = true;
    error.value = null;

    try {
        const response = await fetch(`/accounts/${props.account.id}/growth`, {
            headers: { Accept: 'application/json' },
        });

        if (!response.ok) {
            throw new Error('Failed to load growth data.');
        }

        const data = await response.json();

        if (data.cycles.length === 0) {
            error.value = 'No cycles recorded for this account yet.';
            loading.value = false;
            return;
        }

        cycles.value = data.cycles;
        postSummary.value = data.postSummary ?? postSummary.value;

        if (data.ai_summary) {
            summaryResult.value = {
                summary: data.ai_summary,
                cycle_count: data.cycles.length,
                generated_at: data.ai_summary_generated_at,
            };
        }

        loading.value = false;
        await renderAllCharts();
    } catch (e) {
        error.value = e.message;
        loading.value = false;
    }
};

load();

onBeforeUnmount(() => {
    destroyAllCharts();
});
</script>

<template>
    <div class="fixed inset-0 z-10 flex items-center justify-center bg-black/50 px-4 backdrop-blur-sm">
        <div
            class="h-[95vh] w-[95vw] max-w-6xl overflow-y-auto rounded-lg border p-6 shadow-2xl"
            style="background-color: var(--surface-raised); border-color: var(--border)"
        >
            <div class="flex items-start justify-between gap-4">
                <div>
                    <h2 class="font-display text-lg font-bold" style="color: var(--ink)">
                        {{ account.name }}
                    </h2>
                    <p class="mt-0.5 text-sm" style="color: var(--ink-muted)">Performance trends over time</p>
                </div>
                <div class="flex shrink-0 items-center gap-2">
                    <button
                        v-if="!loading && !error && activeTab !== 'ai-summary'"
                        type="button"
                        :disabled="exporting"
                        class="inline-flex items-center gap-1.5 rounded-md border px-3 py-2 text-sm font-medium transition-colors hover:opacity-70 disabled:opacity-50"
                        style="border-color: var(--border); color: var(--ink-muted)"
                        @click="downloadPdf"
                    >
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-4 w-4">
                            <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4M7 10l5 5 5-5M12 15V3" />
                        </svg>
                        {{ exporting ? 'Preparing…' : 'Download PDF' }}
                    </button>
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
            </div>
            <p v-if="exportError" class="mt-2 text-sm" style="color: var(--status-parah-ink)">{{ exportError }}</p>

            <div v-if="!loading && !error" class="mt-4 flex gap-1 border-b" style="border-color: var(--border)">
                <button
                    v-for="tab in tabs"
                    :key="tab.key"
                    type="button"
                    class="border-b-2 px-3 py-2 text-sm font-medium transition-colors"
                    :style="
                        activeTab === tab.key
                            ? 'border-color: var(--accent); color: var(--accent)'
                            : 'border-color: transparent; color: var(--ink-muted)'
                    "
                    @click="activeTab = tab.key"
                >
                    {{ tab.label }}
                </button>
            </div>

            <div class="mt-5">
                <p v-if="loading" class="py-12 text-center text-sm" style="color: var(--ink-faint)">Loading…</p>
                <p v-else-if="error" class="py-12 text-center text-sm" style="color: var(--ink-faint)">{{ error }}</p>

                <div v-else-if="activeTab === 'ai-summary'" class="space-y-4">
                    <div>
                        <label class="block text-sm font-medium" style="color: var(--ink-muted)">Provider</label>
                        <select
                            v-model="selectedProvider"
                            class="mt-1 w-full rounded-md border px-3 py-2 text-sm transition-colors focus:outline-none focus:ring-2"
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
                            class="mt-1 w-full rounded-md border px-3 py-2 text-sm transition-colors focus:outline-none focus:ring-2"
                            style="border-color: var(--border); background-color: var(--surface); color: var(--ink)"
                        />
                    </div>

                    <button
                        type="button"
                        :disabled="summarizing"
                        class="w-full rounded-md px-4 py-2 text-sm font-semibold transition-opacity hover:opacity-90 disabled:opacity-50"
                        style="background-color: var(--accent); color: var(--accent-ink)"
                        @click="summarizeAccount"
                    >
                        {{ summarizing ? 'Summarizing…' : summaryResult ? 'Regenerate' : 'Summarize' }}
                    </button>

                    <p v-if="summarizeError" class="text-sm" style="color: var(--status-parah-ink)">
                        {{ summarizeError }}
                    </p>

                    <div v-if="summaryResult" class="rounded-md border p-3" style="border-color: var(--border); background-color: var(--surface)">
                        <p class="text-sm leading-relaxed" style="color: var(--ink)">{{ summaryResult.summary }}</p>
                        <p class="mt-2 text-xs" style="color: var(--ink-faint)">
                            {{ summaryResult.cycle_count }} cycle{{ summaryResult.cycle_count === 1 ? '' : 's' }} &middot;
                            generated {{ formatDateTime(summaryResult.generated_at) }}
                        </p>
                    </div>
                </div>

                <p
                    v-else-if="platformCycles(activeTab).length === 0"
                    class="py-12 text-center text-sm"
                    style="color: var(--ink-faint)"
                >
                    No {{ activeTab === 'tiktok' ? 'TikTok' : 'Instagram' }} cycles recorded for this account yet.
                </p>

                <div v-else>
                    <!-- Headline: the numbers this modal exists to answer, stated plainly. -->
                    <div class="grid grid-cols-2 gap-3 sm:grid-cols-4">
                        <div class="rounded-lg border p-4" style="border-color: var(--border); background-color: var(--surface)">
                            <p class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Followers</p>
                            <p class="mt-1 font-display text-2xl font-bold" style="color: var(--ink)">
                                {{ formatCompact(latestCycle?.end_follower) }}
                            </p>
                            <p v-if="deltaFor('end_follower') !== null" class="mt-0.5 text-xs font-medium" :style="deltaFor('end_follower') >= 0 ? 'color: var(--status-sip-ink)' : 'color: var(--status-parah-ink)'">
                                {{ formatDelta(deltaFor('end_follower')) }} vs last cycle
                            </p>
                        </div>
                        <div class="rounded-lg border p-4" style="border-color: var(--border); background-color: var(--surface)">
                            <p class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Health</p>
                            <div class="mt-1.5">
                                <StatusBadge :status="latestCycle?.health_label" />
                            </div>
                            <p class="mt-1.5 text-xs" style="color: var(--ink-muted)">{{ latestCycle?.health_rate }} rate</p>
                        </div>
                        <div class="rounded-lg border p-4" style="border-color: var(--border); background-color: var(--surface)">
                            <p class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Growth Rate</p>
                            <p class="mt-1 font-display text-2xl font-bold" :style="latestCycle?.growth_rate >= 0 ? 'color: var(--ink)' : 'color: var(--status-parah-ink)'">
                                {{ latestCycle?.growth_rate }}%
                            </p>
                            <p class="mt-0.5 text-xs" style="color: var(--ink-muted)">latest cycle</p>
                        </div>
                        <div class="rounded-lg border p-4" style="border-color: var(--border); background-color: var(--surface)">
                            <p class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Avg Views</p>
                            <p class="mt-1 font-display text-2xl font-bold" style="color: var(--ink)">
                                {{ formatCountOrDash(activePlatformSummary().avg_views) }}
                            </p>
                            <p class="mt-0.5 text-xs" style="color: var(--ink-muted)">
                                {{ formatCount(activePlatformSummary().total_posts) }} posts total
                            </p>
                        </div>
                    </div>

                    <!-- Range filter — one control, above every chart it scopes; the KPI row above
                         stays fixed to the true latest cycle regardless of this selection. -->
                    <div v-if="allActiveCycles.length > 6" class="mt-4 flex items-center justify-end gap-2">
                        <label class="text-xs font-medium" style="color: var(--ink-muted)">Chart range</label>
                        <select
                            v-model="range"
                            class="rounded-md border px-2.5 py-1.5 text-xs transition-colors focus:outline-none"
                            style="border-color: var(--border); background-color: var(--surface); color: var(--ink)"
                        >
                            <option v-for="option in rangeOptions" :key="option.value" :value="option.value">
                                {{ option.label }}
                            </option>
                        </select>
                    </div>

                    <!-- The one real trend that matters at a glance: followers over time. -->
                    <div class="mt-4 rounded-lg border p-4" style="border-color: var(--border); background-color: var(--surface)">
                        <h3 class="font-display text-sm font-bold" style="color: var(--ink)">Followers</h3>
                        <p class="text-xs" style="color: var(--ink-faint)">End-of-cycle follower count.</p>
                        <div class="relative mt-3" style="height: 220px">
                            <canvas :ref="(el) => setCanvasRef('end_follower', el)"></canvas>
                        </div>
                    </div>

                    <!-- Volume: stat tiles with a delta arrow instead of three more mini line-charts. -->
                    <div class="mt-4 rounded-lg border p-4" style="border-color: var(--border); background-color: var(--surface)">
                        <h3 class="font-display text-sm font-bold" style="color: var(--ink)">Volume</h3>
                        <p class="text-xs" style="color: var(--ink-faint)">Latest cycle, compared to the one before it.</p>
                        <div class="mt-3 grid grid-cols-2 gap-3 sm:grid-cols-4">
                            <div v-for="tile in volumeTiles" :key="tile.key" class="rounded-md border p-3" style="border-color: var(--border); background-color: var(--bg)">
                                <p class="text-[11px] font-medium uppercase tracking-wide" style="color: var(--ink-faint)">{{ tile.label }}</p>
                                <p class="mt-0.5 font-display text-lg font-bold" style="color: var(--ink)">
                                    {{ formatCompact(latestCycle?.[tile.key]) }}
                                </p>
                                <p v-if="deltaFor(tile.key) !== null" class="mt-0.5 text-xs font-medium" :style="deltaFor(tile.key) >= 0 ? 'color: var(--status-sip-ink)' : 'color: var(--status-parah-ink)'">
                                    {{ deltaFor(tile.key) >= 0 ? '▲' : '▼' }} {{ Math.abs(Math.round(deltaFor(tile.key) * 10) / 10) }}%
                                </p>
                                <p v-else class="mt-0.5 text-xs" style="color: var(--ink-faint)">—</p>
                            </div>
                        </div>
                    </div>

                    <div class="mt-4 rounded-lg border p-4" style="border-color: var(--border); background-color: var(--surface)">
                        <h3 class="font-display text-sm font-bold" style="color: var(--ink)">{{ wideChartSection.title }}</h3>
                        <p class="text-xs" style="color: var(--ink-faint)">{{ wideChartSection.description }}</p>
                        <div class="mt-3 grid grid-cols-1 gap-4 sm:grid-cols-2">
                            <div v-for="config in chartConfigs[wideChartSection.key]" :key="config.key">
                                <p class="mb-1 text-[11px] font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">
                                    {{ config.label }}
                                </p>
                                <div class="relative" style="height: 220px">
                                    <canvas :ref="(el) => setCanvasRef(config.key, el)"></canvas>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="mt-4 grid grid-cols-1 gap-4 lg:grid-cols-2">
                        <div v-for="section in chartSections" :key="section.key" class="rounded-lg border p-4" style="border-color: var(--border); background-color: var(--surface)">
                            <h3 class="font-display text-sm font-bold" style="color: var(--ink)">{{ section.title }}</h3>
                            <p class="text-xs" style="color: var(--ink-faint)">{{ section.description }}</p>
                            <div v-for="config in chartConfigs[section.key]" :key="config.key">
                                <div class="relative mt-3" style="height: 220px">
                                    <canvas :ref="(el) => setCanvasRef(config.key, el)"></canvas>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Cycle coverage detail — supporting detail, not the headline, so it sits below the charts. -->
                    <div class="mt-4 rounded-lg border p-4" style="border-color: var(--border); background-color: var(--surface)">
                        <h3 class="font-display text-sm font-bold" style="color: var(--ink)">Cycle Coverage</h3>
                        <p class="text-xs" style="color: var(--ink-faint)">Posts that fall inside a tracked cycle vs. posts that don't yet.</p>
                        <div class="mt-3 grid grid-cols-2 gap-3 sm:max-w-md">
                            <div class="rounded-md border p-3" style="border-color: var(--border); background-color: var(--bg)">
                                <p class="text-[11px] font-medium uppercase tracking-wide" style="color: var(--ink-faint)">With Cycle</p>
                                <p class="mt-0.5 font-display text-lg font-bold" style="color: var(--ink)">
                                    {{ formatCount(activePlatformSummary().with_cycle.total_posts) }}
                                    <span class="text-xs font-normal" style="color: var(--ink-faint)">posts</span>
                                </p>
                                <p class="text-xs" style="color: var(--ink-muted)">{{ formatCount(activePlatformSummary().with_cycle.total_views) }} views</p>
                            </div>
                            <div class="rounded-md border p-3" style="border-color: var(--border); background-color: var(--bg)">
                                <p class="text-[11px] font-medium uppercase tracking-wide" style="color: var(--ink-faint)">Without Cycle</p>
                                <p class="mt-0.5 font-display text-lg font-bold" style="color: var(--ink)">
                                    {{ formatCount(activePlatformSummary().without_cycle.total_posts) }}
                                    <span class="text-xs font-normal" style="color: var(--ink-faint)">posts</span>
                                </p>
                                <p class="text-xs" style="color: var(--ink-muted)">{{ formatCount(activePlatformSummary().without_cycle.total_views) }} views</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>
