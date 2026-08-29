<script setup>
import { computed, nextTick, onBeforeUnmount, onMounted, ref, watch } from 'vue';
import { router } from '@inertiajs/vue3';
import Chart from '../../chartSetup';
import AppLayout from '../../Layouts/AppLayout.vue';

import StatCard from '../../Components/StatCard.vue';
import MonthPicker from '../../Components/MonthPicker.vue';

defineOptions({ layout: AppLayout });

const props = defineProps({
    filters: {
        type: Object,
        default: () => ({ platform: 'all', range: 'all' }),
    },
    platformCounts: {
        type: Object,
        default: () => ({}),
    },
    cycleData: {
        type: Object,
        default: () => ({}),
    },
    performanceData: {
        type: Object,
        default: () => ({}),
    },
});

const getCssVar = (name) => getComputedStyle(document.documentElement).getPropertyValue(name).trim();

// Status ramp shared by every distribution chart — same PARAH..SIP colors StatusBadge
// uses everywhere else, so a chart's bars carry the same meaning as a badge at a glance
// instead of one flat accent color that says nothing about severity.
const statusColorFor = (tier) => {
    const key = (tier ?? '').toString().toUpperCase();
    const varName = {
        SIP: '--status-sip-ink',
        BAGUS: '--status-bagus-ink',
        CUKUP: '--status-cukup-ink',
        KURANG: '--status-kurang-ink',
        PARAH: '--status-parah-ink',
    }[key];
    return varName ? getCssVar(varName) || getCssVar('--accent') : getCssVar('--accent');
};

// Tabs — Cycles vs Performance, each with its own dataset/summary but sharing the platform/range filters.

const activeTab = ref('cycles');

// Platform / time-range filters — reflected in the URL so links/refreshes preserve state.

const platformFilter = ref(props.filters.platform ?? 'all');
const rangeFilter = ref(props.filters.range ?? 'all');

const activeAvailableMonths = computed(() =>
    (activeTab.value === 'cycles' ? props.cycleData.availableMonths : props.performanceData.availableMonths) ?? [],
);

const applyFilters = () => {
    router.get(
        '/dashboard',
        { platform: platformFilter.value, range: rangeFilter.value },
        { preserveState: true, preserveScroll: true, replace: true },
    );
};

watch(() => props.filters, (value) => {
    platformFilter.value = value.platform ?? 'all';
    rangeFilter.value = value.range ?? 'all';
});

// Switching tabs can invalidate the selected month (each dataset has its own available months),
// so reset range to "all" when it no longer applies to the newly active tab.
watch(activeTab, () => {
    if (rangeFilter.value !== 'all' && !activeAvailableMonths.value.includes(rangeFilter.value)) {
        rangeFilter.value = 'all';
        applyFilters();
    }
});

// Cycles tab — Health distribution bar chart + monthly trend line chart.

const healthCanvas = ref(null);
let healthChart = null;

const renderHealthChart = () => {
    if (!healthCanvas.value) return;
    healthChart?.destroy();

    const inkFaint = getCssVar('--ink-faint') || '#8b979b';
    const border = getCssVar('--border') || '#d8dedc';

    const tiers = props.cycleData.healthDistribution?.tiers ?? [];
    const counts = props.cycleData.healthDistribution?.counts ?? {};

    healthChart = new Chart(healthCanvas.value, {
        type: 'bar',
        data: {
            labels: tiers,
            datasets: [
                {
                    label: 'Cycles',
                    data: tiers.map((tier) => counts[tier] ?? 0),
                    backgroundColor: tiers.map((tier) => statusColorFor(tier)),
                    borderRadius: 4,
                    maxBarThickness: 40,
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
                        label: (context) => `${context.parsed.y} cycle${context.parsed.y === 1 ? '' : 's'}`,
                    },
                },
            },
            scales: {
                x: { ticks: { color: inkFaint }, grid: { display: false } },
                y: { beginAtZero: true, ticks: { color: inkFaint, precision: 0 }, grid: { color: border } },
            },
        },
    });
};

const cycleTrendCanvas = ref(null);
let cycleTrendChart = null;

