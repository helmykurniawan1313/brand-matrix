<script setup>
import { computed, nextTick, onBeforeUnmount, onMounted, ref, watch } from 'vue';
import Chart from '../chartSetup';
import MonthRangePicker from './MonthRangePicker.vue';

const props = defineProps({
    employee: {
        type: Object,
        required: true,
    },
});

const emit = defineEmits(['close']);

const loading = ref(true);
const error = ref(null);
const posts = ref([]);
const series = ref([]);
const asPmCount = ref(0);
const asConceptorCount = ref(0);

// An employee can be credited as Project Manager on some posts and Conceptor
// on others — a role tab switches which credit this view is showing, instead
// of blending two different kinds of "what they did" into one list.
const activeRole = ref('project_manager_id');

// Trend (chart + median/max/min/reels) is the headline view; Content (the
// individual post list) is the drill-down — same split used elsewhere in
// this app (e.g. the PM/Conceptor ranking modal).
const activeView = ref('trend');

const platformLabel = (p) => (p === 'tiktok' ? 'TikTok' : 'Instagram');
const formatDate = (d) => (d ? new Date(d).toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric' }) : '—');
const formatNumber = (v) => (v === null || v === undefined ? '—' : new Intl.NumberFormat('en-US').format(v));

// Month range filter — both endpoints (posts + series) take the same
// month_from/month_to, so the chart, the headline stats, and the post list
// all stay scoped to whatever range is picked.
const monthFrom = ref('');
const monthTo = ref('');
const hasRange = computed(() => !!monthFrom.value || !!monthTo.value);
const rangePickerOpen = ref(false);
const rangePickerRef = ref(null);

const formatMonthLabel = (ym) => {
    if (!ym) return '';
    const [y, m] = ym.split('-');
    return new Date(Number(y), Number(m) - 1, 1).toLocaleString('en-US', { month: 'short', year: 'numeric' });
};

const clearRange = () => {
    monthFrom.value = '';
    monthTo.value = '';
    rangePickerOpen.value = false;
};

const onClickOutsideRange = (event) => {
    if (rangePickerOpen.value && rangePickerRef.value && !rangePickerRef.value.contains(event.target)) {
        rangePickerOpen.value = false;
    }
};
onMounted(() => document.addEventListener('click', onClickOutsideRange));
onBeforeUnmount(() => document.removeEventListener('click', onClickOutsideRange));

const filterParams = () => {
    const params = new URLSearchParams({ role: activeRole.value });
    if (monthFrom.value) params.set('month_from', monthFrom.value);
    if (monthTo.value) params.set('month_to', monthTo.value || monthFrom.value);
    return params;
};

const loadPosts = async () => {
    const response = await fetch(`/employees/${props.employee.id}/posts?${filterParams().toString()}`, {
        headers: { Accept: 'application/json' },
    });
    if (!response.ok) throw new Error('Failed to load content.');
    const data = await response.json();
    posts.value = data.posts ?? [];
    asPmCount.value = data.as_project_manager_count ?? 0;
    asConceptorCount.value = data.as_conceptor_count ?? 0;
};

const chartCanvas = ref(null);
let chart = null;
const getCssVar = (name) => getComputedStyle(document.documentElement).getPropertyValue(name).trim();
const destroyChart = () => {
    chart?.destroy();
    chart = null;
};

const renderChart = async () => {
    await nextTick();
    destroyChart();
    if (!chartCanvas.value || series.value.length === 0) return;

    const accentColor = getCssVar('--accent') || '#0f6e63';
    const gridColor = getCssVar('--border') || '#e0e6e4';
    const inkMuted = getCssVar('--ink-muted') || '#566469';
    const surface = getCssVar('--surface') || '#ffffff';

    chart = new Chart(chartCanvas.value, {
        type: 'line',
        data: {
            labels: series.value.map((point) => point.label),
            datasets: [
                {
                    label: 'Median',
                    data: series.value.map((point) => point.median_views),
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
                        label: (ctx) => `Median: ${new Intl.NumberFormat('en-US').format(ctx.parsed.y)}`,
                    },
                },
            },
            scales: {
                x: { grid: { display: false }, ticks: { color: inkMuted } },
                y: {
                    beginAtZero: true,
                    grid: { color: gridColor },
                    ticks: { color: inkMuted, callback: (value) => formatNumber(value) },
                },
            },
        },
    });
};

