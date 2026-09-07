<script setup>
import { computed, nextTick, onBeforeUnmount, ref, watch } from 'vue';
import Chart from '../chartSetup';

const props = defineProps({
    accountId: { type: Number, required: true },
    accountName: { type: String, required: true },
    platform: { type: String, required: true },
    // When opened as a drill-down from the chart modal, closing this one should
    // read as "back," not "done" — the caller reopens the chart modal on @close,
    // this just changes what the affordance says so that return trip isn't a surprise.
    showBackButton: { type: Boolean, default: false },
});

const emit = defineEmits(['close']);

const loading = ref(true);
const error = ref(null);
const series = ref([]);
const platformLabel = computed(() => (props.platform === 'tiktok' ? 'TikTok' : 'Instagram'));

const chartCanvas = ref(null);
let chart = null;

const seriesWithData = computed(() => series.value.filter((point) => point.avg_views !== null));

const latest = computed(() => (seriesWithData.value.length ? seriesWithData.value[seriesWithData.value.length - 1] : null));
const previous = computed(() => (seriesWithData.value.length > 1 ? seriesWithData.value[seriesWithData.value.length - 2] : null));

const overallDeltaPct = computed(() => {
    if (!latest.value || !previous.value || previous.value.avg_views <= 0) return null;
    return Math.round(((latest.value.avg_views - previous.value.avg_views) / previous.value.avg_views) * 1000) / 10;
});

const peakPoint = computed(() => {
    if (!seriesWithData.value.length) return null;
    return seriesWithData.value.reduce((max, point) => (point.avg_views > max.avg_views ? point : max), seriesWithData.value[0]);
});

const formatNumber = (value) => (value === null || value === undefined ? '—' : new Intl.NumberFormat('en-US').format(value));
const formatCompact = (value) =>
    value === null || value === undefined ? '—' : new Intl.NumberFormat('en-US', { notation: 'compact', maximumFractionDigits: 1 }).format(value);
const formatDelta = (value) => (value === null || value === undefined ? '—' : `${value > 0 ? '+' : ''}${value}%`);
const deltaColor = (value) => {
    if (value === null || value === undefined) return 'var(--ink-faint)';
    if (value < 0) return 'var(--status-parah-ink)';
    if (value > 0) return 'var(--status-sip-ink)';
    return 'var(--ink-muted)';
};

const cssVar = (name) => getComputedStyle(document.documentElement).getPropertyValue(name).trim();

const destroyChart = () => {
    chart?.destroy();
    chart = null;
};

const renderChart = async () => {
    await nextTick();
    destroyChart();
    if (!chartCanvas.value || seriesWithData.value.length === 0) return;

    const accentColor = cssVar('--accent') || '#0f6e63';
    const gridColor = cssVar('--border') || '#e0e6e4';
    const inkMuted = cssVar('--ink-muted') || '#566469';
    const surface = cssVar('--surface') || '#ffffff';

    chart = new Chart(chartCanvas.value, {
        type: 'line',
        data: {
            labels: seriesWithData.value.map((point) => point.label),
            datasets: [
                {
                    label: 'Median views per post',
                    data: seriesWithData.value.map((point) => point.avg_views),
                    borderColor: accentColor,
                    backgroundColor: `${accentColor}1a`,
                    pointBackgroundColor: accentColor,
                    pointBorderColor: surface,
                    pointBorderWidth: 2,
                    pointRadius: 4,
                    borderWidth: 2,
                    fill: true,
                    tension: 0.25,
                },
            ],
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: { display: false },
                tooltip: {
                    callbacks: {
                        label: (ctx) => `Median views: ${new Intl.NumberFormat('en-US').format(ctx.parsed.y)}`,
                    },
                },
            },
            scales: {
                x: { grid: { display: false }, ticks: { color: inkMuted } },
                y: {
                    beginAtZero: true,
                    grid: { color: gridColor },
                    ticks: { color: inkMuted, callback: (value) => formatCompact(value) },
                },
            },
        },
    });
};

let renderGeneration = 0;
const renderWithGeneration = async () => {
    const thisGeneration = ++renderGeneration;
    await renderChart();
    requestAnimationFrame(() => {
        if (thisGeneration !== renderGeneration) return;
        chart?.resize();
    });
};

const load = async () => {
    loading.value = true;
    error.value = null;

    try {
        const response = await fetch(`/views-trend/${props.accountId}?platform=${props.platform}`, {
            headers: { Accept: 'application/json' },
        });

        if (!response.ok) throw new Error('Failed to load views trend.');

        const data = await response.json();
        series.value = data.series ?? [];

        if (seriesWithData.value.length === 0) {
            error.value = 'No views data recorded for this account/platform yet.';
        }

        loading.value = false;
        await renderWithGeneration();
    } catch (e) {
        error.value = e.message;
        loading.value = false;
    }
};

watch(() => [props.accountId, props.platform], load);

load();

onBeforeUnmount(() => {
    destroyChart();
});
</script>

