<script setup>
import { computed, ref } from 'vue';
import { useForm, router } from '@inertiajs/vue3';
import AppLayout from '../../Layouts/AppLayout.vue';
import StatCard from '../../Components/StatCard.vue';
import StatusBadge from '../../Components/StatusBadge.vue';
import CycleDetailModal from '../../Components/CycleDetailModal.vue';
import FilterSummaryModal from '../../Components/FilterSummaryModal.vue';
import SearchableSelect from '../../Components/SearchableSelect.vue';
import MonthRangePicker from '../../Components/MonthRangePicker.vue';
import MultiSelectDropdown from '../../Components/MultiSelectDropdown.vue';
import ActionsMenu from '../../Components/ActionsMenu.vue';
import ConfirmDialog from '../../Components/ConfirmDialog.vue';
import { useToast } from '../../composables/useToast';

const toast = useToast();

const props = defineProps({
    cycles: {
        type: Object,
        required: true,
    },
    accounts: {
        type: Array,
        required: true,
    },
    summary: {
        type: Object,
        required: true,
    },
    filters: {
        type: Object,
        default: () => ({}),
    },
    healthLabels: {
        type: Array,
        default: () => [],
    },
    availableYears: {
        type: Array,
        default: () => [],
    },
    defaultAiProvider: {
        type: String,
        default: 'groq',
    },
    scoreBuckets: {
        type: Object,
        default: () => ({}),
    },
});

const monthOptions = [
    { value: '01', label: 'January' },
    { value: '02', label: 'February' },
    { value: '03', label: 'March' },
    { value: '04', label: 'April' },
    { value: '05', label: 'May' },
    { value: '06', label: 'June' },
    { value: '07', label: 'July' },
    { value: '08', label: 'August' },
    { value: '09', label: 'September' },
    { value: '10', label: 'October' },
    { value: '11', label: 'November' },
    { value: '12', label: 'December' },
];

const columns = [
    { key: 'account', label: 'Account' },
    { key: 'cycle_start_date', label: 'Period' },
    { key: 'growth_rate', label: 'Growth' },
    { key: 'visibility_rate', label: 'Visibility' },
    { key: 'engagement_score', label: 'Engagement' },
    { key: 'health_rate', label: 'Health Rate' },
    { key: 'health_label', label: 'Health' },
];

const sortKey = ref('cycle_start_date');
const sortDir = ref('desc');

const sortBy = (key) => {
    if (sortKey.value === key) {
        sortDir.value = sortDir.value === 'asc' ? 'desc' : 'asc';
    } else {
        sortKey.value = key;
        sortDir.value = 'asc';
    }
};

const scoreKeys = ['growth_rate', 'visibility_rate', 'engagement_score', 'health_rate', 'health_label'];

const valueFor = (cycle, key) => {
    if (key === 'account') {
        return cycle.account?.name ?? '';
    }

    if (scoreKeys.includes(key)) {
        return cycle.scores[key];
    }

    return cycle[key];
};

const sortedCycles = computed(() => {
    return [...props.cycles.data].sort((a, b) => {
        const aVal = valueFor(a, sortKey.value);
        const bVal = valueFor(b, sortKey.value);

        if (aVal < bVal) return sortDir.value === 'asc' ? -1 : 1;
        if (aVal > bVal) return sortDir.value === 'asc' ? 1 : -1;
        return 0;
    });
});

const round = (value) => Math.round(value * 100) / 100;

const formatDate = (value) => {
    return new Date(value).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
};

const goToPage = (url) => {
    if (!url) return;
    router.visit(url, { preserveScroll: true, preserveState: true });
};

// Filters (search + Filter modal: account, health status, month range)

const [initialYearFrom, initialMonthNumFrom] = (props.filters.month_from ?? '').split('-');
const [initialYearTo, initialMonthNumTo] = (props.filters.month_to ?? '').split('-');

const search = ref(props.filters.search ?? '');
const accountFilter = ref(props.filters.account_id ?? '');
const healthFilter = ref(Array.isArray(props.filters.health_label) ? props.filters.health_label : []);
const monthNumFromFilter = ref(initialMonthNumFrom ?? '');
const yearFromFilter = ref(initialYearFrom ?? '');
const monthNumToFilter = ref(initialMonthNumTo ?? '');
const yearToFilter = ref(initialYearTo ?? '');
let searchTimeout = null;