const loadSeries = async () => {
    const response = await fetch(`/employees/${props.employee.id}/series?${filterParams().toString()}`, {
        headers: { Accept: 'application/json' },
    });
    if (!response.ok) throw new Error('Failed to load trend.');
    const data = await response.json();
    series.value = data.series ?? [];
};

const load = async () => {
    loading.value = true;
    error.value = null;

    try {
        await Promise.all([loadPosts(), loadSeries()]);

        if (posts.value.length === 0) {
            error.value = `No posts credited to ${props.employee.name} as ${activeRole.value === 'project_manager_id' ? 'Project Manager' : 'Conceptor'}${hasRange.value ? ' in this range' : ''}.`;
        }
    } catch (e) {
        error.value = e.message;
    } finally {
        // loading must flip false (and the DOM re-render into the 'trend'
        // branch) before the canvas element exists to render into — doing
        // this inside loadSeries() ran too early, while the template was
        // still showing the loading state, so chartCanvas.value was null and
        // the chart silently never rendered.
        loading.value = false;
        await renderChart();
    }
};

watch([activeRole, monthFrom, monthTo], load);
watch(activeView, (view) => {
    if (view === 'trend') renderChart();
});

load();

onBeforeUnmount(destroyChart);

// Headline stats across the (filtered) series — median of the per-month
// medians, overall max/min across all months, and total reels produced.
const headlineStats = computed(() => {
    if (series.value.length === 0) {
        return { median: null, max: null, min: null, totalReels: 0 };
    }

    const medians = series.value.map((p) => p.median_views).sort((a, b) => a - b);
    const mid = Math.floor(medians.length / 2);
    const median = medians.length % 2 === 0 ? Math.round((medians[mid - 1] + medians[mid]) / 2) : medians[mid];

    return {
        median,
        max: Math.max(...series.value.map((p) => p.max_views)),
        min: Math.min(...series.value.map((p) => p.min_views)),
        totalReels: series.value.reduce((sum, p) => sum + p.post_count, 0),
    };
});
</script>

