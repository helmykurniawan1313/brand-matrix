<script setup>
import { computed, nextTick, onBeforeUnmount, ref, watch } from 'vue';
import Chart from '../chartSetup';

const props = defineProps({
    platform: { type: String, default: 'all' },
});

const emit = defineEmits(['close']);

const loading = ref(true);
const error = ref(null);
const projectManagers = ref([]);
const conceptors = ref([]);

const activeTab = ref('pm');
const tabs = [
    { key: 'pm', label: 'Project Managers' },
    { key: 'conceptor', label: 'Conceptors' },
];

// Range filter. Two modes:
//  - 'month': bucket each post by its own post_date month (native month inputs).
//  - 'cycle': only posts assigned to a cycle, bucketed by the month the cycle
//    STARTS in (a 26 Jul–25 Aug cycle = "July"). The picker then offers only
//    months a cycle actually starts in (`cycleMonths` from the API).
// Both from/to empty = whole set (no range param sent to the backend).
const rangeMode = ref('month');
const monthFrom = ref('');
const monthTo = ref('');
const cycleMonths = ref([]);

const setRangeMode = (mode) => {
    if (rangeMode.value === mode) return;
    rangeMode.value = mode;
    monthFrom.value = '';
    monthTo.value = '';
};

const formatMonthLabel = (ym) => {
    if (!ym) return '';
    const [y, m] = ym.split('-');
    return new Date(Number(y), Number(m) - 1, 1).toLocaleString('en-US', { month: 'short', year: 'numeric' });
};

const hasRange = computed(() => !!monthFrom.value || !!monthTo.value);
const rangeSummary = computed(() => {
    if (!hasRange.value) return rangeMode.value === 'cycle' ? 'All cycles' : 'All time';
    const from = formatMonthLabel(monthFrom.value) || 'earliest';
    const to = formatMonthLabel(monthTo.value || monthFrom.value);
    return from === to ? from : `${from} – ${to}`;
});

// Sort ties by average views (best-first by default); a click on any other
// column re-sorts client-side over the already-loaded list — this endpoint
// returns everyone in one shot, so there's no reload needed per sort.
const sortKey = ref('avg_views');
const sortDir = ref('desc');

const sortBy = (key) => {
    if (sortKey.value === key) {
        sortDir.value = sortDir.value === 'asc' ? 'desc' : 'asc';
    } else {
        sortKey.value = key;
        sortDir.value = 'desc';
    }
};

const sortedList = (list) => {
    return [...list].sort((a, b) => {
        const result = a[sortKey.value] - b[sortKey.value];
        return sortDir.value === 'asc' ? result : -result;
    });
};

const activeList = computed(() => sortedList(activeTab.value === 'pm' ? projectManagers.value : conceptors.value));

// The leaderboard is only meaningful when sorted by the ranking metric,
// descending — that's when "#1" / medals actually mean "best".
const isRanked = computed(() => sortKey.value === 'avg_views' && sortDir.value === 'desc');

const formatNumber = (value) => new Intl.NumberFormat('en-US').format(value ?? 0);

const load = async () => {
    loading.value = true;
    error.value = null;

    try {
        const response = await fetch(`/views-trend-ranking?${filterParams().toString()}`, {
            headers: { Accept: 'application/json' },
        });

        if (!response.ok) throw new Error('Failed to load ranking.');

        const data = await response.json();
        projectManagers.value = data.projectManagers ?? [];
        conceptors.value = data.conceptors ?? [];
        cycleMonths.value = data.cycleMonths ?? [];

        if (projectManagers.value.length === 0 && conceptors.value.length === 0) {
            error.value =
                rangeMode.value === 'cycle'
                    ? 'No cycle-assigned posts with recorded views for this range.'
                    : 'No posts with recorded views for this range.';
        }
    } catch (e) {
        error.value = e.message;
    } finally {
        loading.value = false;
    }
};

const clearMonthFilter = () => {
    monthFrom.value = '';
    monthTo.value = '';
};

