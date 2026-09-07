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

// Month range filter — native month inputs, applied on change. Both empty
// means "all time" (no range param sent to the backend at all).
const monthFrom = ref('');
const monthTo = ref('');

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

const formatNumber = (value) => new Intl.NumberFormat('en-US').format(value ?? 0);

const load = async () => {
    loading.value = true;
    error.value = null;

    try {
        const params = new URLSearchParams({ platform: props.platform });
        if (monthFrom.value) params.set('month_from', monthFrom.value);
        if (monthTo.value) params.set('month_to', monthTo.value || monthFrom.value);

        const response = await fetch(`/views-trend-ranking?${params.toString()}`, {
            headers: { Accept: 'application/json' },
        });

        if (!response.ok) throw new Error('Failed to load ranking.');

        const data = await response.json();
        projectManagers.value = data.projectManagers ?? [];
        conceptors.value = data.conceptors ?? [];

        if (projectManagers.value.length === 0 && conceptors.value.length === 0) {
            error.value = 'No posts with recorded views yet to rank.';
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

watch(() => props.platform, load);
watch([monthFrom, monthTo], load);

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
        const params = new URLSearchParams({
            platform: props.platform,
            role: selectedPerson.value.role,
        });
        if (monthFrom.value) params.set('month_from', monthFrom.value);
        if (monthTo.value) params.set('month_to', monthTo.value || monthFrom.value);

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
            class="flex h-[80vh] w-full max-w-3xl flex-col rounded-lg border shadow-2xl"
            style="background-color: var(--surface-raised); border-color: var(--border)"
        >
            <div class="flex shrink-0 items-start justify-between gap-4 border-b p-6" style="border-color: var(--border)">
                <div>
                    <h2 class="font-display text-lg font-bold" style="color: var(--ink)">Best PM &amp; Conceptor</h2>
                    <p class="mt-0.5 text-sm" style="color: var(--ink-muted)">Ranked by median views per post</p>
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

            <div class="flex shrink-0 flex-wrap items-center justify-between gap-3 border-b px-6 pt-3 pb-3" style="border-color: var(--border)">
                <div class="flex gap-1">
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

                <div class="flex items-center gap-2 text-sm" style="color: var(--ink-muted)">
                    <label class="flex items-center gap-1.5">
                        From
                        <input
                            v-model="monthFrom"
                            type="month"
                            class="rounded-md border px-2 py-1 text-sm"
                            style="border-color: var(--border); background-color: var(--surface); color: var(--ink)"
                        />
                    </label>
                    <label class="flex items-center gap-1.5">
                        To
                        <input
                            v-model="monthTo"
                            type="month"
                            :disabled="!monthFrom"
                            class="rounded-md border px-2 py-1 text-sm disabled:opacity-50"
                            style="border-color: var(--border); background-color: var(--surface); color: var(--ink)"
                        />
                    </label>
                    <button
                        v-if="monthFrom || monthTo"
                        type="button"
                        class="text-xs font-medium underline transition-opacity hover:opacity-70"
                        style="color: var(--accent)"
                        @click="clearMonthFilter"
                    >
                        Clear
                    </button>
                </div>
            </div>

            <div class="min-h-0 flex-1 overflow-y-auto p-6">
                <p v-if="loading" class="py-12 text-center text-sm" style="color: var(--ink-faint)">Loading…</p>
                <p v-else-if="error" class="py-12 text-center text-sm" style="color: var(--ink-faint)">{{ error }}</p>

                <div v-else class="overflow-hidden rounded-lg border" style="border-color: var(--border)">
                    <table class="min-w-full">
                        <thead>
                            <tr style="border-bottom: 1px solid var(--border)">
                                <th class="px-4 py-2.5 text-left text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">#</th>
                                <th class="px-4 py-2.5 text-left text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">
                                    {{ activeTab === 'pm' ? 'Project Manager' : 'Conceptor' }}
                                </th>
                                <th
                                    class="cursor-pointer select-none px-4 py-2.5 text-right text-xs font-semibold uppercase tracking-wide transition-colors hover:opacity-70"
                                    style="color: var(--ink-faint)"
                                    @click="sortBy('avg_views')"
                                >
                                    Median Views
                                    <span v-if="sortKey === 'avg_views'">{{ sortDir === 'asc' ? '▲' : '▼' }}</span>
                                </th>
                                <th
                                    class="cursor-pointer select-none px-4 py-2.5 text-right text-xs font-semibold uppercase tracking-wide transition-colors hover:opacity-70"
                                    style="color: var(--ink-faint)"
                                    @click="sortBy('total_views')"
                                >
                                    Total Views
                                    <span v-if="sortKey === 'total_views'">{{ sortDir === 'asc' ? '▲' : '▼' }}</span>
                                </th>
                                <th
                                    class="cursor-pointer select-none px-4 py-2.5 text-right text-xs font-semibold uppercase tracking-wide transition-colors hover:opacity-70"
                                    style="color: var(--ink-faint)"
                                    @click="sortBy('post_count')"
                                >
                                    Posts
                                    <span v-if="sortKey === 'post_count'">{{ sortDir === 'asc' ? '▲' : '▼' }}</span>
                                </th>
                                <th class="px-4 py-2.5 text-right text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)"></th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr
                                v-for="(person, index) in activeList"
                                :key="person.employee_id"
                                class="cursor-pointer transition-colors hover:opacity-80"
                                style="border-bottom: 1px solid var(--border)"
                                @click="openPerson(person)"
                            >
                                <td class="px-4 py-3 text-sm tabular-nums" style="color: var(--ink-faint)">
                                    <span
                                        v-if="sortKey === 'avg_views' && sortDir === 'desc' && index === 0"
                                        class="inline-flex h-5 w-5 items-center justify-center rounded-full text-xs"
                                        style="background-color: var(--status-sip-bg); color: var(--status-sip-ink)"
                                        title="Best median views"
                                    >
                                        ★
                                    </span>
                                    <span v-else>{{ index + 1 }}</span>
                                </td>
                                <td class="px-4 py-3 text-sm font-medium" style="color: var(--ink)">{{ person.employee_name }}</td>
                                <td class="px-4 py-3 text-right text-sm font-semibold tabular-nums" style="color: var(--ink)">
                                    {{ formatNumber(person.avg_views) }}
                                </td>
                                <td class="px-4 py-3 text-right text-sm tabular-nums" style="color: var(--ink-muted)">
                                    {{ formatNumber(person.total_views) }}
                                </td>
                                <td class="px-4 py-3 text-right text-sm tabular-nums" style="color: var(--ink-muted)">
                                    {{ person.post_count }}
                                </td>
                                <td class="px-4 py-3 text-right text-sm" style="color: var(--ink-faint)">
                                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="ml-auto h-4 w-4">
                                        <path d="M3 3v18h18" />
                                        <path d="m19 9-5 5-4-4-3 3" />
                                    </svg>
                                </td>
                            </tr>
                            <tr v-if="activeList.length === 0">
                                <td colspan="6" class="px-4 py-12 text-center text-sm" style="color: var(--ink-faint)">
                                    No {{ activeTab === 'pm' ? 'project managers' : 'conceptors' }} with recorded views yet.
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- Per-person drill-down chart -->
        <div
            v-if="selectedPerson"
            class="fixed inset-0 z-20 flex items-center justify-center bg-black/50 px-4 py-6 backdrop-blur-sm"
            @click.self="closePerson"
        >
            <div
                class="flex h-[60vh] w-full max-w-2xl flex-col rounded-lg border shadow-2xl"
                style="background-color: var(--surface-raised); border-color: var(--border)"
            >
                <div class="flex shrink-0 items-start justify-between gap-4 border-b p-6" style="border-color: var(--border)">
                    <div>
                        <h2 class="font-display text-lg font-bold" style="color: var(--ink)">{{ selectedPerson.employee_name }}</h2>
                        <p class="mt-0.5 text-sm" style="color: var(--ink-muted)">
                            Monthly views trend — {{ selectedPerson.role === 'project_manager_id' ? 'Project Manager' : 'Conceptor' }}
                        </p>
                    </div>
                    <button
                        type="button"
                        class="flex h-8 w-8 shrink-0 items-center justify-center rounded-md transition-colors hover:opacity-70"
                        style="color: var(--ink-muted)"
                        aria-label="Close"
                        @click="closePerson"
                    >
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-5 w-5">
                            <path d="M18 6 6 18M6 6l12 12" />
                        </svg>
                    </button>
                </div>

                <div class="min-h-0 flex-1 p-6">
                    <p v-if="chartLoading" class="py-12 text-center text-sm" style="color: var(--ink-faint)">Loading…</p>
                    <p v-else-if="chartError" class="py-12 text-center text-sm" style="color: var(--ink-faint)">{{ chartError }}</p>
                    <div v-show="!chartLoading && !chartError" class="h-full w-full">
                        <canvas ref="chartCanvas"></canvas>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>