const combinedMonthFrom = computed(() => {
    if (!monthNumFromFilter.value || !yearFromFilter.value) return undefined;
    return `${yearFromFilter.value}-${monthNumFromFilter.value}`;
});

const combinedMonthTo = computed(() => {
    if (!monthNumToFilter.value || !yearToFilter.value) return undefined;
    return `${yearToFilter.value}-${monthNumToFilter.value}`;
});

const filterQuery = computed(() => ({
    search: search.value || undefined,
    account_id: accountFilter.value || undefined,
    health_label: healthFilter.value.length ? healthFilter.value.join(',') : undefined,
    month_from: combinedMonthFrom.value,
    month_to: combinedMonthFrom.value ? (combinedMonthTo.value ?? combinedMonthFrom.value) : undefined,
}));

const applyFilters = () => {
    router.get('/cycles', filterQuery.value, { preserveScroll: true, preserveState: true, replace: true });
};

const onSearchInput = () => {
    clearTimeout(searchTimeout);
    searchTimeout = setTimeout(applyFilters, 300);
};

const clearSearch = () => {
    search.value = '';
    applyFilters();
};

const activeFilterCount = computed(() => {
    let count = 0;
    if (accountFilter.value) count += 1;
    if (healthFilter.value.length) count += 1;
    if (combinedMonthFrom.value) count += 1;
    return count;
});

const hasActiveFilters = computed(() => !!search.value || activeFilterCount.value > 0);

const clearAllFilters = () => {
    search.value = '';
    accountFilter.value = '';
    healthFilter.value = [];
    monthNumFromFilter.value = '';
    yearFromFilter.value = '';
    monthNumToFilter.value = '';
    yearToFilter.value = '';
    applyFilters();
};

// Filter modal

const showFilterModal = ref(false);
const draftAccountFilter = ref('');
const draftHealthFilter = ref([]);
const draftMonthFrom = ref(''); // 'YYYY-MM'
const draftMonthTo = ref(''); // 'YYYY-MM'

const openFilterModal = () => {
    draftAccountFilter.value = accountFilter.value;
    draftHealthFilter.value = [...healthFilter.value];
    draftMonthFrom.value = combinedMonthFrom.value ?? '';
    draftMonthTo.value = combinedMonthTo.value ?? '';
    showFilterModal.value = true;
};

const closeFilterModal = () => {
    showFilterModal.value = false;
};

const applyFilterModal = () => {
    accountFilter.value = draftAccountFilter.value;
    healthFilter.value = [...draftHealthFilter.value];

    const [fromYear, fromMonth] = draftMonthFrom.value.split('-');
    monthNumFromFilter.value = fromMonth ?? '';
    yearFromFilter.value = fromYear ?? '';

    const [toYear, toMonth] = draftMonthTo.value.split('-');
    monthNumToFilter.value = toMonth ?? '';
    yearToFilter.value = toYear ?? '';

    showFilterModal.value = false;
    applyFilters();
};

const clearFilterModal = () => {
    draftAccountFilter.value = '';
    draftHealthFilter.value = [];
    draftMonthFrom.value = '';
    draftMonthTo.value = '';
};

const pdfDownloadUrl = computed(() => {
    const params = new URLSearchParams(
        Object.entries(filterQuery.value).filter(([, v]) => v !== undefined),
    );
    if (filterSummaryBanner.value) {
        params.set('ai_summary', filterSummaryBanner.value.summary);
    }
    const query = params.toString();
    return `/cycles-pdf${query ? `?${query}` : ''}`;
});

// Filtered-set AI summary

const showFilterSummaryModal = ref(false);
const filterSummaryBanner = ref(null);

const filterLabelParts = computed(() => {
    const parts = [];
    if (accountFilter.value) {
        const account = props.accounts.find((a) => a.id === Number(accountFilter.value));
        if (account) parts.push(`account: ${account.name}`);
    }
    if (search.value) parts.push(`search: "${search.value}"`);
    if (healthFilter.value.length) parts.push(`health: ${healthFilter.value.join(', ')}`);
    if (combinedMonthFrom.value) {
        const fromLabel = monthOptions.find((m) => m.value === monthNumFromFilter.value)?.label ?? monthNumFromFilter.value;
        if (combinedMonthTo.value && combinedMonthTo.value !== combinedMonthFrom.value) {
            const toLabel = monthOptions.find((m) => m.value === monthNumToFilter.value)?.label ?? monthNumToFilter.value;
            parts.push(`period: ${fromLabel} ${yearFromFilter.value} - ${toLabel} ${yearToFilter.value}`);
        } else {
            parts.push(`period: ${fromLabel} ${yearFromFilter.value}`);
        }
    }
    return parts.length ? parts.join(', ') : 'none (all cycles)';
});