const renderCycleTrendChart = () => {
    if (!cycleTrendCanvas.value) return;
    cycleTrendChart?.destroy();

    const inkFaint = getCssVar('--ink-faint') || '#8b979b';
    const border = getCssVar('--border') || '#d8dedc';
    const accent = getCssVar('--accent') || '#0f766e';

    const trend = props.cycleData.monthlyTrend ?? [];

    cycleTrendChart = new Chart(cycleTrendCanvas.value, {
        type: 'line',
        data: {
            labels: trend.map((row) => row.label),
            datasets: [
                {
                    label: 'Cycles Added',
                    data: trend.map((row) => row.count),
                    borderColor: accent,
                    backgroundColor: accent,
                    pointBackgroundColor: accent,
                    pointBorderColor: getCssVar('--surface') || '#ffffff',
                    pointBorderWidth: 2,
                    pointRadius: 4,
                    borderWidth: 2,
                    tension: 0.3,
                    fill: false,
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
                        label: (context) => `${context.parsed.y} cycle${context.parsed.y === 1 ? '' : 's'}`,
                    },
                },
            },
            scales: {
                x: { ticks: { color: inkFaint }, grid: { display: false } },
                y: { beginAtZero: true, ticks: { color: inkFaint, precision: 0 }, grid: { color: border } },
            },
        },
    });
};

// Performance tab — Views status distribution bar chart + monthly trend line chart.

const viewsCanvas = ref(null);
let viewsChart = null;

const renderViewsChart = () => {
    if (!viewsCanvas.value) return;
    viewsChart?.destroy();

    const inkFaint = getCssVar('--ink-faint') || '#8b979b';
    const border = getCssVar('--border') || '#d8dedc';

    const tiers = props.performanceData.viewsDistribution?.tiers ?? [];
    const counts = props.performanceData.viewsDistribution?.counts ?? {};

    viewsChart = new Chart(viewsCanvas.value, {
        type: 'bar',
        data: {
            labels: tiers,
            datasets: [
                {
                    label: 'Posts',
                    data: tiers.map((tier) => counts[tier] ?? 0),
                    backgroundColor: tiers.map((tier) => statusColorFor(tier)),
                    borderRadius: 4,
                    maxBarThickness: 40,
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
                        label: (context) => `${context.parsed.y} post${context.parsed.y === 1 ? '' : 's'}`,
                    },
                },
            },
            scales: {
                x: { ticks: { color: inkFaint }, grid: { display: false } },
                y: { beginAtZero: true, ticks: { color: inkFaint, precision: 0 }, grid: { color: border } },
            },
        },
    });
};

const performanceTrendCanvas = ref(null);
let performanceTrendChart = null;

const renderPerformanceTrendChart = () => {
    if (!performanceTrendCanvas.value) return;
    performanceTrendChart?.destroy();

    const inkFaint = getCssVar('--ink-faint') || '#8b979b';
    const border = getCssVar('--border') || '#d8dedc';
    const accent = getCssVar('--accent') || '#0f766e';

    const trend = props.performanceData.monthlyTrend ?? [];

    performanceTrendChart = new Chart(performanceTrendCanvas.value, {
        type: 'line',
        data: {
            labels: trend.map((row) => row.label),
            datasets: [
                {
                    label: 'Posts Added',
                    data: trend.map((row) => row.count),
                    borderColor: accent,
                    backgroundColor: accent,
                    pointBackgroundColor: accent,
                    pointBorderColor: getCssVar('--surface') || '#ffffff',
                    pointBorderWidth: 2,
                    pointRadius: 4,
                    borderWidth: 2,
                    tension: 0.3,
                    fill: false,
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
                        label: (context) => `${context.parsed.y} post${context.parsed.y === 1 ? '' : 's'}`,
                    },
                },
            },
            scales: {
                x: { ticks: { color: inkFaint }, grid: { display: false } },
                y: { beginAtZero: true, ticks: { color: inkFaint, precision: 0 }, grid: { color: border } },
            },
        },
    });
};

// Cycles tab — platform breakdown pie chart.

const platformPieCanvas = ref(null);
let platformPieChart = null;

const renderPlatformPieChart = () => {
    if (!platformPieCanvas.value) return;
    platformPieChart?.destroy();

    const surface = getCssVar('--surface') || '#ffffff';
    const instagramColor = '#e1306c';
    const tiktokColor = '#010101';

    platformPieChart = new Chart(platformPieCanvas.value, {
        type: 'pie',
        data: {
            labels: ['Instagram', 'TikTok'],
            datasets: [
                {
                    data: [props.platformCounts.instagram ?? 0, props.platformCounts.tiktok ?? 0],
                    backgroundColor: [instagramColor, tiktokColor],
                    borderColor: surface,
                    borderWidth: 2,
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
                        label: (context) => `${context.label}: ${context.parsed} cycle${context.parsed === 1 ? '' : 's'}`,
                    },
                },
            },
        },
    });
};

// Performance tab — platform breakdown pie chart.

const performancePlatformPieCanvas = ref(null);
let performancePlatformPieChart = null;