// Shared param builder — the JSON load, the PDF link and the Excel link all
// carry exactly the same platform / range_mode / month range, so a download
// always matches what's on screen.
const filterParams = () => {
    const params = new URLSearchParams({ platform: props.platform, range_mode: rangeMode.value });
    if (monthFrom.value) params.set('month_from', monthFrom.value);
    if (monthTo.value) params.set('month_to', monthTo.value || monthFrom.value);
    return params;
};
const pdfUrl = computed(() => `/views-trend-ranking-pdf?${filterParams().toString()}`);
const excelUrl = computed(() => `/views-trend-ranking-excel?${filterParams().toString()}`);

watch(() => props.platform, load);
watch([rangeMode, monthFrom, monthTo], load);

load();

// --- Per-person drill-down chart ---

const selectedPerson = ref(null); // { employee_id, employee_name, role }
const chartLoading = ref(false);
const chartError = ref(null);
const chartCanvas = ref(null);
let chartInstance = null;

const getCssVar = (name) => getComputedStyle(document.documentElement).getPropertyValue(name).trim();

const destroyChart = () => {
    chartInstance?.destroy();
    chartInstance = null;
};

const openPerson = (person) => {
    selectedPerson.value = {
        employee_id: person.employee_id,
        employee_name: person.employee_name,
        role: activeTab.value === 'pm' ? 'project_manager_id' : 'conceptor_id',
    };
};

const closePerson = () => {
    destroyChart();
    selectedPerson.value = null;
};

const loadPersonSeries = async () => {
    if (!selectedPerson.value) return;

    chartLoading.value = true;
    chartError.value = null;

    try {
        const params = filterParams();
        params.set('role', selectedPerson.value.role);

        const response = await fetch(`/views-trend-ranking/${selectedPerson.value.employee_id}?${params.toString()}`, {
            headers: { Accept: 'application/json' },
        });

        if (!response.ok) throw new Error('Failed to load chart.');

        const data = await response.json();
        const series = data.series ?? [];

        if (series.length === 0) {
            chartError.value = 'No monthly data to chart yet.';
            destroyChart();
            return;
        }

        await nextTick();
        renderPersonChart(series);
    } catch (e) {
        chartError.value = e.message;
    } finally {
        chartLoading.value = false;
    }
};

const renderPersonChart = (series) => {
    destroyChart();
    if (!chartCanvas.value) return;

    const accent = getCssVar('--accent') || '#0f766e';
    const inkFaint = getCssVar('--ink-faint') || '#8b979b';
    const border = getCssVar('--border') || '#d8dedc';

    chartInstance = new Chart(chartCanvas.value, {
        type: 'line',
        data: {
            labels: series.map((s) => s.label),
            datasets: [
                {
                    label: 'Median Views',
                    data: series.map((s) => s.avg_views),
                    borderColor: accent,
                    backgroundColor: `${accent}1a`,
                    pointBackgroundColor: accent,
                    pointBorderColor: getCssVar('--surface') || '#ffffff',
                    pointBorderWidth: 2,
                    pointRadius: 4,
                    borderWidth: 2,
                    tension: 0.3,
                    fill: true,
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
                        label: (context) => {
                            const point = series[context.dataIndex];
                            return [
                                `Median Views: ${formatNumber(point.avg_views)}`,
                                `Total Views: ${formatNumber(point.total_views)}`,
                                `Posts: ${point.post_count}`,
                            ];
                        },
                    },
                },
            },
            scales: {
                x: { ticks: { color: inkFaint }, grid: { display: false } },
                y: {
                    ticks: { color: inkFaint, callback: (value) => formatNumber(value) },
                    grid: { color: border },
                    beginAtZero: true,
                },
            },
        },
    });
};

watch(selectedPerson, (value) => {
    if (value) loadPersonSeries();
});

onBeforeUnmount(destroyChart);
</script>