const openFilterSummaryModal = () => {
    showFilterSummaryModal.value = true;
};

const closeFilterSummaryModal = () => {
    showFilterSummaryModal.value = false;
};

const onSummaryGenerated = (data) => {
    filterSummaryBanner.value = data;
    showFilterSummaryModal.value = false;
};

const dismissSummaryBanner = () => {
    filterSummaryBanner.value = null;
};

// Create / edit modal

const showModal = ref(false);
const editingCycle = ref(null);

const form = useForm({
    account_id: '',
    cycle_start_date: '',
    cycle_end_date: '',
    start_follower: 0,
    end_follower: 0,
    reach: 0,
    views: 0,
    engagement: 0,
    story_performance: 0,
    ads_currency: 'IDR',
    reach_ads_used: false,
    reach_ads_spend: 0,
    views_ads_used: false,
    views_ads_spend: 0,
    engagement_ads_used: false,
    engagement_ads_spend: 0,
});

const anyAdsUsed = computed(() => form.reach_ads_used || form.views_ads_used || form.engagement_ads_used);

const openCreate = () => {
    editingCycle.value = null;
    form.reset();
    form.clearErrors();
    showModal.value = true;
};

const prefillStartFollower = async () => {
    if (editingCycle.value || !form.account_id || !form.cycle_start_date) return;

    try {
        const params = new URLSearchParams({ start_date: form.cycle_start_date });
        if (form.cycle_end_date) params.set('end_date', form.cycle_end_date);

        const response = await fetch(`/accounts/${form.account_id}/neighboring-cycle?${params}`, {
            headers: { Accept: 'application/json' },
        });
        const data = await response.json();

        applyPrefill(data);
    } catch {
        // Silently ignore — user can still fill values manually.
    }
};

const prefillEndFollower = async () => {
    if (editingCycle.value || !form.account_id || !form.cycle_end_date) return;

    try {
        const params = new URLSearchParams({ end_date: form.cycle_end_date });
        if (form.cycle_start_date) params.set('start_date', form.cycle_start_date);

        const response = await fetch(`/accounts/${form.account_id}/neighboring-cycle?${params}`, {
            headers: { Accept: 'application/json' },
        });
        const data = await response.json();

        applyPrefill(data);
    } catch {
        // Silently ignore — user can still fill values manually.
    }
};

const applyPrefill = (data) => {
    if (data.start_follower !== null && data.start_follower !== undefined) {
        form.start_follower = data.start_follower;
    }
    if (data.end_follower !== null && data.end_follower !== undefined) {
        form.end_follower = data.end_follower;
    }
    if (data.reach !== null && data.reach !== undefined) {
        form.reach = data.reach;
    }
    if (data.views !== null && data.views !== undefined) {
        form.views = data.views;
    }
    if (data.engagement !== null && data.engagement !== undefined) {
        form.engagement = data.engagement;
    }
};

const openEdit = (cycle) => {
    editingCycle.value = cycle;
    form.account_id = cycle.account_id;
    form.cycle_start_date = cycle.cycle_start_date.slice(0, 10);
    form.cycle_end_date = cycle.cycle_end_date.slice(0, 10);
    form.start_follower = cycle.start_follower;
    form.end_follower = cycle.end_follower;
    form.reach = cycle.reach;
    form.views = cycle.views;
    form.engagement = cycle.engagement;
    form.story_performance = cycle.story_performance ?? 0;
    form.ads_currency = cycle.ads_currency ?? 'IDR';
    form.reach_ads_used = cycle.reach_ads_used ?? false;
    form.reach_ads_spend = cycle.reach_ads_spend ?? 0;
    form.views_ads_used = cycle.views_ads_used ?? false;
    form.views_ads_spend = cycle.views_ads_spend ?? 0;
    form.engagement_ads_used = cycle.engagement_ads_used ?? false;
    form.engagement_ads_spend = cycle.engagement_ads_spend ?? 0;
    form.clearErrors();
    showModal.value = true;
};