const renderPerformancePlatformPieChart = () => {
    if (!performancePlatformPieCanvas.value) return;
    performancePlatformPieChart?.destroy();

    const surface = getCssVar('--surface') || '#ffffff';
    const instagramColor = '#e1306c';
    const tiktokColor = '#010101';

    const counts = props.performanceData.platformCounts ?? {};

    performancePlatformPieChart = new Chart(performancePlatformPieCanvas.value, {
        type: 'pie',
        data: {
            labels: ['Instagram', 'TikTok'],
            datasets: [
                {
                    data: [counts.instagram ?? 0, counts.tiktok ?? 0],
                    backgroundColor: [instagramColor, tiktokColor],
                    borderColor: surface,
                    borderWidth: 2,
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
                        label: (context) => `${context.label}: ${context.parsed} post${context.parsed === 1 ? '' : 's'}`,
                    },
                },
            },
        },
    });
};

// Guards the resize RAF below against overlapping calls — onMounted fires once with
// whatever data is available immediately, and the watcher below fires again once a
// lazily-loaded Inertia prop actually resolves. A resize callback queued by the first
// call must not run after the second call has already destroyed and replaced the
// chart instances; bumping a token on every call lets a stale callback recognize
// it's been superseded and skip itself instead of resizing charts it doesn't own.
let renderGeneration = 0;

const renderActiveTabCharts = async () => {
    const thisGeneration = ++renderGeneration;

    await nextTick();
    if (activeTab.value === 'cycles') {
        renderHealthChart();
        renderCycleTrendChart();
        renderPlatformPieChart();
    } else {
        renderViewsChart();
        renderPerformanceTrendChart();
        renderPerformancePlatformPieChart();
    }

    // nextTick only guarantees Vue's DOM patch is applied — the browser may not have
    // finished layout yet, so a freshly-mounted canvas can report its pre-layout fallback
    // size (300x150) to Chart.js at construction time, locking in the wrong internal
    // render buffer. Explicitly resizing every chart on the next frame (after layout has
    // settled) forces each one to re-measure its real CSS-driven box and redraw correctly.
    requestAnimationFrame(() => {
        if (thisGeneration !== renderGeneration) return;
        [healthChart, cycleTrendChart, platformPieChart, viewsChart, performanceTrendChart, performancePlatformPieChart]
            .forEach((chart) => chart?.resize());
    });
};

watch(activeTab, renderActiveTabCharts);
watch(() => [props.cycleData, props.performanceData], renderActiveTabCharts);

onMounted(renderActiveTabCharts);

onBeforeUnmount(() => {
    healthChart?.destroy();
    cycleTrendChart?.destroy();
    platformPieChart?.destroy();
    viewsChart?.destroy();
    performanceTrendChart?.destroy();
    performancePlatformPieChart?.destroy();
});
</script>

