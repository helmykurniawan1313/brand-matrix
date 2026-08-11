<script setup>
import { computed, nextTick, onBeforeUnmount, onMounted, ref, watch } from 'vue';
import { router } from '@inertiajs/vue3';
import Chart from 'chart.js/auto';
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
    employeesCount: {
        type: Number,
        default: 0,
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
    const accent = getCssVar('--accent') || '#0f766e';

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
                    backgroundColor: accent,
                    borderRadius: 4,
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
                x: { ticks: { color: inkFaint }, grid: { color: border } },
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
                    pointRadius: 4,
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
                x: { ticks: { color: inkFaint }, grid: { color: border } },
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
    const accent = getCssVar('--accent') || '#0f766e';

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
                    backgroundColor: accent,
                    borderRadius: 4,
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
                x: { ticks: { color: inkFaint }, grid: { color: border } },
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
                    pointRadius: 4,
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
                x: { ticks: { color: inkFaint }, grid: { color: border } },
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
                legend: { position: 'bottom', labels: { color: getCssVar('--ink-muted') || '#4b5563' } },
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
                legend: { position: 'bottom', labels: { color: getCssVar('--ink-muted') || '#4b5563' } },
                tooltip: {
                    callbacks: {
                        label: (context) => `${context.label}: ${context.parsed} post${context.parsed === 1 ? '' : 's'}`,
                    },
                },
            },
        },
    });
};