<template>
    <div class="fixed inset-0 z-10 flex items-center justify-center bg-black/50 px-4 backdrop-blur-sm">
        <div
            class="max-h-[90vh] w-[95vw] max-w-3xl overflow-y-auto rounded-lg border p-6 shadow-2xl"
            style="background-color: var(--surface-raised); border-color: var(--border)"
        >
            <div class="flex items-start justify-between gap-4">
                <div>
                    <button
                        v-if="showBackButton"
                        type="button"
                        class="mb-1.5 inline-flex items-center gap-1 text-xs font-medium transition-colors hover:opacity-70"
                        style="color: var(--ink-muted)"
                        @click="emit('close')"
                    >
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-3.5 w-3.5">
                            <path d="m15 18-6-6 6-6" />
                        </svg>
                        Back to chart
                    </button>
                    <h2 class="font-display text-lg font-bold" style="color: var(--ink)">{{ accountName }}</h2>
                    <p class="mt-0.5 text-sm" style="color: var(--ink-muted)">Views trend — {{ platformLabel }}</p>
                </div>
                <button
                    type="button"
                    class="flex h-8 w-8 shrink-0 items-center justify-center rounded-md transition-colors hover:opacity-70"
                    style="color: var(--ink-muted)"
                    :aria-label="showBackButton ? 'Back to chart' : 'Close'"
                    @click="emit('close')"
                >
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-5 w-5">
                        <path d="M18 6 6 18M6 6l12 12" />
                    </svg>
                </button>
            </div>

            <div class="mt-5">
                <p v-if="loading" class="py-12 text-center text-sm" style="color: var(--ink-faint)">Loading…</p>
                <p v-else-if="error" class="py-12 text-center text-sm" style="color: var(--ink-faint)">{{ error }}</p>

                <template v-else>
                    <!-- Views-only headline stats -->
                    <div class="grid grid-cols-3 gap-3">
                        <div class="rounded-lg border p-4" style="border-color: var(--border); background-color: var(--surface)">
                            <p class="text-xs font-medium uppercase tracking-wide" style="color: var(--ink-faint)">Latest cycle median views</p>
                            <p class="mt-1.5 font-display text-2xl font-bold" style="color: var(--ink)">{{ formatNumber(latest?.avg_views) }}</p>
                            <p class="mt-0.5 text-xs font-semibold" :style="`color: ${deltaColor(overallDeltaPct)}`">
                                {{ formatDelta(overallDeltaPct) }} vs prior cycle
                            </p>
                        </div>
                        <div class="rounded-lg border p-4" style="border-color: var(--border); background-color: var(--surface)">
                            <p class="text-xs font-medium uppercase tracking-wide" style="color: var(--ink-faint)">Peak cycle</p>
                            <p class="mt-1.5 font-display text-2xl font-bold" style="color: var(--ink)">{{ formatNumber(peakPoint?.avg_views) }}</p>
                            <p class="mt-0.5 text-xs" style="color: var(--ink-muted)">{{ peakPoint?.label ?? '—' }}</p>
                        </div>
                        <div class="rounded-lg border p-4" style="border-color: var(--border); background-color: var(--surface)">
                            <p class="text-xs font-medium uppercase tracking-wide" style="color: var(--ink-faint)">Posts, latest cycle</p>
                            <p class="mt-1.5 font-display text-2xl font-bold" style="color: var(--ink)">{{ formatNumber(latest?.post_count) }}</p>
                            <p class="mt-0.5 text-xs" style="color: var(--ink-muted)">{{ latest?.label ?? '—' }}</p>
                        </div>
                    </div>

                    <!-- The chart: the whole point of this modal -->
                    <div class="mt-5 rounded-lg border p-4" style="border-color: var(--border); background-color: var(--surface)">
                        <h3 class="text-sm font-semibold" style="color: var(--ink)">Median views per post, by cycle</h3>
                        <div class="mt-3 h-64">
                            <canvas ref="chartCanvas"></canvas>
                        </div>
                    </div>

                    <!-- Per-cycle detail table -->
                    <div class="mt-5 overflow-hidden rounded-lg border" style="border-color: var(--border); background-color: var(--surface)">
                        <table class="min-w-full">
                            <thead>
                                <tr style="border-bottom: 1px solid var(--border)">
                                    <th class="px-4 py-2.5 text-left text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Cycle</th>
                                    <th class="px-4 py-2.5 text-right text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Median views</th>
                                    <th class="px-4 py-2.5 text-right text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Δ vs prior</th>
                                    <th class="px-4 py-2.5 text-right text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Posts</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr v-for="point in [...series].reverse()" :key="point.cycle_id" style="border-bottom: 1px solid var(--border)">
                                    <td class="px-4 py-2.5 text-sm font-medium" style="color: var(--ink)">{{ point.label }}</td>
                                    <td class="px-4 py-2.5 text-right text-sm tabular-nums" style="color: var(--ink)">{{ formatNumber(point.avg_views) }}</td>
                                    <td class="px-4 py-2.5 text-right text-sm font-semibold tabular-nums" :style="`color: ${deltaColor(point.delta_pct)}`">
                                        {{ formatDelta(point.delta_pct) }}
                                    </td>
                                    <td class="px-4 py-2.5 text-right text-sm tabular-nums" style="color: var(--ink-muted)">{{ point.post_count }}</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </template>
            </div>
        </div>
    </div>
</template>
