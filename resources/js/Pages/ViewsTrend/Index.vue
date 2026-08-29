<script setup>
import { computed, ref } from 'vue';
import { router } from '@inertiajs/vue3';
import AppLayout from '../../Layouts/AppLayout.vue';
import ViewsTrendDetailModal from '../../Components/ViewsTrendDetailModal.vue';

defineOptions({ layout: AppLayout });

const props = defineProps({
    filters: { type: Object, required: true },
    rows: { type: Object, required: true },
    chartRows: { type: Array, default: () => [] },
    counts: { type: Object, required: true },
});

const search = ref(props.filters.search ?? '');
const platform = ref(props.filters.platform ?? 'all');
const trendFilter = ref(props.filters.trend ?? 'all');
const sort = ref(props.filters.sort ?? 'trend');
const direction = ref(props.filters.direction ?? 'asc');
let searchTimeout = null;

const platformTabs = [
    { value: 'all', label: 'All Platforms' },
    { value: 'instagram', label: 'Instagram' },
    { value: 'tiktok', label: 'TikTok' },
];

const platformMeta = {
    instagram: { label: 'IG', color: '#e1306c' },
    tiktok: { label: 'TT', color: '#010101' },
};

const trendMeta = {
    setback: { label: 'Setback', bg: 'var(--status-parah-bg)', ink: 'var(--status-parah-ink)' },
    stagnant: { label: 'Stagnant', bg: 'var(--status-kurang-bg)', ink: 'var(--status-kurang-ink)' },
    growing: { label: 'Growing', bg: 'var(--status-sip-bg)', ink: 'var(--status-sip-ink)' },
    stable: { label: 'Stable', bg: 'var(--status-bagus-bg)', ink: 'var(--status-bagus-ink)' },
    insufficient_data: { label: 'Not enough data', bg: 'var(--border)', ink: 'var(--ink-muted)' },
};

const trendTabs = [
    { value: 'all', label: 'All accounts', tone: null },
    { value: 'setback', label: 'Setback', tone: 'setback' },
    { value: 'stagnant', label: 'Stagnant', tone: 'stagnant' },
    { value: 'growing', label: 'Growing', tone: 'growing' },
    { value: 'stable', label: 'Stable', tone: 'stable' },
];

const applyFilters = () => {
    router.get(
        '/views-trend',
        {
            search: search.value || undefined,
            platform: platform.value,
            trend: trendFilter.value === 'all' ? undefined : trendFilter.value,
            sort: sort.value === 'trend' ? undefined : sort.value,
            direction: direction.value === 'asc' ? undefined : direction.value,
        },
        { preserveState: true, preserveScroll: true, replace: true },
    );
};

const onSearchInput = () => {
    clearTimeout(searchTimeout);
    searchTimeout = setTimeout(applyFilters, 300);
};

const clearSearch = () => {
    search.value = '';
    applyFilters();
};

const setTrendFilter = (value) => {
    trendFilter.value = value;
    applyFilters();
};

const setPlatform = (value) => {
    platform.value = value;
    applyFilters();
};

// Filter modal (draft state, only applied on "Apply") — mirrors the pattern used
// on Cycles/Performance, wrapping platform + trend so the toolbar doesn't need
// to grow separate controls as more filters are added later.
const showFilterModal = ref(false);
const draftPlatform = ref('all');
const draftTrend = ref('all');

const openFilterModal = () => {
    draftPlatform.value = platform.value;
    draftTrend.value = trendFilter.value;
    showFilterModal.value = true;
};

const closeFilterModal = () => {
    showFilterModal.value = false;
};

const applyFilterModal = () => {
    platform.value = draftPlatform.value;
    trendFilter.value = draftTrend.value;
    showFilterModal.value = false;
    applyFilters();
};

const clearFilterModal = () => {
    draftPlatform.value = 'all';
    draftTrend.value = 'all';
};

const activeFilterCount = computed(() => {
    let count = 0;
    if (platform.value !== 'all') count += 1;
    if (trendFilter.value !== 'all') count += 1;
    return count;
});