<template>
    <div class="fixed inset-0 z-10 flex items-center justify-center bg-black/50 px-4 py-6 backdrop-blur-sm">
        <div
            class="flex h-[85vh] w-full max-w-4xl flex-col overflow-hidden rounded-lg border shadow-2xl"
            style="background-color: var(--surface-raised); border-color: var(--border)"
        >
            <!-- Header -->
            <div class="flex shrink-0 items-start justify-between gap-4 px-6 pt-5 pb-3">
                <div class="min-w-0">
                    <h2 class="font-display text-lg font-bold leading-tight" style="color: var(--ink)">{{ employee.name }}</h2>
                    <p class="mt-1 text-sm" style="color: var(--ink-muted)">{{ employee.position || employee.department?.name || '—' }}</p>
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

            <!-- Role tabs -->
            <div class="flex shrink-0 gap-6 border-b px-6" style="border-color: var(--border)">
                <button
                    type="button"
                    class="relative -mb-px border-b-2 pb-2.5 pt-1 text-sm font-semibold transition-colors"
                    :style="
                        activeRole === 'project_manager_id'
                            ? 'border-color: var(--accent); color: var(--ink)'
                            : 'border-color: transparent; color: var(--ink-faint)'
                    "
                    @click="activeRole = 'project_manager_id'"
                >
                    As Project Manager
                    <span v-if="asPmCount" class="ml-1 text-xs" style="color: var(--ink-faint)">({{ asPmCount }})</span>
                </button>
                <button
                    type="button"
                    class="relative -mb-px border-b-2 pb-2.5 pt-1 text-sm font-semibold transition-colors"
                    :style="
                        activeRole === 'conceptor_id'
                            ? 'border-color: var(--accent); color: var(--ink)'
                            : 'border-color: transparent; color: var(--ink-faint)'
                    "
                    @click="activeRole = 'conceptor_id'"
                >
                    As Conceptor
                    <span v-if="asConceptorCount" class="ml-1 text-xs" style="color: var(--ink-faint)">({{ asConceptorCount }})</span>
                </button>
            </div>

            <!-- Filter panel: month range -->
            <div class="flex shrink-0 flex-wrap items-center gap-2 px-6 pt-3">
                <div ref="rangePickerRef" class="relative">
                    <button
                        type="button"
                        class="inline-flex items-center gap-1.5 rounded-lg border px-2.5 py-1.5 text-xs font-medium transition-colors hover:opacity-80"
                        :style="
                            hasRange
                                ? 'border-color: var(--accent); background-color: var(--accent-soft); color: var(--accent)'
                                : 'border-color: var(--border); background-color: var(--surface); color: var(--ink-muted)'
                        "
                        @click="rangePickerOpen = !rangePickerOpen"
                    >
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-3.5 w-3.5">
                            <rect x="3" y="4" width="18" height="18" rx="2" />
                            <path d="M3 10h18M8 2v4M16 2v4" />
                        </svg>
                        <template v-if="hasRange">
                            {{ formatMonthLabel(monthFrom) || '…' }} → {{ formatMonthLabel(monthTo || monthFrom) }}
                        </template>
                        <template v-else>All time</template>
                    </button>

                    <div v-if="rangePickerOpen" class="absolute left-0 top-full z-20 mt-2 w-72 shadow-xl">
                        <MonthRangePicker
                            v-model:model-from="monthFrom"
                            v-model:model-to="monthTo"
                            class="!max-w-none"
                        />
                        <button
                            type="button"
                            class="mt-2 w-full rounded-md py-1.5 text-xs font-semibold transition-opacity hover:opacity-90"
                            style="background-color: var(--accent); color: var(--accent-ink)"
                            @click="rangePickerOpen = false"
                        >
                            Done
                        </button>
                    </div>
                </div>

                <button
                    v-if="hasRange"
                    type="button"
                    class="text-xs font-medium transition-opacity hover:opacity-70"
                    style="color: var(--accent)"
                    @click="clearRange"
                >
                    Reset
                </button>

                <!-- Trend/Content view switcher, pushed to the right -->
                <div class="ml-auto flex gap-1 rounded-lg border p-1" style="border-color: var(--border); background-color: var(--surface)">
                    <button
                        type="button"
                        class="rounded-md px-3 py-1 text-xs font-semibold transition-colors"
                        :style="
                            activeView === 'trend'
                                ? 'background-color: var(--accent); color: var(--accent-ink)'
                                : 'color: var(--ink-muted)'
                        "
                        @click="activeView = 'trend'"
                    >
                        Trend
                    </button>
                    <button
                        type="button"
                        class="rounded-md px-3 py-1 text-xs font-semibold transition-colors"
                        :style="
                            activeView === 'content'
                                ? 'background-color: var(--accent); color: var(--accent-ink)'
                                : 'color: var(--ink-muted)'
                        "
                        @click="activeView = 'content'"
                    >
                        Content
                    </button>
                </div>
            </div>

            <!-- Body -->
            <div class="min-h-0 flex-1 overflow-y-auto px-6 pb-6" style="background-color: var(--surface-raised)">
                <div v-if="loading" class="flex h-40 items-center justify-center">
                    <span class="text-sm" style="color: var(--ink-faint)">Loading…</span>
                </div>

                <div v-else-if="error" class="flex h-40 flex-col items-center justify-center gap-1 text-center">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" class="h-8 w-8" style="color: var(--ink-faint)">
                        <path d="M3 3v18h18" />
                        <path d="m19 9-5 5-4-4-3 3" />
                    </svg>
                    <p class="text-sm" style="color: var(--ink-faint)">{{ error }}</p>
                </div>

                <template v-else-if="activeView === 'trend'">
                    <!-- Headline stats -->
                    <div class="mt-3 grid grid-cols-2 gap-3 sm:grid-cols-4">
                        <div class="rounded-lg border p-3" style="border-color: var(--border); background-color: var(--surface)">
                            <p class="text-[11px] font-medium uppercase tracking-wide" style="color: var(--ink-faint)">Median</p>
                            <p class="mt-1 font-display text-xl font-bold tabular-nums" style="color: var(--ink)">{{ formatNumber(headlineStats.median) }}</p>
                        </div>
                        <div class="rounded-lg border p-3" style="border-color: var(--border); background-color: var(--surface)">
                            <p class="text-[11px] font-medium uppercase tracking-wide" style="color: var(--ink-faint)">Max</p>
                            <p class="mt-1 font-display text-xl font-bold tabular-nums" style="color: var(--ink)">{{ formatNumber(headlineStats.max) }}</p>
                        </div>
                        <div class="rounded-lg border p-3" style="border-color: var(--border); background-color: var(--surface)">
                            <p class="text-[11px] font-medium uppercase tracking-wide" style="color: var(--ink-faint)">Min</p>
                            <p class="mt-1 font-display text-xl font-bold tabular-nums" style="color: var(--ink)">{{ formatNumber(headlineStats.min) }}</p>
                        </div>
                        <div class="rounded-lg border p-3" style="border-color: var(--border); background-color: var(--surface)">
                            <p class="text-[11px] font-medium uppercase tracking-wide" style="color: var(--ink-faint)">Total Reels</p>
                            <p class="mt-1 font-display text-xl font-bold tabular-nums" style="color: var(--ink)">{{ formatNumber(headlineStats.totalReels) }}</p>
                        </div>
                    </div>

                    <!-- Chart -->
                    <div class="mt-4 rounded-lg border p-4" style="border-color: var(--border); background-color: var(--surface)">
                        <h3 class="text-sm font-semibold" style="color: var(--ink)">Median views, by month</h3>
                        <div class="mt-3 h-64">
                            <canvas ref="chartCanvas"></canvas>
                        </div>
                    </div>

                    <!-- Per-month table -->
                    <div class="mt-4 overflow-hidden rounded-lg border" style="border-color: var(--border); background-color: var(--surface)">
                        <table class="min-w-full">
                            <thead>
                                <tr style="border-bottom: 1px solid var(--border)">
                                    <th class="px-4 py-2.5 text-left text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Month</th>
                                    <th class="px-4 py-2.5 text-right text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Total</th>
                                    <th class="px-4 py-2.5 text-right text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Min</th>
                                    <th class="px-4 py-2.5 text-right text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Max</th>
                                    <th class="px-4 py-2.5 text-right text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Median</th>
                                    <th class="px-4 py-2.5 text-right text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Reels</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr v-for="point in [...series].reverse()" :key="point.month" style="border-bottom: 1px solid var(--border)">
                                    <td class="px-4 py-2.5 text-sm font-medium" style="color: var(--ink)">{{ point.label }}</td>
                                    <td class="px-4 py-2.5 text-right text-sm tabular-nums" style="color: var(--ink-muted)">{{ formatNumber(point.total_views) }}</td>
                                    <td class="px-4 py-2.5 text-right text-sm tabular-nums" style="color: var(--ink-muted)">{{ formatNumber(point.min_views) }}</td>
                                    <td class="px-4 py-2.5 text-right text-sm tabular-nums" style="color: var(--ink-muted)">{{ formatNumber(point.max_views) }}</td>
                                    <td class="px-4 py-2.5 text-right text-sm tabular-nums" style="color: var(--ink)">{{ formatNumber(point.median_views) }}</td>
                                    <td class="px-4 py-2.5 text-right text-sm tabular-nums" style="color: var(--ink-muted)">{{ point.post_count }}</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </template>

                <template v-else>
                    <p class="py-3 text-xs" style="color: var(--ink-faint)">
                        {{ posts.length }} post{{ posts.length === 1 ? '' : 's' }}
                    </p>
                    <table class="min-w-full">
                        <thead class="sticky top-0" style="background-color: var(--surface-raised)">
                            <tr style="border-bottom: 1px solid var(--border)">
                                <th class="py-2.5 text-left text-[11px] font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Account</th>
                                <th class="py-2.5 text-left text-[11px] font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Platform</th>
                                <th class="py-2.5 text-left text-[11px] font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Date</th>
                                <th class="py-2.5 text-right text-[11px] font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Views</th>
                                <th class="py-2.5 pl-3 text-left text-[11px] font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Ads</th>
                                <th class="py-2.5 pl-3 text-left text-[11px] font-semibold uppercase tracking-wide" style="color: var(--ink-faint)"></th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr v-for="post in posts" :key="post.id" style="border-bottom: 1px solid var(--border)">
                                <td class="py-3 text-sm font-medium" style="color: var(--ink)">{{ post.account_name }}</td>
                                <td class="py-3 text-sm" style="color: var(--ink-muted)">{{ platformLabel(post.platform) }}</td>
                                <td class="py-3 text-sm tabular-nums" style="color: var(--ink-muted)">{{ formatDate(post.post_date) }}</td>
                                <td class="py-3 text-right text-sm font-semibold tabular-nums" style="color: var(--ink)">{{ formatNumber(post.views) }}</td>
                                <td class="py-3 pl-3 text-sm" style="color: var(--ink-muted)">{{ post.ads ? 'Yes' : 'No' }}</td>
                                <td class="py-3 pl-3 text-right">
                                    <a
                                        v-if="post.link"
                                        :href="post.link"
                                        target="_blank"
                                        rel="noopener"
                                        class="text-xs font-medium transition-opacity hover:opacity-70"
                                        style="color: var(--accent)"
                                    >
                                        View
                                    </a>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </template>
            </div>
        </div>
    </div>
</template>
