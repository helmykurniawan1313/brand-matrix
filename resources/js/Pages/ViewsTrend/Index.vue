<script setup>
import { computed, ref } from 'vue';
import { router } from '@inertiajs/vue3';
import AppLayout from '../../Layouts/AppLayout.vue';
import ViewsTrendDetailModal from '../../Components/ViewsTrendDetailModal.vue';

defineOptions({ layout: AppLayout });

const props = defineProps({
    filters: { type: Object, required: true },
    rows: { type: Object, required: true },
    counts: { type: Object, required: true },
});

const platform = ref(props.filters.platform ?? 'all');
const trendFilter = ref(props.filters.trend ?? 'all');
const sort = ref(props.filters.sort ?? 'trend');
const direction = ref(props.filters.direction ?? 'asc');

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
            platform: platform.value,
            trend: trendFilter.value === 'all' ? undefined : trendFilter.value,
            sort: sort.value === 'trend' ? undefined : sort.value,
            direction: direction.value === 'asc' ? undefined : direction.value,
        },
        { preserveState: true, preserveScroll: true },
    );
};

const setTrendFilter = (value) => {
    trendFilter.value = value;
    applyFilters();
};

const setPlatform = (value) => {
    platform.value = value;
    applyFilters();
};

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

// --- Diverging bar chart: Δ% per account on this page, ranked worst -> best. ---
// This is the page's headline story (who fell back, who grew) — the table below
// is the complete, sortable detail view. Only rows with a real delta plot; an
// "insufficient data" row (delta_pct === null) has nothing to diverge from.
const chartRows = computed(() =>
    props.rows.data
        .filter((row) => row.delta_pct !== null)
        .slice()
        .sort((a, b) => a.delta_pct - b.delta_pct),
);

const maxAbsDelta = computed(() => {
    const max = Math.max(10, ...chartRows.value.map((row) => Math.abs(row.delta_pct)));
    return Math.ceil(max / 10) * 10;
});

const barWidthPct = (delta) => (Math.abs(delta) / maxAbsDelta.value) * 50;

// Detail modal — reuses the same growth modal used on the Accounts page.
const selectedAccount = ref(null);
const selectedPlatform = ref('instagram');
const openDetail = (row) => {
    selectedAccount.value = { id: row.account_id, name: row.account_name };
    selectedPlatform.value = row.platform;
};
const closeDetail = () => {
    selectedAccount.value = null;
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

    <!-- Diverging bar chart: the headline view. -->
    <div class="mt-6 rounded-lg border p-5" style="border-color: var(--border); background-color: var(--surface)">
        <div class="flex items-center justify-between">
            <div>
                <h2 class="text-sm font-semibold" style="color: var(--ink)">Views change vs prior cycle</h2>
                <p class="mt-0.5 text-xs" style="color: var(--ink-muted)">This page's accounts, ranked worst to best</p>
            </div>
            <div class="flex items-center gap-4 text-xs" style="color: var(--ink-muted)">
                <span class="flex items-center gap-1.5"><span class="h-2.5 w-2.5 rounded-sm" style="background-color: var(--status-parah-ink)" />Down</span>
                <span class="flex items-center gap-1.5"><span class="h-2.5 w-2.5 rounded-sm" style="background-color: var(--status-sip-ink)" />Up</span>
            </div>
        </div>

        <div v-if="chartRows.length === 0" class="py-10 text-center text-sm" style="color: var(--ink-faint)">
            No accounts with a comparable prior cycle on this page.
        </div>

        <div v-else class="mt-5 space-y-1.5">
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
                            class="h-full rounded-l-sm transition-opacity group-hover:opacity-80"
                            :style="`width: ${barWidthPct(row.delta_pct)}%; background-color: var(--status-parah-ink)`"
                        />
                    </div>
                    <!-- positive arm (grows rightward from center) -->
                    <div class="absolute left-1/2 flex h-4" :style="`width: 50%`">
                        <div
                            v-if="row.delta_pct > 0"
                            class="h-full rounded-r-sm transition-opacity group-hover:opacity-80"
                            :style="`width: ${barWidthPct(row.delta_pct)}%; background-color: var(--status-sip-ink)`"
                        />
                    </div>
                </div>
                <span class="w-14 shrink-0 text-right text-xs font-semibold tabular-nums" :style="`color: ${deltaColor(row.delta_pct)}`">
                    {{ formatDelta(row.delta_pct) }}
                </span>
            </div>
        </div>
    </div>

    <!-- Full detail table -->
    <div class="mt-6 flex flex-wrap items-center gap-1 rounded-lg border p-1 sm:w-fit" style="border-color: var(--border); background-color: var(--surface)">
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
                        <td class="px-4 py-3.5 text-right text-sm font-semibold tabular-nums" :style="`color: ${deltaColor(row.delta_pct)}`">
                            {{ formatDelta(row.delta_pct) }}
                        </td>
                        <td class="px-4 py-3.5 text-sm" style="color: var(--ink-muted)">{{ row.last_cycle_label }}</td>
                        <td class="px-4 py-3.5 text-right text-sm" style="color: var(--ink-faint)">View →</td>
                    </tr>
                    <tr v-if="rows.data.length === 0">
                        <td :colspan="platform === 'all' ? 8 : 7" class="px-4 py-12 text-center text-sm" style="color: var(--ink-faint)">
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
        @close="closeDetail"
    />
</template>