const sortBy = (key) => {
    if (sort.value === key) {
        direction.value = direction.value === 'asc' ? 'desc' : 'asc';
    } else {
        sort.value = key;
        direction.value = 'asc';
    }
    applyFilters();
};

const goToPage = (url) => {
    if (!url) return;
    router.visit(url, { preserveScroll: true, preserveState: true });
};

const formatNumber = (value) => (value === null || value === undefined ? '—' : new Intl.NumberFormat('en-US').format(value));
const formatDelta = (value) => (value === null || value === undefined ? 'New' : `${value > 0 ? '+' : ''}${value}%`);
const deltaColor = (value) => {
    if (value === null || value === undefined) return 'var(--ink-faint)';
    if (value <= -15) return 'var(--status-parah-ink)';
    if (value >= 15) return 'var(--status-sip-ink)';
    return 'var(--ink-muted)';
};

// --- Diverging bar chart: Δ% per account, ranked best -> worst by default. ---
// Sourced from chartRows (all filtered-by-page-controls accounts, unpaginated,
// unsorted-by-table) rather than the table's current page — so sorting or
// paging the table never reshuffles or truncates the chart; only the page's
// search/platform/trend filters do (the modal's own sort/trend controls below
// operate client-side on this same already-loaded set, no reload needed).
// Only rows with a real delta plot; an "insufficient data" row (delta_pct ===
// null) has nothing to diverge from.
const showChartModal = ref(false);
const chartSort = ref('best'); // 'best' = descending (growth first), 'worst' = ascending (setback first)
const chartTrendFilter = ref('all');

const chartRowsWithDelta = computed(() => props.chartRows.filter((row) => row.delta_pct !== null));

const chartRows = computed(() => {
    const filtered = chartTrendFilter.value === 'all'
        ? chartRowsWithDelta.value
        : chartRowsWithDelta.value.filter((row) => row.trend === chartTrendFilter.value);

    return filtered.slice().sort((a, b) => (chartSort.value === 'best' ? b.delta_pct - a.delta_pct : a.delta_pct - b.delta_pct));
});

// Linear width against the single largest |delta| in the set is unreadable
// whenever one account has an outsized swing (e.g. a small account going from
// 100 to 2,700 views reads as +2600%) — it flattens every normal-range row to a
// hairline. A log1p scale keeps every row visibly proportioned: outliers still
// read as "biggest," but a -19% row next to a +2600% row is still visibly a bar,
// not an invisible sliver.
const logScale = (delta) => Math.log10(1 + Math.abs(delta));

const maxLogDelta = computed(() => {
    const max = Math.max(logScale(10), ...chartRows.value.map((row) => logScale(row.delta_pct)));
    return max;
});

const barWidthPct = (delta) => (logScale(delta) / maxLogDelta.value) * 50;

const exportQuery = () => ({
    search: search.value || undefined,
    platform: platform.value,
    trend: trendFilter.value === 'all' ? undefined : trendFilter.value,
    sort: sort.value === 'trend' ? undefined : sort.value,
    direction: direction.value === 'asc' ? undefined : direction.value,
});

const pdfDownloadUrl = computed(() => {
    const params = new URLSearchParams(Object.entries(exportQuery()).filter(([, v]) => v !== undefined));
    const query = params.toString();
    return `/views-trend-pdf${query ? `?${query}` : ''}`;
});

const excelDownloadUrl = computed(() => {
    const params = new URLSearchParams(Object.entries(exportQuery()).filter(([, v]) => v !== undefined));
    const query = params.toString();
    return `/views-trend-excel${query ? `?${query}` : ''}`;
});

// Detail modal — reuses the same growth modal used on the Accounts page.
// Opening it from the chart modal is a drill-down, not a separate action: the
// chart modal steps aside (never stacked behind it) and closing the detail
// modal steps back to the chart exactly as it was — same sort, same trend
// filter, same scroll position — rather than dumping the user back at the
// flat table. cameFromChart is the only piece of state this needs, since the
// chart's own sort/filter refs already persist independently of showChartModal.
const selectedAccount = ref(null);
const selectedPlatform = ref('instagram');
const cameFromChart = ref(false);