const closeModal = () => {
    showModal.value = false;
    editingCycle.value = null;
    form.reset();
    form.clearErrors();
};

const submit = () => {
    const isEditing = !!editingCycle.value;
    const options = {
        preserveScroll: true,
        onSuccess: () => {
            showModal.value = false;
            editingCycle.value = null;
            form.reset();
            form.clearErrors();
            toast.success(isEditing ? 'Cycle updated.' : 'Cycle added.');
        },
        onError: () => {
            toast.error(isEditing ? 'Failed to update cycle.' : 'Failed to add cycle.');
        },
    };

    if (isEditing) {
        form.put(`/cycles/${editingCycle.value.id}`, options);
    } else {
        form.post('/cycles', options);
    }
};

// Delete confirmation

const deletingCycle = ref(null);
const deleting = ref(false);

const confirmDestroy = (cycle) => {
    deletingCycle.value = cycle;
};

const cancelDestroy = () => {
    deletingCycle.value = null;
};

const destroy = () => {
    if (!deletingCycle.value) return;
    deleting.value = true;

    router.delete(`/cycles/${deletingCycle.value.id}`, {
        preserveScroll: true,
        onSuccess: () => {
            toast.success('Cycle deleted.');
            deletingCycle.value = null;
        },
        onError: () => toast.error('Failed to delete cycle.'),
        onFinish: () => {
            deleting.value = false;
        },
    });
};

// Detail modal

const viewingCycle = ref(null);

const openDetail = (cycle) => {
    viewingCycle.value = cycle;
};

const closeDetail = () => {
    viewingCycle.value = null;
};

const inputStyle =
    'mt-1 w-full rounded-md border px-3 py-2 text-sm transition-colors focus:outline-none focus:ring-2';
</script>