const renderActiveTabCharts = async () => {
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
            <div class="mt-6 grid grid-cols-2 gap-3 sm:grid-cols-4">
                <StatCard label="Accounts" :value="String(cycleData.summary?.accounts_count ?? 0)" />
                <StatCard label="Cycles Tracked" :value="String(cycleData.summary?.cycles_count ?? 0)" />
                <StatCard label="Employees" :value="String(employeesCount)" />
                <StatCard
                    label="Avg Health Rate"
                    :value="cycleData.summary?.avg_health_rate != null ? String(cycleData.summary.avg_health_rate) : '—'"
                />
            </div>

            <div class="mt-3 grid grid-cols-2 gap-3 sm:grid-cols-2">
                <StatCard label="Healthy (SIP)" :value="String(cycleData.summary?.healthy_cycles_count ?? 0)" hint="cycles at top tier" />
                <StatCard label="Needs Attention" :value="String(cycleData.summary?.at_risk_cycles_count ?? 0)" hint="KURANG or PARAH" />
            </div>

            <div class="mt-6 grid grid-cols-1 gap-4 lg:grid-cols-2">
                <div class="rounded-lg border p-4" style="border-color: var(--border); background-color: var(--surface)">
                    <h3 class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">
                        Health Distribution
                    </h3>
                    <p class="mt-0.5 text-xs" style="color: var(--ink-faint)">How many cycles landed on each Health label.</p>
                    <div class="mt-3" style="height: 240px">
                        <canvas ref="healthCanvas"></canvas>
                    </div>
                </div>

                <div class="rounded-lg border p-4" style="border-color: var(--border); background-color: var(--surface)">
                    <h3 class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">
                        Cycles Added Per Month
                    </h3>
                    <p class="mt-0.5 text-xs" style="color: var(--ink-faint)">Last 6 months with recorded cycles.</p>
                    <div class="mt-3" style="height: 240px">
                        <canvas ref="cycleTrendCanvas"></canvas>
                    </div>
                </div>
            </div>

            <div class="mt-4 grid grid-cols-1 gap-4 lg:grid-cols-2">
                <div class="rounded-lg border p-4" style="border-color: var(--border); background-color: var(--surface)">
                    <h3 class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">
                        Cycles by Platform
                    </h3>
                    <div class="mx-auto mt-3" style="height: 240px; max-width: 320px">
                        <canvas ref="platformPieCanvas"></canvas>
                    </div>
                </div>

                <div class="rounded-lg border p-4" style="border-color: var(--border); background-color: var(--surface)">
                    <h3 class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">
                        Top Project Managers
                    </h3>
                    <p class="mt-0.5 text-xs" style="color: var(--ink-faint)">Ranked by average Health Rate across their assigned cycles.</p>

                    <div v-if="cycleData.topProjectManagers?.length" class="mt-3 space-y-2">
                        <div
                            v-for="(pm, index) in cycleData.topProjectManagers"
                            :key="pm.employee_id"
                            class="flex items-center gap-3 rounded-md border p-3"
                            style="border-color: var(--border); background-color: var(--bg)"
                        >
                            <span
                                class="flex h-8 w-8 shrink-0 items-center justify-center rounded-full font-display text-sm font-bold"
                                :style="
                                    index === 0
                                        ? 'background-color: #fde68a; color: #92400e'
                                        : index === 1
                                            ? 'background-color: #e5e7eb; color: #374151'
                                            : 'background-color: #fdba74; color: #7c2d12'
                                "
                            >
                                {{ index + 1 }}
                            </span>
                            <div class="min-w-0">
                                <p class="truncate text-sm font-semibold" style="color: var(--ink)">{{ pm.employee_name }}</p>
                                <p class="text-xs" style="color: var(--ink-muted)">
                                    {{ pm.avg_health_rate }} avg &middot; {{ pm.cycle_count }} cycle{{ pm.cycle_count === 1 ? '' : 's' }}
                                </p>
                            </div>
                        </div>
                    </div>
                    <p v-else class="mt-3 text-sm" style="color: var(--ink-faint)">No cycles with a project manager assigned yet.</p>
                </div>
            </div>
        </template>

        <!-- Performance tab -->
        <template v-else>
            <div class="mt-6 grid grid-cols-2 gap-3 sm:grid-cols-4">
                <StatCard label="Accounts" :value="String(performanceData.summary?.accounts_count ?? 0)" />
                <StatCard label="Performance Posts" :value="String(performanceData.summary?.performances_count ?? 0)" />
                <StatCard
                    label="Avg Views (H+7)"
                    :value="performanceData.summary?.avg_views != null ? String(performanceData.summary.avg_views) : '—'"
                />
                <StatCard label="Employees" :value="String(employeesCount)" />
            </div>

            <div class="mt-3 grid grid-cols-2 gap-3 sm:grid-cols-2">
                <StatCard label="Top Performing" :value="String(performanceData.summary?.top_performing_count ?? 0)" hint="top-tier Views status" />
                <StatCard label="Needs Attention" :value="String(performanceData.summary?.at_risk_count ?? 0)" hint="bottom-tier Views status" />
            </div>

            <div class="mt-6 grid grid-cols-1 gap-4 lg:grid-cols-2">
                <div class="rounded-lg border p-4" style="border-color: var(--border); background-color: var(--surface)">
                    <h3 class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">
                        Views Status Distribution
                    </h3>
                    <p class="mt-0.5 text-xs" style="color: var(--ink-faint)">How many posts landed on each Views H+7 status.</p>
                    <div class="mt-3" style="height: 240px">
                        <canvas ref="viewsCanvas"></canvas>
                    </div>
                </div>

                <div class="rounded-lg border p-4" style="border-color: var(--border); background-color: var(--surface)">
                    <h3 class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">
                        Posts Added Per Month
                    </h3>
                    <p class="mt-0.5 text-xs" style="color: var(--ink-faint)">Last 6 months with recorded posts.</p>
                    <div class="mt-3" style="height: 240px">
                        <canvas ref="performanceTrendCanvas"></canvas>
                    </div>
                </div>
            </div>

            <div class="mt-4 grid grid-cols-1 gap-4 lg:grid-cols-3">
                <div class="rounded-lg border p-4" style="border-color: var(--border); background-color: var(--surface)">
                    <h3 class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">
                        Posts by Platform
                    </h3>
                    <div class="mx-auto mt-3" style="height: 220px; max-width: 280px">
                        <canvas ref="performancePlatformPieCanvas"></canvas>
                    </div>
                </div>

                <div class="rounded-lg border p-4" style="border-color: var(--border); background-color: var(--surface)">
                    <h3 class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">
                        Top Project Managers
                    </h3>
                    <p class="mt-0.5 text-xs" style="color: var(--ink-faint)">Ranked by number of posts managed.</p>

                    <div v-if="performanceData.topProjectManagers?.length" class="mt-3 space-y-2">
                        <div
                            v-for="(pm, index) in performanceData.topProjectManagers"
                            :key="pm.employee_id"
                            class="flex items-center gap-3 rounded-md border p-3"
                            style="border-color: var(--border); background-color: var(--bg)"
                        >
                            <span
                                class="flex h-8 w-8 shrink-0 items-center justify-center rounded-full font-display text-sm font-bold"
                                :style="
                                    index === 0
                                        ? 'background-color: #fde68a; color: #92400e'
                                        : index === 1
                                            ? 'background-color: #e5e7eb; color: #374151'
                                            : 'background-color: #fdba74; color: #7c2d12'
                                "
                            >
                                {{ index + 1 }}
                            </span>
                            <div class="min-w-0">
                                <p class="truncate text-sm font-semibold" style="color: var(--ink)">{{ pm.employee_name }}</p>
                                <p class="text-xs" style="color: var(--ink-muted)">
                                    {{ pm.post_count }} post{{ pm.post_count === 1 ? '' : 's' }}
                                </p>
                            </div>
                        </div>
                    </div>
                    <p v-else class="mt-3 text-sm" style="color: var(--ink-faint)">No posts with a project manager assigned yet.</p>
                </div>

                <div class="rounded-lg border p-4" style="border-color: var(--border); background-color: var(--surface)">
                    <h3 class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">
                        Top Conceptors
                    </h3>
                    <p class="mt-0.5 text-xs" style="color: var(--ink-faint)">Ranked by number of posts conceptualized.</p>

                    <div v-if="performanceData.topConceptors?.length" class="mt-3 space-y-2">
                        <div
                            v-for="(conceptor, index) in performanceData.topConceptors"
                            :key="conceptor.employee_id"
                            class="flex items-center gap-3 rounded-md border p-3"
                            style="border-color: var(--border); background-color: var(--bg)"
                        >
                            <span
                                class="flex h-8 w-8 shrink-0 items-center justify-center rounded-full font-display text-sm font-bold"
                                :style="
                                    index === 0
                                        ? 'background-color: #fde68a; color: #92400e'
                                        : index === 1
                                            ? 'background-color: #e5e7eb; color: #374151'
                                            : 'background-color: #fdba74; color: #7c2d12'
                                "
                            >
                                {{ index + 1 }}
                            </span>
                            <div class="min-w-0">
                                <p class="truncate text-sm font-semibold" style="color: var(--ink)">{{ conceptor.employee_name }}</p>
                                <p class="text-xs" style="color: var(--ink-muted)">
                                    {{ conceptor.post_count }} post{{ conceptor.post_count === 1 ? '' : 's' }}
                                </p>
                            </div>
                        </div>
                    </div>
                    <p v-else class="mt-3 text-sm" style="color: var(--ink-faint)">No posts with a conceptor assigned yet.</p>
                </div>
            </div>
        </template>
</template>
