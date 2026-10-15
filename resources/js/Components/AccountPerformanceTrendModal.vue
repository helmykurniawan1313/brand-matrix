<script setup>
import { computed, nextTick, onBeforeUnmount, onMounted, ref, watch } from 'vue';
import Chart from '../chartSetup';
import StatusBadge from './StatusBadge.vue';

const props = defineProps({
    accountId: { type: Number, required: true },
    accountName: { type: String, required: true },
    platform: { type: String, required: true },
});

const emit = defineEmits(['close']);

const loading = ref(true);
const error = ref(null);
const series = ref([]);
const platformLabel = computed(() => (props.platform === 'tiktok' ? 'TikTok' : 'Instagram'));

const chartCanvas = ref(null);
let chart = null;

const cssVar = (name) => getComputedStyle(document.documentElement).getPropertyValue(name).trim();

// Fixed categorical order, never cycled — same accent-first palette used
// elsewhere in the app (AccountGrowthModal/ContentInsightDetailModal) plus one
// additional hue for Health, since this chart has 4 series, not 3.
const palette = () => [
    cssVar('--accent') || '#0f6e63',
    '#c2410c',
    '#7c3aed',
    '#1d4ed8',
];

const metricSeries = [
    { key: 'growth_rate', label: 'Growth', suffix: '%' },
    { key: 'visibility_rate', label: 'Visibility', suffix: '' },
    { key: 'engagement_score', label: 'Engagement', suffix: '' },
    { key: 'health_rate', label: 'Health', suffix: '' },
];

const loadTrend = async () => {
    loading.value = true;
    error.value = null;

    try {
        const response = await fetch(`/account-performance/${props.accountId}/trend?platform=${props.platform}`, {
            headers: { Accept: 'application/json' },
        });

        if (!response.ok) throw new Error('Failed to load trend.');

        const data = await response.json();
        series.value = data.series ?? [];

        if (series.value.length === 0) {
            error.value = 'No cycles recorded for this account on this platform.';
        }
    } catch (e) {
        error.value = e.message;
    } finally {
        loading.value = false;
    }
};

const destroyChart = () => {
    chart?.destroy();
    chart = null;
};

const renderChart = async () => {
    await nextTick();
    destroyChart();
    if (!chartCanvas.value || series.value.length < 2) return;

    const colors = palette();
    const gridColor = cssVar('--border') || '#e0e6e4';
    const inkMuted = cssVar('--ink-muted') || '#566469';
    const surface = cssVar('--surface') || '#ffffff';

    chart = new Chart(chartCanvas.value, {
        type: 'line',
        data: {
            labels: series.value.map((point) => point.month),
            datasets: metricSeries.map((metric, i) => ({
                label: metric.label,
                data: series.value.map((point) => point[metric.key]),
                borderColor: colors[i],
                backgroundColor: colors[i],
                pointBackgroundColor: colors[i],
                pointBorderColor: surface,
                pointBorderWidth: 1.5,
                pointRadius: 3,
                borderWidth: 2,
                fill: false,
                tension: 0.25,
            })),
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    position: 'bottom',
                    labels: { color: inkMuted, boxWidth: 10, boxHeight: 10, usePointStyle: true },
                },
                tooltip: {
                    callbacks: {
                        label: (ctx) => `${ctx.dataset.label}: ${ctx.parsed.y}`,
                    },
                },
            },
            scales: {
                x: { grid: { display: false }, ticks: { color: inkMuted } },
                y: {
                    beginAtZero: true,
                    grid: { color: gridColor },
                    ticks: { color: inkMuted },
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

watch(series, renderWithGeneration);

onMounted(() => {
    loadTrend();
});

onBeforeUnmount(destroyChart);

const latest = computed(() => (series.value.length ? series.value[series.value.length - 1] : null));

const monthLabel = (m) => m;
const round = (v) => (v === null || v === undefined ? '—' : Math.round(v * 10) / 10);
</script>

<template>
    <div class="fixed inset-0 z-10 flex items-center justify-center bg-black/50 px-4 backdrop-blur-sm">
        <div
            class="flex max-h-[85vh] w-full max-w-3xl flex-col overflow-hidden rounded-xl border shadow-2xl"
            style="background-color: var(--surface-raised); border-color: var(--border)"
        >
            <div class="flex shrink-0 items-start justify-between gap-4 border-b px-6 py-5" style="border-color: var(--border)">
                <div class="min-w-0">
                    <div class="flex flex-wrap items-center gap-2">
                        <h2 class="truncate font-display text-lg font-bold" style="color: var(--ink)">{{ accountName }}</h2>
                        <span
                            class="shrink-0 rounded px-1.5 py-0.5 text-[10px] font-semibold uppercase tracking-wide"
                            style="background-color: var(--accent-soft); color: var(--accent)"
                        >
                            {{ platformLabel }}
                        </span>
                        <StatusBadge v-if="latest" :status="latest.health_label" />
                    </div>
                    <p class="mt-0.5 text-sm" style="color: var(--ink-muted)">
                        Growth, Visibility, Engagement, and Health — one cycle per month, oldest to latest.
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

            <div class="min-h-0 flex-1 overflow-y-auto px-6 py-5">
                <div v-if="loading" class="flex items-center justify-center py-20 text-sm" style="color: var(--ink-faint)">
                    Loading trend…
                </div>

                <div v-else-if="error" class="flex items-center justify-center py-20 text-sm" style="color: var(--ink-faint)">
                    {{ error }}
                </div>

                <template v-else>
                    <div class="h-72">
                        <canvas ref="chartCanvas"></canvas>
                    </div>

                    <div class="mt-6 overflow-hidden rounded-lg border" style="border-color: var(--border)">
                        <table class="min-w-full">
                            <thead>
                                <tr style="border-bottom: 1px solid var(--border)">
                                    <th class="px-3 py-2 text-left text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Month</th>
                                    <th class="px-3 py-2 text-left text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Growth</th>
                                    <th class="px-3 py-2 text-left text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Visibility</th>
                                    <th class="px-3 py-2 text-left text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Engagement</th>
                                    <th class="px-3 py-2 text-left text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Health Rate</th>
                                    <th class="px-3 py-2 text-left text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Health</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr v-for="point in [...series].reverse()" :key="point.cycle_start_date" style="border-bottom: 1px solid var(--border)">
                                    <td class="px-3 py-2.5 text-sm" style="color: var(--ink)">{{ monthLabel(point.month) }}</td>
                                    <td class="px-3 py-2.5 text-sm tabular-nums" style="color: var(--ink-muted)">{{ round(point.growth_rate) }}%</td>
                                    <td class="px-3 py-2.5 text-sm tabular-nums" style="color: var(--ink-muted)">{{ round(point.visibility_rate) }}</td>
                                    <td class="px-3 py-2.5 text-sm tabular-nums" style="color: var(--ink-muted)">{{ round(point.engagement_score) }}</td>
                                    <td class="px-3 py-2.5 text-sm tabular-nums" style="color: var(--ink)">{{ round(point.health_rate) }}</td>
                                    <td class="px-3 py-2.5 text-sm">
                                        <StatusBadge :status="point.health_label" />
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </template>
            </div>
        </div>
    </div>
</template>