<template>
    <AppLayout>
        <div class="flex items-start justify-between gap-4">
            <div>
                <h1 class="font-display text-2xl font-bold tracking-tight" style="color: var(--ink)">
                    Performance Cycles
                </h1>
                <p class="mt-1 text-sm" style="color: var(--ink-muted)">
                    Growth, visibility, and engagement scored per reporting cycle.
                </p>
            </div>
            <button
                type="button"
                class="shrink-0 rounded-md px-4 py-2 text-sm font-semibold transition-opacity hover:opacity-90"
                style="background-color: var(--accent); color: var(--accent-ink)"
                @click="openCreate"
            >
                + Add Cycle
            </button>
        </div>

        <div v-if="summary.total > 0" class="mt-6 grid grid-cols-2 gap-3 sm:grid-cols-4">
            <StatCard label="Cycles Tracked" :value="String(summary.total)" />
            <StatCard
                label="Avg Health Rate"
                :value="String(summary.avg_health_rate)"
                :hint="`across ${summary.total} cycle${summary.total === 1 ? '' : 's'}`"
            />
            <StatCard label="Healthy (SIP)" :value="String(summary.healthy_count)" hint="cycles at top tier" />
            <StatCard label="Needs Attention" :value="String(summary.at_risk_count)" hint="KURANG or PARAH" />
        </div>

        <div class="mt-8 flex flex-wrap items-center gap-3">
            <div class="relative max-w-xs flex-1">
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

            <button
                v-if="hasActiveFilters"
                type="button"
                class="text-sm font-medium transition-colors hover:opacity-70"
                style="color: var(--ink-muted)"
                @click="clearAllFilters"
            >
                Clear filters
            </button>

            <button
                type="button"
                class="ml-auto inline-flex items-center gap-1.5 rounded-md border px-3 py-2 text-sm font-medium transition-colors hover:opacity-70"
                style="border-color: var(--border); color: var(--ink)"
                @click="openFilterSummaryModal"
            >
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-4 w-4">
                    <path d="M12 3v3m0 12v3m9-9h-3M6 12H3m15.5-6.5-2.1 2.1M8.6 15.4l-2.1 2.1m0-11 2.1 2.1m9 9-2.1-2.1" />
                    <circle cx="12" cy="12" r="3.5" />
                </svg>
                Summarize with AI
            </button>

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

        <div
            v-if="filterSummaryBanner"
            class="mt-4 rounded-lg border p-4"
            style="border-color: var(--accent); background-color: var(--surface)"
        >
            <div class="flex items-start justify-between gap-4">
                <div>
                    <p class="text-xs font-semibold uppercase tracking-wide" style="color: var(--accent)">AI Summary</p>
                    <p class="mt-1 text-sm leading-relaxed" style="color: var(--ink)">{{ filterSummaryBanner.summary }}</p>
                    <p class="mt-2 text-xs" style="color: var(--ink-faint)">
                        Based on {{ filterSummaryBanner.cycle_count }} cycle{{ filterSummaryBanner.cycle_count === 1 ? '' : 's' }}
                        &middot; {{ filterSummaryBanner.filter_summary }}
                    </p>
                </div>
                <button
                    type="button"
                    class="shrink-0 rounded-md p-1 transition-colors hover:opacity-70"
                    style="color: var(--ink-faint)"
                    aria-label="Dismiss summary"
                    @click="dismissSummaryBanner"
                >
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-4 w-4">
                        <path d="M18 6 6 18M6 6l12 12" />
                    </svg>
                </button>
            </div>
        </div>

        <div
            class="mt-3 overflow-hidden rounded-lg border"
            style="border-color: var(--border); background-color: var(--surface)"
        >
            <div class="overflow-x-auto">
                <table class="w-full min-w-[900px]">
                    <thead>
                        <tr style="border-bottom: 1px solid var(--border)">
                            <th
                                v-for="column in columns"
                                :key="column.key"
                                class="cursor-pointer select-none whitespace-nowrap px-3 py-3 text-left text-xs font-semibold uppercase tracking-wide transition-colors"
                                style="color: var(--ink-faint)"
                                @click="sortBy(column.key)"
                            >
                                <span class="inline-flex items-center gap-1">
                                    {{ column.label }}
                                    <span v-if="sortKey === column.key" style="color: var(--accent)">
                                        {{ sortDir === 'asc' ? '↑' : '↓' }}
                                    </span>
                                </span>
                            </th>
                            <th
                                class="whitespace-nowrap px-3 py-3 text-right text-xs font-semibold uppercase tracking-wide"
                                style="color: var(--ink-faint)"
                            >
                                Actions
                            </th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr
                            v-for="cycle in sortedCycles"
                            :key="cycle.id"
                            class="group cursor-pointer transition-colors hover:opacity-80"
                            style="border-bottom: 1px solid var(--border)"
                            @click="openDetail(cycle)"
                        >
                            <td class="max-w-[130px] truncate px-3 py-3.5 text-sm font-medium" :title="cycle.account?.name" style="color: var(--ink)">
                                {{ cycle.account?.name }}
                            </td>
                            <td class="whitespace-nowrap px-3 py-3.5 text-sm" style="color: var(--ink-muted)">
                                {{ formatDate(cycle.cycle_start_date) }} – {{ formatDate(cycle.cycle_end_date) }}
                            </td>
                            <td
                                class="whitespace-nowrap px-3 py-3.5 text-sm font-medium tabular-nums"
                                :style="cycle.scores.growth_rate < 0 ? 'color: var(--status-parah-ink)' : 'color: var(--ink)'"
                            >
                                {{ round(cycle.scores.growth_rate) }}%
                            </td>
                            <td class="whitespace-nowrap px-3 py-3.5 text-sm tabular-nums" style="color: var(--ink)">
                                {{ round(cycle.scores.visibility_rate) }}
                            </td>
                            <td class="whitespace-nowrap px-3 py-3.5 text-sm tabular-nums" style="color: var(--ink)">
                                {{ round(cycle.scores.engagement_score) }}
                            </td>
                            <td class="whitespace-nowrap px-3 py-3.5 text-sm font-semibold tabular-nums" style="color: var(--ink)">
                                {{ round(cycle.scores.health_rate) }}
                            </td>
                            <td class="whitespace-nowrap px-3 py-3.5 text-sm">
                                <StatusBadge :status="cycle.scores.health_label" />
                            </td>
                            <td class="whitespace-nowrap px-3 py-3.5 text-right text-sm" @click.stop>
                                <ActionsMenu
                                    :items="[
                                        { label: 'View', onClick: () => openDetail(cycle) },
                                        { label: 'Edit', onClick: () => openEdit(cycle) },
                                        { label: 'Delete', danger: true, onClick: () => confirmDestroy(cycle) },
                                    ]"
                                />
                            </td>
                        </tr>
                        <tr v-if="sortedCycles.length === 0">
                            <td colspan="8" class="px-4 py-12 text-center text-sm" style="color: var(--ink-faint)">
                                <template v-if="hasActiveFilters">No cycles match the current filters.</template>
                                <template v-else>No cycles yet. Add your first cycle to see health scores.</template>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <div
                v-if="cycles.last_page > 1"
                class="flex items-center justify-between border-t px-4 py-3"
                style="border-color: var(--border)"
            >
                <p class="text-sm" style="color: var(--ink-muted)">
                    Showing <span class="font-medium tabular-nums" style="color: var(--ink)">{{ cycles.from }}–{{ cycles.to }}</span>
                    of <span class="font-medium tabular-nums" style="color: var(--ink)">{{ cycles.total }}</span>
                </p>
                <div class="flex items-center gap-1">
                    <button
                        v-for="link in cycles.links"
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

        <!-- Create / Edit modal -->
        <div
            v-if="showModal"
            class="fixed inset-0 z-10 flex items-center justify-center bg-black/50 px-4 backdrop-blur-sm"
        >
            <div
                class="w-full max-w-lg rounded-lg border p-6 shadow-2xl"
                style="background-color: var(--surface-raised); border-color: var(--border)"
            >
                <div class="flex items-start justify-between gap-4">
                    <h2 class="font-display text-lg font-bold" style="color: var(--ink)">
                        {{ editingCycle ? 'Edit Cycle' : 'Add Cycle' }}
                    </h2>
                    <button
                        type="button"
                        class="flex h-8 w-8 shrink-0 items-center justify-center rounded-md transition-colors hover:opacity-70"
                        style="color: var(--ink-muted)"
                        aria-label="Close"
                        @click="closeModal"
                    >
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-5 w-5">
                            <path d="M18 6 6 18M6 6l12 12" />
                        </svg>
                    </button>
                </div>

                <form @submit.prevent="submit" class="mt-5 space-y-4">
                    <div>
                        <label class="block text-sm font-medium" style="color: var(--ink-muted)">Account</label>
                        <SearchableSelect
                            v-model="form.account_id"
                            :options="accounts"
                            placeholder="Select an account"
                            class="mt-1"
                        />
                        <p v-if="form.errors.account_id" class="mt-1 text-sm" style="color: var(--status-parah-ink)">
                            {{ form.errors.account_id }}
                        </p>
                    </div>

                    <div class="grid grid-cols-2 gap-4">
                        <div>
                            <label class="block text-sm font-medium" style="color: var(--ink-muted)">Cycle Start</label>
                            <input
                                v-model="form.cycle_start_date"
                                type="date"
                                :class="inputStyle"
                                style="border-color: var(--border); background-color: var(--surface); color: var(--ink)"
                                @change="prefillStartFollower"
                            />
                            <p v-if="!editingCycle && form.account_id && form.cycle_start_date" class="mt-1 text-xs" style="color: var(--ink-faint)">
                                Followers, reach, views &amp; engagement auto-fill from connected Instagram data, or a neighboring cycle, if available.
                            </p>
                            <p v-if="form.errors.cycle_start_date" class="mt-1 text-sm" style="color: var(--status-parah-ink)">
                                {{ form.errors.cycle_start_date }}
                            </p>
                        </div>
                        <div>
                            <label class="block text-sm font-medium" style="color: var(--ink-muted)">Cycle End</label>
                            <input
                                v-model="form.cycle_end_date"
                                type="date"
                                :class="inputStyle"
                                style="border-color: var(--border); background-color: var(--surface); color: var(--ink)"
                                @change="prefillEndFollower"
                            />
                            <p v-if="!editingCycle && form.account_id && form.cycle_end_date" class="mt-1 text-xs" style="color: var(--ink-faint)">
                                Followers, reach, views &amp; engagement auto-fill from connected Instagram data, or a neighboring cycle, if available.
                            </p>
                            <p v-if="form.errors.cycle_end_date" class="mt-1 text-sm" style="color: var(--status-parah-ink)">
                                {{ form.errors.cycle_end_date }}
                            </p>
                        </div>
                    </div>

                    <div class="grid grid-cols-2 gap-4">
                        <div>
                            <label class="block text-sm font-medium" style="color: var(--ink-muted)">Start Followers</label>
                            <input
                                v-model.number="form.start_follower"
                                type="number"
                                min="0"
                                :class="inputStyle"
                                style="border-color: var(--border); background-color: var(--surface); color: var(--ink)"
                            />
                            <p v-if="form.errors.start_follower" class="mt-1 text-sm" style="color: var(--status-parah-ink)">
                                {{ form.errors.start_follower }}
                            </p>
                        </div>
                        <div>
                            <label class="block text-sm font-medium" style="color: var(--ink-muted)">End Followers</label>
                            <input
                                v-model.number="form.end_follower"
                                type="number"
                                min="0"
                                :class="inputStyle"
                                style="border-color: var(--border); background-color: var(--surface); color: var(--ink)"
                            />
                            <p v-if="form.errors.end_follower" class="mt-1 text-sm" style="color: var(--status-parah-ink)">
                                {{ form.errors.end_follower }}
                            </p>
                        </div>
                    </div>

                    <div class="grid grid-cols-3 gap-4">
                        <div>
                            <label class="block text-sm font-medium" style="color: var(--ink-muted)">Reach</label>
                            <input
                                v-model.number="form.reach"
                                type="number"
                                min="0"
                                :class="inputStyle"
                                style="border-color: var(--border); background-color: var(--surface); color: var(--ink)"
                            />
                            <p v-if="form.errors.reach" class="mt-1 text-sm" style="color: var(--status-parah-ink)">
                                {{ form.errors.reach }}
                            </p>
                        </div>
                        <div>
                            <label class="block text-sm font-medium" style="color: var(--ink-muted)">Views</label>
                            <input
                                v-model.number="form.views"
                                type="number"
                                min="0"
                                :class="inputStyle"
                                style="border-color: var(--border); background-color: var(--surface); color: var(--ink)"
                            />
                            <p v-if="form.errors.views" class="mt-1 text-sm" style="color: var(--status-parah-ink)">
                                {{ form.errors.views }}
                            </p>
                        </div>
                        <div>
                            <label class="block text-sm font-medium" style="color: var(--ink-muted)">Engagement</label>
                            <input
                                v-model.number="form.engagement"
                                type="number"
                                min="0"
                                :class="inputStyle"
                                style="border-color: var(--border); background-color: var(--surface); color: var(--ink)"
                            />
                            <p v-if="form.errors.engagement" class="mt-1 text-sm" style="color: var(--status-parah-ink)">
                                {{ form.errors.engagement }}
                            </p>
                        </div>
                    </div>

                    <div>
                        <label class="block text-sm font-medium" style="color: var(--ink-muted)">Story Performance</label>
                        <input
                            v-model.number="form.story_performance"
                            type="number"
                            min="0"
                            :class="inputStyle"
                            style="border-color: var(--border); background-color: var(--surface); color: var(--ink)"
                        />
                        <p v-if="form.errors.story_performance" class="mt-1 text-sm" style="color: var(--status-parah-ink)">
                            {{ form.errors.story_performance }}
                        </p>
                    </div>

                    <div class="space-y-3 rounded-md border p-3" style="border-color: var(--border)">
                        <p class="text-sm font-medium" style="color: var(--ink-muted)">Ads Spend</p>

                        <div v-if="anyAdsUsed">
                            <label class="block text-xs font-medium" style="color: var(--ink-muted)">Currency</label>
                            <select
                                v-model="form.ads_currency"
                                :class="inputStyle"
                                style="border-color: var(--border); background-color: var(--surface); color: var(--ink); max-width: 10rem"
                            >
                                <option value="IDR">IDR</option>
                                <option value="USD">USD</option>
                                <option value="EUR">EUR</option>
                            </select>
                        </div>

                        <div v-for="metric in ['reach', 'views', 'engagement']" :key="metric">
                            <label class="flex items-center gap-2 text-sm" style="color: var(--ink)">
                                <input
                                    v-model="form[`${metric}_ads_used`]"
                                    type="checkbox"
                                    class="h-4 w-4 rounded"
                                    style="accent-color: var(--accent)"
                                />
                                Used ads for {{ metric === 'reach' ? 'Reach' : metric === 'views' ? 'Views' : 'Engagement' }}?
                            </label>
                            <input
                                v-if="form[`${metric}_ads_used`]"
                                v-model.number="form[`${metric}_ads_spend`]"
                                type="number"
                                min="0"
                                step="0.01"
                                placeholder="Amount spent"
                                class="mt-1.5"
                                :class="inputStyle"
                                style="border-color: var(--border); background-color: var(--surface); color: var(--ink)"
                            />
                            <p v-if="form.errors[`${metric}_ads_spend`]" class="mt-1 text-sm" style="color: var(--status-parah-ink)">
                                {{ form.errors[`${metric}_ads_spend`] }}
                            </p>
                        </div>
                    </div>

                    <div class="flex justify-end gap-3 pt-2">
                        <button
                            type="button"
                            class="rounded-md border px-4 py-2 text-sm font-medium transition-colors hover:opacity-70"
                            style="border-color: var(--border); color: var(--ink-muted)"
                            @click="closeModal"
                        >
                            Cancel
                        </button>
                        <button
                            type="submit"
                            :disabled="form.processing"
                            class="rounded-md px-4 py-2 text-sm font-semibold transition-opacity hover:opacity-90 disabled:opacity-50"
                            style="background-color: var(--accent); color: var(--accent-ink)"
                        >
                            {{ editingCycle ? 'Save Changes' : 'Add Cycle' }}
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <CycleDetailModal
            v-if="viewingCycle"
            :cycle="viewingCycle"
            :default-ai-provider="defaultAiProvider"
            :score-buckets="scoreBuckets"
            @close="closeDetail"
        />

        <FilterSummaryModal
            v-if="showFilterSummaryModal"
            :filter-query="filterQuery"
            :filter-label="filterLabelParts"
            :default-ai-provider="defaultAiProvider"
            @close="closeFilterSummaryModal"
            @generated="onSummaryGenerated"
        />

        <ConfirmDialog
            :open="!!deletingCycle"
            title="Delete this cycle?"
            :message="deletingCycle ? `This will permanently remove the cycle for ${deletingCycle.account?.name} (${formatDate(deletingCycle.cycle_start_date)} – ${formatDate(deletingCycle.cycle_end_date)}). This cannot be undone.` : ''"
            :processing="deleting"
            @confirm="destroy"
            @cancel="cancelDestroy"
        />

        <!-- Filter modal -->
        <div
            v-if="showFilterModal"
            class="fixed inset-0 z-10 flex items-center justify-center bg-black/50 px-4 py-6 backdrop-blur-sm"
        >
            <div
                class="flex max-h-full w-full max-w-sm flex-col rounded-lg border shadow-2xl"
                style="background-color: var(--surface-raised); border-color: var(--border)"
            >
                <div class="flex shrink-0 items-start justify-between gap-4 p-6 pb-0">
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

                <div class="min-h-0 flex-1 space-y-4 overflow-y-auto p-6">
                    <div>
                        <label class="block text-sm font-medium" style="color: var(--ink-muted)">Account</label>
                        <SearchableSelect
                            v-model="draftAccountFilter"
                            :options="accounts"
                            clearable
                            clear-label="All accounts"
                            class="mt-1"
                        />
                    </div>

                    <div>
                        <label class="block text-sm font-medium" style="color: var(--ink-muted)">Health Status</label>
                        <MultiSelectDropdown
                            v-model="draftHealthFilter"
                            :options="healthLabels"
                            placeholder="All health statuses"
                            class="mt-1"
                        />
                    </div>

                    <div>
                        <label class="block text-sm font-medium" style="color: var(--ink-muted)">Cycle Month Range</label>
                        <p v-if="draftMonthFrom" class="mt-1 text-sm" style="color: var(--ink)">
                            {{ draftMonthFrom }}<template v-if="draftMonthTo && draftMonthTo !== draftMonthFrom"> – {{ draftMonthTo }}</template>
                        </p>
                        <MonthRangePicker
                            v-model:model-from="draftMonthFrom"
                            v-model:model-to="draftMonthTo"
                            class="mt-1"
                        />
                        <p class="mt-1.5 text-xs" style="color: var(--ink-faint)">
                            Filters by the cycle's start date. Click a month to start, click another to set a range.
                        </p>
                    </div>
                </div>

                <div class="flex shrink-0 items-center justify-between border-t p-6 pt-4" style="border-color: var(--border)">
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
    </AppLayout>
</template>
