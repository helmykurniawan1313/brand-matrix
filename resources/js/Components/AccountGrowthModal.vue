<script setup>
import { nextTick, onBeforeUnmount, ref, watch } from 'vue';
import Chart from 'chart.js/auto';

const props = defineProps({
    account: {
        type: Object,
        required: true,
    },
    defaultAiProvider: {
        type: String,
        default: 'groq',
    },
});

const emit = defineEmits(['close']);

const loading = ref(true);
const error = ref(null);
const cycles = ref([]);

const tabs = [
    { key: 'instagram', label: 'Instagram' },
    { key: 'tiktok', label: 'TikTok' },
    { key: 'ai-summary', label: 'AI Summary' },
];

const activeTab = ref('instagram');

const platformCycles = (platform) => cycles.value.filter((c) => (c.platform ?? 'instagram') === platform);

const chartSections = [
    { key: 'overview', title: 'Growth' },
    { key: 'volume', title: 'Volume' },
    { key: 'story-performance', title: 'Story Performance' },
    { key: 'scores', title: 'Scores' },
    { key: 'engagement-rate', title: 'Engagement Rate' },
];

const chartConfigs = {
    overview: [
        { key: 'end_follower', label: 'Followers', suffix: '', single: true },
        { key: 'growth_rate', label: 'Growth Rate', suffix: '%', single: true },
    ],
    volume: [
        { key: 'reach', label: 'Reach', suffix: '', single: true },
        { key: 'views', label: 'Views', suffix: '', single: true },
        { key: 'engagement', label: 'Engagement', suffix: '', single: true },
    ],
    'story-performance': [
        { key: 'story_performance', label: 'Story Performance', suffix: '', single: true },
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
        pointRadius: 3,
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
                legend: { display: config.combined, labels: { color: inkFaint } },
                tooltip: {
                    callbacks: {
                        label: (context) => `${context.dataset.label}: ${formatValue(context.parsed.y, config.suffix)}`,
                    },
                },
            },
            scales: {
                x: {
                    ticks: { color: inkFaint },
                    grid: { color: border },
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
    const dataCycles = platformCycles(activeTab.value);
    allChartConfigs().forEach((config) => renderChart(config, dataCycles));
};

watch(activeTab, renderAllCharts);

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
                    legend: { display: config.combined, labels: { color: '#12181a' } },
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
        const dataCycles = platformCycles(activeTab.value === 'tiktok' ? 'tiktok' : 'instagram');
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

                <div v-else class="space-y-8">
                    <section v-for="section in chartSections" :key="section.key">
                        <h3 class="font-display text-sm font-bold" style="color: var(--ink)">{{ section.title }}</h3>
                        <div
                            class="mt-3 grid grid-cols-1 gap-6"
                            :class="{
                                'sm:grid-cols-2': chartConfigs[section.key].length === 2,
                                'sm:grid-cols-2 xl:grid-cols-3': chartConfigs[section.key].length >= 3,
                            }"
                        >
                            <div v-for="config in chartConfigs[section.key]" :key="config.key">
                                <p class="mb-2 text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">
                                    {{ config.label }}
                                </p>
                                <div class="relative" style="height: 260px">
                                    <canvas :ref="(el) => setCanvasRef(config.key, el)"></canvas>
                                </div>
                            </div>
                        </div>
                    </section>
                </div>
            </div>
        </div>
    </div>
</template>