const openDetail = (row) => {
    cameFromChart.value = showChartModal.value;
    showChartModal.value = false;
    selectedAccount.value = { id: row.account_id, name: row.account_name };
    selectedPlatform.value = row.platform;
};
const closeDetail = () => {
    selectedAccount.value = null;
    if (cameFromChart.value) {
        showChartModal.value = true;
        cameFromChart.value = false;
    }
};
</script>

<template>
    <div class="flex flex-wrap items-start justify-between gap-4">
        <div>
            <h1 class="font-display text-2xl font-bold tracking-tight" style="color: var(--ink)">Views Trend</h1>
            <p class="mt-1 text-sm" style="color: var(--ink-muted)">
                Which accounts are dropping off, flat, or growing in post views — compared cycle over cycle.
            </p>
        </div>

        <div class="flex gap-1 rounded-lg border p-1" style="border-color: var(--border); background-color: var(--surface)">
            <button
                v-for="tab in platformTabs"
                :key="tab.value"
                type="button"
                class="rounded-md px-3 py-1.5 text-sm font-medium transition-colors"
                :style="
                    platform === tab.value
                        ? 'background-color: var(--accent); color: var(--accent-ink)'
                        : 'color: var(--ink-muted)'
                "
                @click="setPlatform(tab.value)"
            >
                {{ tab.label }}
            </button>
        </div>
    </div>

    <!-- KPI row: tap a tile to filter the table/chart below by that trend. -->
    <div class="mt-6 grid grid-cols-2 gap-3 sm:grid-cols-4">
        <button
            v-for="tab in trendTabs.slice(1)"
            :key="tab.value"
            type="button"
            class="rounded-lg border p-4 text-left transition-colors"
            :style="
                trendFilter === tab.value
                    ? `border-color: ${trendMeta[tab.tone].ink}; background-color: ${trendMeta[tab.tone].bg}`
                    : 'border-color: var(--border); background-color: var(--surface)'
            "
            @click="setTrendFilter(trendFilter === tab.value ? 'all' : tab.value)"
        >
            <p class="text-xs font-medium uppercase tracking-wide" style="color: var(--ink-faint)">{{ tab.label }}</p>
            <p class="mt-1.5 font-display text-3xl font-bold" :style="`color: ${trendMeta[tab.tone].ink}`">
                {{ counts[tab.value] }}
            </p>
            <p class="mt-0.5 text-xs" style="color: var(--ink-muted)">
                {{ tab.value === 'setback' ? 'views dropped 15%+' : tab.value === 'stagnant' ? 'flat for 3+ cycles' : tab.value === 'growing' ? 'views up 15%+' : 'minor movement' }}
            </p>
        </button>
    </div>

    <!-- Diverging bar chart summary card: opens the full chart in a modal on demand.
         Data only changes with search/platform/trend filters, never with the table's
         sort or page — so the chart stays stable while you sort/browse the table. -->
    <button
        type="button"
        class="mt-6 flex w-full items-center justify-between rounded-lg border p-5 text-left transition-colors hover:opacity-90"
        style="border-color: var(--border); background-color: var(--surface)"
        @click="showChartModal = true"
    >
        <div>
            <h2 class="text-sm font-semibold" style="color: var(--ink)">Views change vs prior cycle</h2>
            <p class="mt-0.5 text-xs" style="color: var(--ink-muted)">
                {{ chartRowsWithDelta.length }} filtered account{{ chartRowsWithDelta.length === 1 ? '' : 's' }}, ranked best to worst — click to view chart
            </p>
        </div>
        <div class="flex items-center gap-4 text-xs" style="color: var(--ink-muted)">
            <span class="flex items-center gap-1.5"><span class="h-2.5 w-2.5 rounded-sm" style="background-color: var(--status-parah-ink)" />Down</span>
            <span class="flex items-center gap-1.5"><span class="h-2.5 w-2.5 rounded-sm" style="background-color: var(--status-sip-ink)" />Up</span>
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-4 w-4 shrink-0">
                <path d="M15 3h6v6M9 21H3v-6M21 3l-7 7M3 21l7-7" />
            </svg>
        </div>
    </button>

    <!-- Toolbar: search + Filter + trend pills on the left, exports on the right —
         all in one row, matching the Cycles/Performance toolbar convention. -->
    <div class="mt-6 flex flex-wrap items-center gap-3">
        <div class="relative max-w-xs flex-1 sm:min-w-[14rem]">
            <svg
                xmlns="http://www.w3.org/2000/svg"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="2"
                class="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2"
                style="color: var(--ink-faint)"
            >
                <circle cx="11" cy="11" r="8" />
                <path d="m21 21-4.3-4.3" />
            </svg>
            <input
                v-model="search"
                type="text"
                placeholder="Search by account…"
                class="w-full rounded-md border py-2 pl-9 pr-8 text-sm transition-colors focus:outline-none"
                style="border-color: var(--border); background-color: var(--surface); color: var(--ink)"
                @input="onSearchInput"
            />
            <button
                v-if="search"
                type="button"
                class="absolute right-2.5 top-1/2 -translate-y-1/2 transition-colors hover:opacity-70"
                style="color: var(--ink-faint)"
                aria-label="Clear search"
                @click="clearSearch"
            >
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-4 w-4">
                    <path d="M18 6 6 18M6 6l12 12" />
                </svg>
            </button>
        </div>

        <button
            type="button"
            class="relative inline-flex items-center gap-1.5 rounded-md border px-3 py-2 text-sm font-medium transition-colors hover:opacity-70"
            style="border-color: var(--border); color: var(--ink)"
            @click="openFilterModal"
        >
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-4 w-4">
                <path d="M4 4h16l-6.5 8v6l-3 2v-8L4 4z" />
            </svg>
            Filter
            <span
                v-if="activeFilterCount > 0"
                class="ml-0.5 inline-flex h-4 min-w-4 items-center justify-center rounded-full px-1 text-[10px] font-bold"
                style="background-color: var(--accent); color: var(--accent-ink)"
            >
                {{ activeFilterCount }}
            </span>
        </button>

        <div class="flex gap-1 rounded-lg border p-1" style="border-color: var(--border); background-color: var(--surface)">
            <button
                v-for="tab in trendTabs"
                :key="tab.value"
                type="button"
                class="rounded-md px-3 py-1.5 text-sm font-medium transition-colors"
                :style="
                    trendFilter === tab.value
                        ? 'background-color: var(--accent); color: var(--accent-ink)'
                        : 'color: var(--ink-muted)'
                "
                @click="setTrendFilter(tab.value)"
            >
                {{ tab.label }}
            </button>
        </div>

        <div class="ml-auto flex items-center gap-3">
            <a
                :href="excelDownloadUrl"
                class="inline-flex items-center gap-1.5 rounded-md border px-3 py-2 text-sm font-medium transition-colors hover:opacity-70"
                style="border-color: var(--border); color: var(--ink-muted)"
            >
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-4 w-4">
                    <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8l-6-6z" />
                    <path d="M14 2v6h6M9.5 13l5 6M14.5 13l-5 6" />
                </svg>
                Export Excel
            </a>

            <a
                :href="pdfDownloadUrl"
                class="inline-flex items-center gap-1.5 rounded-md border px-3 py-2 text-sm font-medium transition-colors hover:opacity-70"
                style="border-color: var(--border); color: var(--ink-muted)"
            >
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-4 w-4">
                    <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4M7 10l5 5 5-5M12 15V3" />
                </svg>
                Download PDF
            </a>
        </div>
    </div>

    <div class="mt-3 overflow-hidden rounded-lg border" style="border-color: var(--border); background-color: var(--surface)">
        <div class="overflow-x-auto">
            <table class="min-w-full">
                <thead>
                    <tr style="border-bottom: 1px solid var(--border)">
                        <th
                            class="cursor-pointer select-none px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide transition-colors hover:opacity-70"
                            style="color: var(--ink-faint)"
                            @click="sortBy('account')"
                        >
                            Account
                            <span v-if="sort === 'account'">{{ direction === 'asc' ? '▲' : '▼' }}</span>
                        </th>
                        <th v-if="platform === 'all'" class="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Platform</th>
                        <th
                            class="cursor-pointer select-none px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide transition-colors hover:opacity-70"
                            style="color: var(--ink-faint)"
                            @click="sortBy('trend')"
                        >
                            Trend
                            <span v-if="sort === 'trend'">{{ direction === 'asc' ? '▲' : '▼' }}</span>
                        </th>
                        <th
                            class="cursor-pointer select-none px-4 py-3 text-right text-xs font-semibold uppercase tracking-wide transition-colors hover:opacity-70"
                            style="color: var(--ink-faint)"
                            @click="sortBy('last_avg_views')"
                        >
                            Last cycle avg views
                            <span v-if="sort === 'last_avg_views'">{{ direction === 'asc' ? '▲' : '▼' }}</span>
                        </th>
                        <th
                            class="cursor-pointer select-none px-4 py-3 text-right text-xs font-semibold uppercase tracking-wide transition-colors hover:opacity-70"
                            style="color: var(--ink-faint)"
                            @click="sortBy('prior_avg_views')"
                        >
                            Prior cycle
                            <span v-if="sort === 'prior_avg_views'">{{ direction === 'asc' ? '▲' : '▼' }}</span>
                        </th>
                        <th
                            class="cursor-pointer select-none px-4 py-3 text-right text-xs font-semibold uppercase tracking-wide transition-colors hover:opacity-70"
                            style="color: var(--ink-faint)"
                            @click="sortBy('last_total_views')"
                        >
                            Total views (last)
                            <span v-if="sort === 'last_total_views'">{{ direction === 'asc' ? '▲' : '▼' }}</span>
                        </th>
                        <th
                            class="cursor-pointer select-none px-4 py-3 text-right text-xs font-semibold uppercase tracking-wide transition-colors hover:opacity-70"
                            style="color: var(--ink-faint)"
                            @click="sortBy('prior_total_views')"
                        >
                            Total views (prior)
                            <span v-if="sort === 'prior_total_views'">{{ direction === 'asc' ? '▲' : '▼' }}</span>
                        </th>
                        <th
                            class="cursor-pointer select-none px-4 py-3 text-right text-xs font-semibold uppercase tracking-wide transition-colors hover:opacity-70"
                            style="color: var(--ink-faint)"
                            @click="sortBy('delta_pct')"
                        >
                            Δ%
                            <span v-if="sort === 'delta_pct'">{{ direction === 'asc' ? '▲' : '▼' }}</span>
                        </th>
                        <th class="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">As of</th>
                        <th class="px-4 py-3 text-right text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)"></th>
                    </tr>
                </thead>
                <tbody>
                    <tr
                        v-for="row in rows.data"
                        :key="row.row_id"
                        class="cursor-pointer transition-colors hover:opacity-80"
                        style="border-bottom: 1px solid var(--border)"
                        @click="openDetail(row)"
                    >
                        <td class="px-4 py-3.5 text-sm font-medium" style="color: var(--ink)">{{ row.account_name }}</td>
                        <td v-if="platform === 'all'" class="px-4 py-3.5 text-sm">
                            <span
                                class="inline-flex items-center gap-1.5 rounded-full px-2 py-0.5 text-xs font-semibold text-white"
                                :style="`background-color: ${platformMeta[row.platform].color}`"
                            >
                                {{ platformMeta[row.platform].label }}
                            </span>
                        </td>
                        <td class="px-4 py-3.5 text-sm">
                            <span
                                class="inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-xs font-semibold"
                                :style="`background-color: ${trendMeta[row.trend].bg}; color: ${trendMeta[row.trend].ink}`"
                            >
                                <span class="h-1.5 w-1.5 rounded-full" :style="`background-color: ${trendMeta[row.trend].ink}`" />
                                {{ trendMeta[row.trend].label }}
                                <template v-if="row.trend === 'stagnant'">({{ row.stagnant_streak }} cycles)</template>
                            </span>
                        </td>
                        <td class="px-4 py-3.5 text-right text-sm tabular-nums" style="color: var(--ink)">{{ formatNumber(row.last_avg_views) }}</td>
                        <td class="px-4 py-3.5 text-right text-sm tabular-nums" style="color: var(--ink-muted)">{{ formatNumber(row.prior_avg_views) }}</td>
                        <td class="px-4 py-3.5 text-right text-sm tabular-nums" style="color: var(--ink)">{{ formatNumber(row.last_total_views) }}</td>
                        <td class="px-4 py-3.5 text-right text-sm tabular-nums" style="color: var(--ink-muted)">{{ formatNumber(row.prior_total_views) }}</td>
                        <td class="px-4 py-3.5 text-right text-sm font-semibold tabular-nums" :style="`color: ${deltaColor(row.delta_pct)}`">
                            {{ formatDelta(row.delta_pct) }}
                        </td>
                        <td class="px-4 py-3.5 text-sm" style="color: var(--ink-muted)">{{ row.last_cycle_label }}</td>
                        <td class="px-4 py-3.5 text-right text-sm" style="color: var(--ink-faint)">View →</td>
                    </tr>
                    <tr v-if="rows.data.length === 0">
                        <td :colspan="platform === 'all' ? 10 : 9" class="px-4 py-12 text-center text-sm" style="color: var(--ink-faint)">
                            No accounts match this filter.
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>

        <div
            v-if="rows.last_page > 1"
            class="flex items-center justify-between border-t px-4 py-3"
            style="border-color: var(--border)"
        >
            <p class="text-sm" style="color: var(--ink-muted)">
                Showing <span class="font-medium tabular-nums" style="color: var(--ink)">{{ rows.from }}–{{ rows.to }}</span>
                of <span class="font-medium tabular-nums" style="color: var(--ink)">{{ rows.total }}</span>
            </p>
            <div class="flex items-center gap-1">
                <button
                    v-for="link in rows.links"
                    :key="link.label"
                    type="button"
                    class="min-w-[2.25rem] rounded-md px-2.5 py-1.5 text-sm font-medium transition-colors"
                    :class="{ 'cursor-not-allowed opacity-40': !link.url }"
                    :style="
                        link.active
                            ? 'background-color: var(--accent); color: var(--accent-ink)'
                            : 'color: var(--ink-muted)'
                    "
                    :disabled="!link.url"
                    v-html="link.label"
                    @click="goToPage(link.url)"
                />
            </div>
        </div>
    </div>

    <ViewsTrendDetailModal
        v-if="selectedAccount"
        :account-id="selectedAccount.id"
        :account-name="selectedAccount.name"
        :platform="selectedPlatform"
        :show-back-button="cameFromChart"
        @close="closeDetail"
    />

    <!-- Chart modal -->
    <div
        v-if="showChartModal"
        class="fixed inset-0 z-10 flex items-center justify-center bg-black/50 px-4 py-6 backdrop-blur-sm"
        @click.self="showChartModal = false"
    >
        <div
            class="flex h-[85vh] w-full max-w-3xl flex-col rounded-lg border shadow-2xl"
            style="background-color: var(--surface-raised); border-color: var(--border)"
        >
            <div class="flex shrink-0 items-start justify-between gap-4 border-b p-6" style="border-color: var(--border)">
                <div>
                    <h2 class="font-display text-lg font-bold" style="color: var(--ink)">Views change vs prior cycle</h2>
                    <p class="mt-0.5 text-sm" style="color: var(--ink-muted)">
                        {{ chartRows.length }} account{{ chartRows.length === 1 ? '' : 's' }}
                    </p>
                </div>
                <div class="flex shrink-0 items-center gap-4">
                    <div class="flex items-center gap-4 text-xs" style="color: var(--ink-muted)">
                        <span class="flex items-center gap-1.5"><span class="h-2.5 w-2.5 rounded-sm" style="background-color: var(--status-parah-ink)" />Down</span>
                        <span class="flex items-center gap-1.5"><span class="h-2.5 w-2.5 rounded-sm" style="background-color: var(--status-sip-ink)" />Up</span>
                    </div>
                    <button
                        type="button"
                        class="flex h-8 w-8 shrink-0 items-center justify-center rounded-md transition-colors hover:opacity-70"
                        style="color: var(--ink-muted)"
                        aria-label="Close"
                        @click="showChartModal = false"
                    >
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-5 w-5">
                            <path d="M18 6 6 18M6 6l12 12" />
                        </svg>
                    </button>
                </div>
            </div>

            <!-- Sort + trend filter, scoped to this chart only, client-side over the
                 already-loaded filtered set — no reload needed. -->
            <div class="flex shrink-0 flex-wrap items-center gap-2 border-b px-6 py-3" style="border-color: var(--border)">
                <div class="flex gap-1 rounded-lg border p-1" style="border-color: var(--border); background-color: var(--bg)">
                    <button
                        type="button"
                        class="rounded-md px-3 py-1.5 text-xs font-medium transition-colors"
                        :style="chartSort === 'best' ? 'background-color: var(--accent); color: var(--accent-ink)' : 'color: var(--ink-muted)'"
                        @click="chartSort = 'best'"
                    >
                        Best to worst
                    </button>
                    <button
                        type="button"
                        class="rounded-md px-3 py-1.5 text-xs font-medium transition-colors"
                        :style="chartSort === 'worst' ? 'background-color: var(--accent); color: var(--accent-ink)' : 'color: var(--ink-muted)'"
                        @click="chartSort = 'worst'"
                    >
                        Worst to best
                    </button>
                </div>

                <div class="flex flex-wrap gap-1 rounded-lg border p-1" style="border-color: var(--border); background-color: var(--bg)">
                    <button
                        v-for="tab in trendTabs"
                        :key="tab.value"
                        type="button"
                        class="rounded-md px-3 py-1.5 text-xs font-medium transition-colors"
                        :style="chartTrendFilter === tab.value ? 'background-color: var(--accent); color: var(--accent-ink)' : 'color: var(--ink-muted)'"
                        @click="chartTrendFilter = tab.value"
                    >
                        {{ tab.label }}
                    </button>
                </div>
            </div>

            <div class="min-h-0 flex-1 overflow-y-auto p-6">
                <div v-if="chartRows.length === 0" class="py-10 text-center text-sm" style="color: var(--ink-faint)">
                    No accounts match this chart filter.
                </div>

                <div v-else class="space-y-1.5">
                    <div v-for="row in chartRows" :key="row.row_id" class="group flex cursor-pointer items-center gap-3" @click="openDetail(row)">
                        <span class="flex w-32 shrink-0 items-center justify-end gap-1.5 truncate text-right text-xs font-medium" style="color: var(--ink-muted)">
                            <span
                                v-if="platform === 'all'"
                                class="inline-flex h-4 w-4 shrink-0 items-center justify-center rounded-full text-[8px] font-bold text-white"
                                :style="`background-color: ${platformMeta[row.platform].color}`"
                            >
                                {{ platformMeta[row.platform].label }}
                            </span>
                            <span class="truncate" :title="row.account_name">{{ row.account_name }}</span>
                        </span>
                        <div class="relative flex h-6 flex-1 items-center">
                            <!-- zero baseline -->
                            <div class="absolute inset-y-0 left-1/2 w-px" style="background-color: var(--border-strong)" />
                            <!-- negative arm (grows leftward from center) -->
                            <div class="absolute right-1/2 flex h-4 justify-end" :style="`width: 50%`">
                                <div
                                    v-if="row.delta_pct < 0"
                                    class="h-full min-w-[3px] rounded-l-sm transition-opacity group-hover:opacity-80"
                                    :style="`width: ${barWidthPct(row.delta_pct)}%; background-color: var(--status-parah-ink)`"
                                />
                            </div>
                            <!-- positive arm (grows rightward from center) -->
                            <div class="absolute left-1/2 flex h-4" :style="`width: 50%`">
                                <div
                                    v-if="row.delta_pct > 0"
                                    class="h-full min-w-[3px] rounded-r-sm transition-opacity group-hover:opacity-80"
                                    :style="`width: ${barWidthPct(row.delta_pct)}%; background-color: var(--status-sip-ink)`"
                                />
                            </div>
                        </div>
                        <span class="w-16 shrink-0 text-right text-xs font-semibold tabular-nums" :style="`color: ${deltaColor(row.delta_pct)}`">
                            {{ formatDelta(row.delta_pct) }}
                        </span>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Filter modal -->
    <div
        v-if="showFilterModal"
        class="fixed inset-0 z-10 flex items-center justify-center bg-black/50 px-4 backdrop-blur-sm"
    >
        <div
            class="w-full max-w-sm rounded-lg border p-6 shadow-2xl"
            style="background-color: var(--surface-raised); border-color: var(--border)"
        >
            <div class="flex items-start justify-between gap-4">
                <h2 class="font-display text-lg font-bold" style="color: var(--ink)">Filter</h2>
                <button
                    type="button"
                    class="flex h-8 w-8 shrink-0 items-center justify-center rounded-md transition-colors hover:opacity-70"
                    style="color: var(--ink-muted)"
                    aria-label="Close"
                    @click="closeFilterModal"
                >
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-5 w-5">
                        <path d="M18 6 6 18M6 6l12 12" />
                    </svg>
                </button>
            </div>

            <div class="mt-5 space-y-4">
                <div>
                    <label class="block text-sm font-medium" style="color: var(--ink-muted)">Platform</label>
                    <div class="mt-1.5 flex gap-1 rounded-lg border p-1" style="border-color: var(--border); background-color: var(--surface)">
                        <button
                            v-for="tab in platformTabs"
                            :key="tab.value"
                            type="button"
                            class="flex-1 rounded-md px-3 py-1.5 text-sm font-medium transition-colors"
                            :style="
                                draftPlatform === tab.value
                                    ? 'background-color: var(--accent); color: var(--accent-ink)'
                                    : 'color: var(--ink-muted)'
                            "
                            @click="draftPlatform = tab.value"
                        >
                            {{ tab.label }}
                        </button>
                    </div>
                </div>

                <div>
                    <label class="block text-sm font-medium" style="color: var(--ink-muted)">Trend</label>
                    <div class="mt-1.5 flex flex-wrap gap-1 rounded-lg border p-1" style="border-color: var(--border); background-color: var(--surface)">
                        <button
                            v-for="tab in trendTabs"
                            :key="tab.value"
                            type="button"
                            class="rounded-md px-3 py-1.5 text-sm font-medium transition-colors"
                            :style="
                                draftTrend === tab.value
                                    ? 'background-color: var(--accent); color: var(--accent-ink)'
                                    : 'color: var(--ink-muted)'
                            "
                            @click="draftTrend = tab.value"
                        >
                            {{ tab.label }}
                        </button>
                    </div>
                </div>
            </div>

            <div class="mt-6 flex items-center justify-between">
                <button
                    type="button"
                    class="text-sm font-medium transition-colors hover:opacity-70"
                    style="color: var(--ink-muted)"
                    @click="clearFilterModal"
                >
                    Reset
                </button>
                <div class="flex gap-3">
                    <button
                        type="button"
                        class="rounded-md border px-4 py-2 text-sm font-medium transition-colors hover:opacity-70"
                        style="border-color: var(--border); color: var(--ink-muted)"
                        @click="closeFilterModal"
                    >
                        Cancel
                    </button>
                    <button
                        type="button"
                        class="rounded-md px-4 py-2 text-sm font-semibold transition-opacity hover:opacity-90"
                        style="background-color: var(--accent); color: var(--accent-ink)"
                        @click="applyFilterModal"
                    >
                        Apply
                    </button>
                </div>
            </div>
        </div>
    </div>
</template>