<template>
    <div class="fixed inset-0 z-10 flex items-center justify-center bg-black/50 px-4 py-6 backdrop-blur-sm" @click.self="emit('close')">
        <div
            class="flex h-[82vh] w-full max-w-3xl flex-col overflow-hidden rounded-xl border shadow-2xl"
            style="background-color: var(--surface-raised); border-color: var(--border)"
        >
            <!-- Header: title + subtle icon actions, no divider (the tab bar below is the first real boundary) -->
            <div class="flex shrink-0 items-start justify-between gap-4 px-6 pt-5 pb-3">
                <div class="min-w-0">
                    <h2 class="font-display text-lg font-bold leading-tight" style="color: var(--ink)">Best PM &amp; Conceptor</h2>
                    <p class="mt-1 text-sm" style="color: var(--ink-muted)">
                        By median views per post ·
                        {{ rangeMode === 'cycle' ? 'grouped by cycle month' : 'grouped by post month' }}
                    </p>
                </div>
                <div class="flex shrink-0 items-center gap-1">
                    <a
                        :href="pdfUrl"
                        title="Download PDF"
                        aria-label="Download PDF"
                        class="flex h-8 w-8 items-center justify-center rounded-lg transition-colors hover:bg-[var(--surface)]"
                        style="color: var(--ink-muted)"
                    >
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" class="h-4 w-4">
                            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z" />
                            <path d="M14 2v6h6" />
                            <text x="7.5" y="17.5" font-size="6" font-weight="700" fill="currentColor" stroke="none">PDF</text>
                        </svg>
                    </a>
                    <a
                        :href="excelUrl"
                        title="Download Excel"
                        aria-label="Download Excel"
                        class="flex h-8 w-8 items-center justify-center rounded-lg transition-colors hover:bg-[var(--surface)]"
                        style="color: var(--ink-muted)"
                    >
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" class="h-4 w-4">
                            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z" />
                            <path d="M14 2v6h6" />
                            <path d="m9 13 2 3 M13 13l-2 3" />
                        </svg>
                    </a>
                    <div class="mx-1 h-5 w-px" style="background-color: var(--border)" />
                    <button
                        type="button"
                        class="flex h-8 w-8 items-center justify-center rounded-lg transition-colors hover:bg-[var(--surface)]"
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

            <!-- Tab bar — the only real dividing line at the top -->
            <div class="flex shrink-0 gap-6 border-b px-6" style="border-color: var(--border)">
                <button
                    v-for="tab in tabs"
                    :key="tab.key"
                    type="button"
                    class="relative -mb-px border-b-2 pb-2.5 pt-1 text-sm font-semibold transition-colors"
                    :style="
                        activeTab === tab.key
                            ? 'border-color: var(--accent); color: var(--ink)'
                            : 'border-color: transparent; color: var(--ink-faint)'
                    "
                    @click="activeTab = tab.key"
                >
                    {{ tab.label }}
                </button>
            </div>

            <!-- Filter row — lightweight, on the raised surface, no hard border -->
            <div class="flex shrink-0 flex-wrap items-center gap-x-4 gap-y-2 px-6 py-3">
                <!-- Segmented mode toggle -->
                <div
                    class="inline-flex rounded-lg p-0.5"
                    style="background-color: var(--surface)"
                >
                    <button
                        v-for="mode in ['month', 'cycle']"
                        :key="mode"
                        type="button"
                        class="rounded-md px-2.5 py-1 text-xs font-semibold capitalize transition-all"
                        :style="
                            rangeMode === mode
                                ? 'background-color: var(--surface-raised); color: var(--ink); box-shadow: 0 1px 2px rgba(0,0,0,0.06)'
                                : 'background-color: transparent; color: var(--ink-faint)'
                        "
                        @click="setRangeMode(mode)"
                    >
                        {{ mode === 'month' ? 'By month' : 'By cycle' }}
                    </button>
                </div>

                <!-- From / To in a single pill so it reads as one control -->
                <div
                    class="flex items-center gap-1.5 rounded-lg px-2.5 py-1"
                    style="background-color: var(--surface)"
                >
                    <template v-if="rangeMode === 'month'">
                        <input
                            v-model="monthFrom"
                            type="month"
                            aria-label="From month"
                            class="w-[8.5rem] bg-transparent text-xs focus:outline-none"
                            style="color: var(--ink); color-scheme: normal"
                        />
                        <span class="text-xs" style="color: var(--ink-faint)">→</span>
                        <input
                            v-model="monthTo"
                            type="month"
                            :disabled="!monthFrom"
                            aria-label="To month"
                            class="w-[8.5rem] bg-transparent text-xs focus:outline-none disabled:opacity-40"
                            style="color: var(--ink); color-scheme: normal"
                        />
                    </template>
                    <template v-else>
                        <select
                            v-model="monthFrom"
                            aria-label="From cycle month"
                            class="bg-transparent text-xs focus:outline-none"
                            style="color: var(--ink)"
                        >
                            <option value="">Earliest</option>
                            <option v-for="ym in cycleMonths" :key="ym" :value="ym">{{ formatMonthLabel(ym) }}</option>
                        </select>
                        <span class="text-xs" style="color: var(--ink-faint)">→</span>
                        <select
                            v-model="monthTo"
                            :disabled="!monthFrom"
                            aria-label="To cycle month"
                            class="bg-transparent text-xs focus:outline-none disabled:opacity-40"
                            style="color: var(--ink)"
                        >
                            <option value="">Latest in range</option>
                            <option
                                v-for="ym in cycleMonths.filter((m) => !monthFrom || m >= monthFrom)"
                                :key="ym"
                                :value="ym"
                            >
                                {{ formatMonthLabel(ym) }}
                            </option>
                        </select>
                    </template>
                </div>

                <button
                    v-if="hasRange"
                    type="button"
                    class="text-xs font-medium transition-opacity hover:opacity-70"
                    style="color: var(--accent)"
                    @click="clearMonthFilter"
                >
                    Reset
                </button>

                <span class="ml-auto text-xs" style="color: var(--ink-faint)">{{ rangeSummary }}</span>
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

                <table v-else class="min-w-full">
                    <thead class="sticky top-0" style="background-color: var(--surface-raised)">
                        <tr style="border-bottom: 1px solid var(--border)">
                            <th class="w-12 py-2.5 pr-2 text-left text-[11px] font-semibold uppercase tracking-wide" style="color: var(--ink-faint)"></th>
                            <th class="py-2.5 text-left text-[11px] font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">
                                {{ activeTab === 'pm' ? 'Project Manager' : 'Conceptor' }}
                            </th>
                            <th
                                class="cursor-pointer select-none py-2.5 text-right text-[11px] font-semibold uppercase tracking-wide transition-colors hover:opacity-70"
                                style="color: var(--ink-faint)"
                                @click="sortBy('avg_views')"
                            >
                                Median<span v-if="sortKey === 'avg_views'" class="ml-0.5">{{ sortDir === 'asc' ? '↑' : '↓' }}</span>
                            </th>
                            <th
                                class="cursor-pointer select-none py-2.5 text-right text-[11px] font-semibold uppercase tracking-wide transition-colors hover:opacity-70"
                                style="color: var(--ink-faint)"
                                @click="sortBy('total_views')"
                            >
                                Total<span v-if="sortKey === 'total_views'" class="ml-0.5">{{ sortDir === 'asc' ? '↑' : '↓' }}</span>
                            </th>
                            <th
                                class="cursor-pointer select-none py-2.5 pr-1 text-right text-[11px] font-semibold uppercase tracking-wide transition-colors hover:opacity-70"
                                style="color: var(--ink-faint)"
                                @click="sortBy('post_count')"
                            >
                                Posts<span v-if="sortKey === 'post_count'" class="ml-0.5">{{ sortDir === 'asc' ? '↑' : '↓' }}</span>
                            </th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr
                            v-for="(person, index) in activeList"
                            :key="person.employee_id"
                            class="group cursor-pointer transition-colors"
                            :class="{ 'hover:bg-[var(--surface)]': true }"
                            :style="
                                isRanked && index === 0
                                    ? `border-bottom: 1px solid var(--border); background-color: var(--accent-soft)`
                                    : 'border-bottom: 1px solid var(--border)'
                            "
                            @click="openPerson(person)"
                        >
                            <td class="py-3 pr-2">
                                <span
                                    v-if="isRanked && index < 3"
                                    class="inline-flex h-6 w-6 items-center justify-center rounded-full text-xs font-bold"
                                    :style="[
                                        index === 0
                                            ? 'background-color: var(--status-cukup-bg); color: var(--status-cukup-ink)'
                                            : index === 1
                                            ? 'background-color: var(--surface); color: var(--ink-muted)'
                                            : 'background-color: var(--status-kurang-bg); color: var(--status-kurang-ink)',
                                    ]"
                                >
                                    {{ index + 1 }}
                                </span>
                                <span v-else class="pl-1.5 text-sm tabular-nums" style="color: var(--ink-faint)">
                                    {{ index + 1 }}
                                </span>
                            </td>
                            <td class="py-3 text-sm font-medium" style="color: var(--ink)">
                                {{ person.employee_name }}
                            </td>
                            <td class="py-3 text-right text-sm font-semibold tabular-nums" style="color: var(--ink)">
                                {{ formatNumber(person.avg_views) }}
                            </td>
                            <td class="py-3 text-right text-sm tabular-nums" style="color: var(--ink-muted)">
                                {{ formatNumber(person.total_views) }}
                            </td>
                            <td class="py-3 pr-1 text-right text-sm tabular-nums" style="color: var(--ink-muted)">
                                {{ person.post_count }}
                            </td>
                        </tr>
                        <tr v-if="activeList.length === 0">
                            <td colspan="5" class="py-12 text-center text-sm" style="color: var(--ink-faint)">
                                No {{ activeTab === 'pm' ? 'project managers' : 'conceptors' }} to rank for this range.
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Per-person drill-down — a lighter overlay that visually belongs to the same surface -->
        <div
            v-if="selectedPerson"
            class="fixed inset-0 z-20 flex items-center justify-center bg-black/40 px-4 py-6 backdrop-blur-sm"
            @click.self="closePerson"
        >
            <div
                class="flex h-[58vh] w-full max-w-2xl flex-col overflow-hidden rounded-xl border shadow-2xl"
                style="background-color: var(--surface-raised); border-color: var(--border)"
            >
                <div class="flex shrink-0 items-start justify-between gap-4 px-6 pt-5 pb-4 border-b" style="border-color: var(--border)">
                    <div class="min-w-0">
                        <h2 class="font-display text-lg font-bold leading-tight" style="color: var(--ink)">{{ selectedPerson.employee_name }}</h2>
                        <p class="mt-1 text-sm" style="color: var(--ink-muted)">
                            Monthly median views · {{ selectedPerson.role === 'project_manager_id' ? 'as Project Manager' : 'as Conceptor' }}
                        </p>
                    </div>
                    <button
                        type="button"
                        class="flex h-8 w-8 shrink-0 items-center justify-center rounded-lg transition-colors hover:bg-[var(--surface)]"
                        style="color: var(--ink-muted)"
                        aria-label="Back to leaderboard"
                        @click="closePerson"
                    >
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-5 w-5">
                            <path d="M18 6 6 18M6 6l12 12" />
                        </svg>
                    </button>
                </div>

                <div class="min-h-0 flex-1 p-6">
                    <div v-if="chartLoading" class="flex h-full items-center justify-center">
                        <span class="text-sm" style="color: var(--ink-faint)">Loading…</span>
                    </div>
                    <div v-else-if="chartError" class="flex h-full items-center justify-center">
                        <span class="text-sm" style="color: var(--ink-faint)">{{ chartError }}</span>
                    </div>
                    <div v-show="!chartLoading && !chartError" class="h-full w-full">
                        <canvas ref="chartCanvas"></canvas>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>