<template>
        <h1 class="font-display text-2xl font-bold tracking-tight" style="color: var(--ink)">Dashboard</h1>
        <p class="mt-1 text-sm" style="color: var(--ink-muted)">
            A snapshot of accounts, cycles, and performance across Brand Matrix.
        </p>

        <div class="mt-5 flex gap-1 border-b" style="border-color: var(--border)">
            <button
                v-for="tab in [{ value: 'cycles', label: 'Cycles' }, { value: 'performance', label: 'Performance' }]"
                :key="tab.value"
                type="button"
                class="border-b-2 px-3 py-2.5 text-sm font-medium transition-colors"
                :style="
                    activeTab === tab.value
                        ? 'border-color: var(--accent); color: var(--accent)'
                        : 'border-color: transparent; color: var(--ink-muted)'
                "
                @click="activeTab = tab.value"
            >
                {{ tab.label }}
            </button>
        </div>

        <div class="mt-4 flex flex-wrap items-center gap-3">
            <span class="text-xs font-medium uppercase tracking-wide" style="color: var(--ink-faint)">Filter</span>
            <div class="flex items-center gap-1 rounded-md border p-1" style="border-color: var(--border); background-color: var(--surface)">
                <button
                    v-for="option in [{ value: 'all', label: 'All Platforms' }, { value: 'instagram', label: 'Instagram' }, { value: 'tiktok', label: 'TikTok' }]"
                    :key="option.value"
                    type="button"
                    class="rounded px-3 py-1.5 text-sm font-medium transition-colors"
                    :style="
                        platformFilter === option.value
                            ? 'background-color: var(--accent); color: var(--accent-ink)'
                            : 'color: var(--ink-muted)'
                    "
                    @click="platformFilter = option.value; applyFilters()"
                >
                    {{ option.label }}
                </button>
            </div>

            <MonthPicker
                v-model="rangeFilter"
                :available-months="activeAvailableMonths"
                class="w-44"
                @update:model-value="applyFilters"
            />
        </div>

        <!-- Cycles tab -->
        <template v-if="activeTab === 'cycles'">
            <div class="mt-6 grid grid-cols-2 gap-3 lg:grid-cols-4">
                <StatCard label="Accounts" :value="String(cycleData.summary?.accounts_count ?? 0)" />
                <StatCard label="Cycles Tracked" :value="String(cycleData.summary?.cycles_count ?? 0)" />
                <StatCard
                    label="Avg Health Rate"
                    :value="cycleData.summary?.avg_health_rate != null ? String(cycleData.summary.avg_health_rate) : '—'"
                />
                <StatCard label="Healthy (SIP)" :value="String(cycleData.summary?.healthy_cycles_count ?? 0)" hint="cycles at top tier" />
            </div>

            <!-- Needs Attention is the one number that should draw the eye — a status-colored
                 warning tile, not another neutral stat card carrying the same weight as the rest. -->
            <div
                v-if="(cycleData.summary?.at_risk_cycles_count ?? 0) > 0"
                class="mt-3 flex items-center gap-3 rounded-lg border p-4"
                style="border-color: var(--status-parah-ink); background-color: var(--status-parah-bg)"
            >
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-6 w-6 shrink-0" style="color: var(--status-parah-ink)">
                    <path d="M12 9v4m0 4h.01M10.29 3.86 1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0Z" />
                </svg>
                <div>
                    <p class="font-display text-lg font-bold" style="color: var(--status-parah-ink)">
                        {{ cycleData.summary.at_risk_cycles_count }} cycle{{ cycleData.summary.at_risk_cycles_count === 1 ? '' : 's' }} need{{ cycleData.summary.at_risk_cycles_count === 1 ? 's' : '' }} attention
                    </p>
                    <p class="text-xs" style="color: var(--status-parah-ink)">Health label is KURANG or PARAH.</p>
                </div>
            </div>
            <div
                v-else
                class="mt-3 flex items-center gap-3 rounded-lg border p-4"
                style="border-color: var(--status-sip-ink); background-color: var(--status-sip-bg)"
            >
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-6 w-6 shrink-0" style="color: var(--status-sip-ink)">
                    <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14" /><path d="m9 11 3 3L22 4" />
                </svg>
                <p class="font-display text-sm font-bold" style="color: var(--status-sip-ink)">No cycles currently need attention.</p>
            </div>

            <div class="mt-6 grid grid-cols-1 gap-4 lg:grid-cols-3">
                <div class="rounded-lg border p-4 lg:col-span-2" style="border-color: var(--border); background-color: var(--surface)">
                    <h3 class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">
                        Health Distribution
                    </h3>
                    <p class="mt-0.5 text-xs" style="color: var(--ink-faint)">How many cycles landed on each Health label.</p>
                    <div class="mt-3" style="height: 220px">
                        <canvas ref="healthCanvas"></canvas>
                    </div>
                </div>

                <div class="flex flex-col rounded-lg border p-4" style="border-color: var(--border); background-color: var(--surface)">
                    <h3 class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">
                        Cycles by Platform
                    </h3>
                    <div class="flex flex-1 flex-col items-center justify-center py-1">
                        <div style="height: 140px; width: 140px">
                            <canvas ref="platformPieCanvas"></canvas>
                        </div>
                        <div class="mt-3 flex justify-center gap-5">
                            <div class="flex items-center gap-1.5">
                                <span class="h-2.5 w-2.5 shrink-0 rounded-full" style="background-color: #e1306c"></span>
                                <span class="text-xs" style="color: var(--ink-muted)">IG</span>
                                <span class="text-xs font-semibold tabular-nums" style="color: var(--ink)">{{ platformCounts.instagram ?? 0 }}</span>
                            </div>
                            <div class="flex items-center gap-1.5">
                                <span class="h-2.5 w-2.5 shrink-0 rounded-full" style="background-color: #010101"></span>
                                <span class="text-xs" style="color: var(--ink-muted)">TT</span>
                                <span class="text-xs font-semibold tabular-nums" style="color: var(--ink)">{{ platformCounts.tiktok ?? 0 }}</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="mt-4 rounded-lg border p-4" style="border-color: var(--border); background-color: var(--surface)">
                <h3 class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">
                    Cycles Added Per Month
                </h3>
                <p class="mt-0.5 text-xs" style="color: var(--ink-faint)">Last 6 months with recorded cycles.</p>
                <div class="mt-3" style="height: 200px">
                    <canvas ref="cycleTrendCanvas"></canvas>
                </div>
            </div>
        </template>

        <!-- Performance tab -->
        <template v-else>
            <div class="mt-6 grid grid-cols-2 gap-3 lg:grid-cols-4">
                <StatCard label="Accounts" :value="String(performanceData.summary?.accounts_count ?? 0)" />
                <StatCard label="Performance Posts" :value="String(performanceData.summary?.performances_count ?? 0)" />
                <StatCard
                    label="Avg Views (H+7)"
                    :value="performanceData.summary?.avg_views != null ? String(performanceData.summary.avg_views) : '—'"
                />
                <StatCard label="Top Performing" :value="String(performanceData.summary?.top_performing_count ?? 0)" hint="top-tier Views status" />
            </div>

            <!-- Needs Attention is the one number that should draw the eye — a status-colored
                 warning tile, not another neutral stat card carrying the same weight as the rest. -->
            <div
                v-if="(performanceData.summary?.at_risk_count ?? 0) > 0"
                class="mt-3 flex items-center gap-3 rounded-lg border p-4"
                style="border-color: var(--status-parah-ink); background-color: var(--status-parah-bg)"
            >
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-6 w-6 shrink-0" style="color: var(--status-parah-ink)">
                    <path d="M12 9v4m0 4h.01M10.29 3.86 1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0Z" />
                </svg>
                <div>
                    <p class="font-display text-lg font-bold" style="color: var(--status-parah-ink)">
                        {{ performanceData.summary.at_risk_count }} post{{ performanceData.summary.at_risk_count === 1 ? '' : 's' }} need{{ performanceData.summary.at_risk_count === 1 ? 's' : '' }} attention
                    </p>
                    <p class="text-xs" style="color: var(--status-parah-ink)">Views H+7 status is bottom-tier.</p>
                </div>
            </div>
            <div
                v-else
                class="mt-3 flex items-center gap-3 rounded-lg border p-4"
                style="border-color: var(--status-sip-ink); background-color: var(--status-sip-bg)"
            >
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-6 w-6 shrink-0" style="color: var(--status-sip-ink)">
                    <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14" /><path d="m9 11 3 3L22 4" />
                </svg>
                <p class="font-display text-sm font-bold" style="color: var(--status-sip-ink)">No posts currently need attention.</p>
            </div>

            <div class="mt-6 grid grid-cols-1 gap-4 lg:grid-cols-3">
                <div class="rounded-lg border p-4 lg:col-span-2" style="border-color: var(--border); background-color: var(--surface)">
                    <h3 class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">
                        Views Status Distribution
                    </h3>
                    <p class="mt-0.5 text-xs" style="color: var(--ink-faint)">How many posts landed on each Views H+7 status.</p>
                    <div class="mt-3" style="height: 220px">
                        <canvas ref="viewsCanvas"></canvas>
                    </div>
                </div>

                <div class="flex flex-col rounded-lg border p-4" style="border-color: var(--border); background-color: var(--surface)">
                    <h3 class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">
                        Posts by Platform
                    </h3>
                    <div class="flex flex-1 flex-col items-center justify-center py-1">
                        <div style="height: 140px; width: 140px">
                            <canvas ref="performancePlatformPieCanvas"></canvas>
                        </div>
                        <div class="mt-3 flex justify-center gap-5">
                            <div class="flex items-center gap-1.5">
                                <span class="h-2.5 w-2.5 shrink-0 rounded-full" style="background-color: #e1306c"></span>
                                <span class="text-xs" style="color: var(--ink-muted)">IG</span>
                                <span class="text-xs font-semibold tabular-nums" style="color: var(--ink)">{{ performanceData.platformCounts?.instagram ?? 0 }}</span>
                            </div>
                            <div class="flex items-center gap-1.5">
                                <span class="h-2.5 w-2.5 shrink-0 rounded-full" style="background-color: #010101"></span>
                                <span class="text-xs" style="color: var(--ink-muted)">TT</span>
                                <span class="text-xs font-semibold tabular-nums" style="color: var(--ink)">{{ performanceData.platformCounts?.tiktok ?? 0 }}</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="mt-4 rounded-lg border p-4" style="border-color: var(--border); background-color: var(--surface)">
                <h3 class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">
                    Posts Added Per Month
                </h3>
                <p class="mt-0.5 text-xs" style="color: var(--ink-faint)">Last 6 months with recorded posts.</p>
                <div class="mt-3" style="height: 200px">
                    <canvas ref="performanceTrendCanvas"></canvas>
                </div>
            </div>
        </template>
</template>
