<script setup>
import { computed, nextTick, onBeforeUnmount, onMounted, ref, watch } from 'vue';
import { router } from '@inertiajs/vue3';
import Chart from '../../chartSetup';
import AppLayout from '../../Layouts/AppLayout.vue';

import PerformanceFormModal from '../../Components/PerformanceFormModal.vue';
import PerformanceDetailModal from '../../Components/PerformanceDetailModal.vue';
import FilterSummaryModal from '../../Components/FilterSummaryModal.vue';
import StatCard from '../../Components/StatCard.vue';
import StatusBadge from '../../Components/StatusBadge.vue';
import SearchableSelect from '../../Components/SearchableSelect.vue';
import MultiSelectDropdown from '../../Components/MultiSelectDropdown.vue';
import ActionsMenu from '../../Components/ActionsMenu.vue';
import ConfirmDialog from '../../Components/ConfirmDialog.vue';
import { useToast } from '../../composables/useToast';
import { useAuth } from '../../composables/useAuth';

defineOptions({ layout: AppLayout });

const toast = useToast();
const { canEdit } = useAuth();

const props = defineProps({
    performances: {
        type: Object,
        required: true,
    },
    accounts: {
        type: Array,
        required: true,
    },
    employees: {
        type: Array,
        required: true,
    },
    accountDepartmentEmployees: {
        type: Array,
        required: true,
    },
    filters: {
        type: Object,
        default: () => ({}),
    },
    viewsStatusOptions: {
        type: Array,
        default: () => [],
    },
    noteOptions: {
        type: Array,
        default: () => [],
    },
    viewsBuckets: {
        type: Array,
        default: () => [],
    },
    followerBuckets: {
        type: Array,
        default: () => [],
    },
    summary: {
        type: Object,
        default: () => ({}),
    },
    statusDistribution: {
        type: Object,
        default: () => ({}),
    },
    topTierLabels: {
        type: Array,
        default: () => [],
    },
    bottomTierLabels: {
        type: Array,
        default: () => [],
    },
    defaultAiProvider: {
        type: String,
        default: 'groq',
    },
});

// --- Filters ---

const search = ref(props.filters.search ?? '');
const accountFilter = ref(props.filters.account_id ?? '');
const pmFilter = ref(props.filters.project_manager_id ?? '');
const conceptorFilter = ref(props.filters.conceptor_id ?? '');
const viewsStatusFilter = ref(props.filters.views_status ? props.filters.views_status.split(',').filter(Boolean) : []);
const adsFilter = ref(
    props.filters.ads === null || props.filters.ads === undefined
        ? ''
        : props.filters.ads === 'null'
          ? 'null'
          : props.filters.ads
            ? '1'
            : '0',
);
const postDateFromFilter = ref(props.filters.post_date_from ?? '');
const postDateToFilter = ref(props.filters.post_date_to ?? '');
const viewsH7Filter = ref(props.filters.views_h7 ?? '');
const platformFilter = ref(props.filters.platform ?? '');
const sort = ref(props.filters.sort ?? '');
const direction = ref(props.filters.direction ?? 'asc');
let searchTimeout = null;

const filterQuery = () => ({
    search: search.value || undefined,
    account_id: accountFilter.value || undefined,
    project_manager_id: pmFilter.value || undefined,
    conceptor_id: conceptorFilter.value || undefined,
    views_status: viewsStatusFilter.value.length ? viewsStatusFilter.value.join(',') : undefined,
    ads: adsFilter.value || undefined,
    post_date_from: postDateFromFilter.value || undefined,
    post_date_to: postDateToFilter.value || undefined,
    views_h7: viewsH7Filter.value || undefined,
    platform: platformFilter.value || undefined,
    sort: sort.value || undefined,
    direction: sort.value ? direction.value : undefined,
});

const applyFilters = () => {
    router.get('/performances', filterQuery(), { preserveScroll: true, preserveState: true, replace: true });
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
    const { search: _search, sort: _sort, direction: _direction, ...rest } = filterQuery();
    return Object.values(rest).filter((v) => v !== undefined).length;
});
const hasActiveFilters = computed(() => !!search.value || activeFilterCount.value > 0);

const clearAllFilters = () => {
    search.value = '';
    accountFilter.value = '';
    pmFilter.value = '';
    conceptorFilter.value = '';
    viewsStatusFilter.value = [];
    adsFilter.value = '';
    postDateFromFilter.value = '';
    postDateToFilter.value = '';
    viewsH7Filter.value = '';
    platformFilter.value = '';
    applyFilters();
};

// KPI tiles/banner are clickable shortcuts onto the same views-status filter
// the Filter modal exposes — scrolls to the (now-filtered) table so the click
// reads as "show me those records," not just a static count.
const filterByViewsStatus = (labels) => {
    viewsStatusFilter.value = [...labels];
    applyFilters();
    document.getElementById('performance-table')?.scrollIntoView({ behavior: 'smooth', block: 'start' });
};

const sortBy = (column) => {
    if (sort.value === column) {
        direction.value = direction.value === 'asc' ? 'desc' : 'asc';
    } else {
        sort.value = column;
        direction.value = 'asc';
    }
    applyFilters();
};

// --- Filter modal (draft state, only applied on "Apply") ---

const showFilterModal = ref(false);
const draftAccountFilter = ref('');
const draftPmFilter = ref('');
const draftConceptorFilter = ref('');
const draftViewsStatusFilter = ref([]);
const draftAdsFilter = ref('');
const draftPostDateFromFilter = ref('');
const draftPostDateToFilter = ref('');
const draftViewsH7Filter = ref('');
const draftPlatformFilter = ref('');

const openFilterModal = () => {
    draftAccountFilter.value = accountFilter.value;
    draftPmFilter.value = pmFilter.value;
    draftConceptorFilter.value = conceptorFilter.value;
    draftViewsStatusFilter.value = [...viewsStatusFilter.value];
    draftAdsFilter.value = adsFilter.value;
    draftPostDateFromFilter.value = postDateFromFilter.value;
    draftPostDateToFilter.value = postDateToFilter.value;
    draftViewsH7Filter.value = viewsH7Filter.value;
    draftPlatformFilter.value = platformFilter.value;
    showFilterModal.value = true;
};

const closeFilterModal = () => {
    showFilterModal.value = false;
};

const applyFilterModal = () => {
    accountFilter.value = draftAccountFilter.value;
    pmFilter.value = draftPmFilter.value;
    conceptorFilter.value = draftConceptorFilter.value;
    viewsStatusFilter.value = [...draftViewsStatusFilter.value];
    adsFilter.value = draftAdsFilter.value;
    postDateFromFilter.value = draftPostDateFromFilter.value;
    postDateToFilter.value = draftPostDateToFilter.value;
    viewsH7Filter.value = draftViewsH7Filter.value;
    platformFilter.value = draftPlatformFilter.value;
    showFilterModal.value = false;
    applyFilters();
};

const clearFilterModal = () => {
    draftAccountFilter.value = '';
    draftPmFilter.value = '';
    draftConceptorFilter.value = '';
    draftViewsStatusFilter.value = [];
    draftAdsFilter.value = '';
    draftPostDateFromFilter.value = '';
    draftPostDateToFilter.value = '';
    draftViewsH7Filter.value = '';
    draftPlatformFilter.value = '';
};

const inputStyle =
    'mt-1 w-full rounded-md border px-3 py-2 text-sm transition-colors focus:outline-none';

// PDF export + filtered-set AI summary

const pdfDownloadUrl = computed(() => {
    const params = new URLSearchParams(
        Object.entries(filterQuery()).filter(([, v]) => v !== undefined),
    );
    if (filterSummaryBanner.value) {
        params.set('ai_summary', filterSummaryBanner.value.summary);
    }
    const query = params.toString();
    return `/performances-pdf${query ? `?${query}` : ''}`;
});

const excelDownloadUrl = computed(() => {
    const params = new URLSearchParams(
        Object.entries(filterQuery()).filter(([, v]) => v !== undefined),
    );
    const query = params.toString();
    return `/performances-excel${query ? `?${query}` : ''}`;
});

const showFilterSummaryModal = ref(false);
const filterSummaryBanner = ref(null);

const filterLabelParts = computed(() => {
    const parts = [];
    if (accountFilter.value) {
        const account = props.accounts.find((a) => a.id === Number(accountFilter.value));
        if (account) parts.push(`account: ${account.name}`);
    }
    if (search.value) parts.push(`search: "${search.value}"`);
    if (platformFilter.value) parts.push(`platform: ${platformFilter.value === 'instagram' ? 'Instagram' : 'TikTok'}`);
    if (viewsStatusFilter.value.length) parts.push(`status: ${viewsStatusFilter.value.join(', ')}`);
    if (adsFilter.value) parts.push(`ads: ${adsFilter.value === '1' ? 'Yes' : adsFilter.value === '0' ? 'No' : '-'}`);
    if (postDateFromFilter.value) {
        parts.push(`post date: ${postDateFromFilter.value}${postDateToFilter.value ? ` to ${postDateToFilter.value}` : '+'}`);
    }
    if (viewsH7Filter.value) {
        parts.push(`views H+7: ${viewsH7Filter.value === 'null' ? 'empty' : 'not empty'}`);
    }
    return parts.length ? parts.join(', ') : 'none (all records)';
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

const goToPage = (url) => {
    if (!url) return;
    router.visit(url, { preserveScroll: true, preserveState: true });
};

const showCreateModal = ref(false);
const editingPerformance = ref(null);
const viewingPerformance = ref(null);

const openDetail = (performance) => {
    viewingPerformance.value = performance;
};

const closeDetail = () => {
    viewingPerformance.value = null;
};

const openCreate = () => {
    showCreateModal.value = true;
};

const closeCreate = () => {
    showCreateModal.value = false;
};

const startEdit = (performance) => {
    editingPerformance.value = performance;
};

const editFromDetail = (performance) => {
    viewingPerformance.value = null;
    editingPerformance.value = performance;
};

const cancelEdit = () => {
    editingPerformance.value = null;
};

// Delete confirmation

const deletingPerformance = ref(null);
const deleting = ref(false);

const confirmDestroy = (performance) => {
    deletingPerformance.value = performance;
};

const cancelDestroy = () => {
    deletingPerformance.value = null;
};

const destroy = () => {
    if (!deletingPerformance.value) return;
    deleting.value = true;

    router.delete(`/performances/${deletingPerformance.value.id}`, {
        preserveScroll: true,
        onSuccess: () => {
            toast.success('Performance record deleted.');
            deletingPerformance.value = null;
        },
        onError: () => toast.error('Failed to delete performance record.'),
        onFinish: () => {
            deleting.value = false;
        },
    });
};

const formatDate = (value) => {
    if (!value) return '—';
    return new Date(value).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
};

const formatNumber = (value) => (value === null || value === undefined ? '—' : Number(value).toLocaleString('en-US'));

const platformLabels = { instagram: 'Instagram', tiktok: 'TikTok' };
const formatPlatform = (value) => platformLabels[value] ?? '—';

// Status distribution chart — how many matching records landed on each
// Views H+7 status label (PARAH..SIP). Mirrors the Cycles Score Distribution
// chart, just with a single series since Performance only has one metric.

const statusDistributionCanvas = ref(null);
let statusDistributionChart = null;

const getCssVar = (name) => getComputedStyle(document.documentElement).getPropertyValue(name).trim();

// Each bar is a status tier (PARAH..SIP), so it wears the app's real status
// color for that tier rather than one flat accent hue — matches the Dashboard's
// Health Distribution chart convention (statusColorFor).
const statusColorFor = (tier) =>
    getCssVar(
        {
            SIP: '--status-sip-ink',
            BAGUS: '--status-bagus-ink',
            CUKUP: '--status-cukup-ink',
            KURANG: '--status-kurang-ink',
            PARAH: '--status-parah-ink',
        }[String(tier).toUpperCase()] ?? '--accent',
    ) || '#0f766e';

const renderStatusDistributionChart = () => {
    if (!statusDistributionCanvas.value) return;

    statusDistributionChart?.destroy();

    const inkFaint = getCssVar('--ink-faint') || '#8b979b';
    const border = getCssVar('--border') || '#d8dedc';

    const tiers = props.statusDistribution.tiers ?? [];
    const counts = props.statusDistribution.counts ?? {};

    statusDistributionChart = new Chart(statusDistributionCanvas.value, {
        type: 'bar',
        data: {
            labels: tiers.map((tier) => String(tier)),
            datasets: [
                {
                    label: 'Views H+7 Status',
                    data: tiers.map((tier) => counts[tier] ?? 0),
                    backgroundColor: tiers.map((tier) => statusColorFor(tier)),
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
                        label: (context) => `${context.parsed.y} record${context.parsed.y === 1 ? '' : 's'}`,
                    },
                },
            },
            scales: {
                x: {
                    title: { display: true, text: 'Views H+7 Status', color: inkFaint },
                    ticks: { color: inkFaint },
                    grid: { display: false },
                },
                y: {
                    beginAtZero: true,
                    title: { display: true, text: 'Record Count', color: inkFaint },
                    ticks: { color: inkFaint, precision: 0 },
                    grid: { color: border },
                },
            },
        },
    });
};

watch(
    () => props.statusDistribution,
    async () => {
        await nextTick();
        renderStatusDistributionChart();
    },
);

onMounted(async () => {
    await nextTick();
    renderStatusDistributionChart();
});

onBeforeUnmount(() => {
    statusDistributionChart?.destroy();
});
</script>

<template>
        <div class="flex items-start justify-between gap-4">
            <div>
                <h1 class="font-display text-2xl font-bold tracking-tight" style="color: var(--ink)">Performance</h1>
                <p class="mt-1 text-sm" style="color: var(--ink-muted)">
                    Track individual social media posts and their performance.
                </p>
            </div>
            <button
                v-if="canEdit"
                type="button"
                class="shrink-0 rounded-md px-4 py-2 text-sm font-semibold transition-opacity hover:opacity-90"
                style="background-color: var(--accent); color: var(--accent-ink)"
                @click="openCreate"
            >
                + Add Performance
            </button>
        </div>

        <div v-if="summary.total > 0" class="mt-6 grid grid-cols-2 gap-3 sm:grid-cols-3">
            <StatCard label="Records Tracked" :value="String(summary.total)" />
            <StatCard
                label="Avg Views H+7"
                :value="summary.avg_views !== null ? String(summary.avg_views) : '—'"
                :hint="`across ${summary.total} record${summary.total === 1 ? '' : 's'}`"
            />
            <button
                type="button"
                class="rounded-lg border p-4 text-left transition-colors hover:opacity-80"
                style="border-color: var(--border); background-color: var(--surface)"
                title="Show top performing records"
                @click="filterByViewsStatus(topTierLabels)"
            >
                <p class="text-xs font-medium uppercase tracking-wide" style="color: var(--ink-faint)">Top Performing</p>
                <p class="mt-1.5 font-display text-2xl font-bold tabular-nums" style="color: var(--ink)">{{ summary.top_performing_count }}</p>
                <p class="mt-0.5 text-xs" style="color: var(--ink-muted)">{{ topTierLabels.join(' or ') || '—' }}</p>
            </button>
        </div>

        <!-- Needs Attention draws the eye as a status-colored banner rather than another
             neutral stat card carrying the same visual weight as the rest (matches Dashboard/Cycles).
             Clickable when there's something to show — filters the table below to those records. -->
        <button
            v-if="summary.total > 0 && summary.at_risk_count > 0"
            type="button"
            class="mt-3 flex w-full items-center gap-3 rounded-lg border p-4 text-left transition-colors hover:opacity-90"
            style="border-color: var(--status-parah-ink); background-color: var(--status-parah-bg)"
            title="Show records that need attention"
            @click="filterByViewsStatus(bottomTierLabels)"
        >
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-6 w-6 shrink-0" style="color: var(--status-parah-ink)">
                <path d="M12 9v4m0 4h.01M10.29 3.86 1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0Z" />
            </svg>
            <div>
                <p class="font-display text-lg font-bold" style="color: var(--status-parah-ink)">
                    {{ summary.at_risk_count }} record{{ summary.at_risk_count === 1 ? '' : 's' }} need{{ summary.at_risk_count === 1 ? 's' : '' }} attention
                </p>
                <p class="text-sm" style="color: var(--status-parah-ink)">Views H+7 status is KURANG or PARAH — click to filter the table below.</p>
            </div>
        </button>
        <div
            v-else-if="summary.total > 0"
            class="mt-3 flex items-center gap-3 rounded-lg border p-4"
            style="border-color: var(--status-sip-ink); background-color: var(--status-sip-bg)"
        >
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-6 w-6 shrink-0" style="color: var(--status-sip-ink)">
                <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14M22 4 12 14.01l-3-3" />
            </svg>
            <p class="text-sm font-semibold" style="color: var(--status-sip-ink)">All records are performing well — nothing needs attention right now.</p>
        </div>

        <div v-if="summary.total > 0" class="mt-6 rounded-lg border p-4" style="border-color: var(--border); background-color: var(--surface)">
            <h3 class="text-sm font-semibold" style="color: var(--ink)">
                Status Distribution
            </h3>
            <p class="mt-0.5 text-xs" style="color: var(--ink-muted)">
                How many matching records landed on each Views H+7 status label.
            </p>
            <div class="mt-3" style="height: 260px">
                <canvas ref="statusDistributionCanvas"></canvas>
            </div>
        </div>

        <div class="mt-8 flex flex-wrap items-center gap-3">
            <div class="relative max-w-xs flex-1 sm:min-w-[16rem]">
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
                    placeholder="Search by client…"
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

            <div class="ml-auto flex items-center gap-3">
                <button
                    type="button"
                    class="inline-flex items-center gap-1.5 rounded-md border px-3 py-2 text-sm font-medium transition-colors hover:opacity-70"
                    style="border-color: var(--accent); color: var(--accent)"
                    @click="openFilterSummaryModal"
                >
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-4 w-4">
                        <path d="M12 3v3m0 12v3m9-9h-3M6 12H3m15.5-6.5-2.1 2.1M8.6 15.4l-2.1 2.1m0-11 2.1 2.1m9 9-2.1-2.1" />
                        <circle cx="12" cy="12" r="3.5" />
                    </svg>
                    Summarize with AI
                </button>

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
                        Based on {{ filterSummaryBanner.performance_count }} record{{ filterSummaryBanner.performance_count === 1 ? '' : 's' }}
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
            id="performance-table"
            class="mt-4 overflow-hidden rounded-lg border scroll-mt-4"
            style="border-color: var(--border); background-color: var(--surface)"
        >
            <div class="overflow-x-auto">
                <table class="w-full min-w-[900px]">
                    <thead>
                        <tr style="border-bottom: 1px solid var(--border)">
                            <th
                                class="cursor-pointer select-none px-3 py-3 text-left text-xs font-semibold uppercase tracking-wide transition-colors hover:opacity-70"
                                style="color: var(--ink-faint)"
                                @click="sortBy('account')"
                            >
                                Brand
                                <span v-if="sort === 'account'">{{ direction === 'asc' ? '▲' : '▼' }}</span>
                            </th>
                            <th class="px-3 py-3 text-left text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Platform</th>
                            <th class="px-3 py-3 text-left text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Account Category</th>
                            <th
                                class="cursor-pointer select-none px-3 py-3 text-left text-xs font-semibold uppercase tracking-wide transition-colors hover:opacity-70"
                                style="color: var(--ink-faint)"
                                @click="sortBy('post_date')"
                            >
                                Post Date
                                <span v-if="sort === 'post_date'">{{ direction === 'asc' ? '▲' : '▼' }}</span>
                            </th>
                            <th class="px-3 py-3 text-left text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Ads</th>
                            <th class="px-3 py-3 text-left text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">PM Name</th>
                            <th class="px-3 py-3 text-left text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Conceptor Name</th>
                            <th
                                class="cursor-pointer select-none px-3 py-3 text-left text-xs font-semibold uppercase tracking-wide transition-colors hover:opacity-70"
                                style="color: var(--ink-faint)"
                                @click="sortBy('views_h7')"
                            >
                                Views H+7
                                <span v-if="sort === 'views_h7'">{{ direction === 'asc' ? '▲' : '▼' }}</span>
                            </th>
                            <th
                                class="cursor-pointer select-none px-3 py-3 text-left text-xs font-semibold uppercase tracking-wide transition-colors hover:opacity-70"
                                style="color: var(--ink-faint)"
                                @click="sortBy('views_status')"
                            >
                                Status
                                <span v-if="sort === 'views_status'">{{ direction === 'asc' ? '▲' : '▼' }}</span>
                            </th>
                            <th class="px-3 py-3 text-right text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr
                            v-for="performance in performances.data"
                            :key="performance.id"
                            class="cursor-pointer transition-colors hover:opacity-80"
                            style="border-bottom: 1px solid var(--border)"
                            @click="openDetail(performance)"
                        >
                            <td class="px-3 py-3.5 text-sm font-medium" style="color: var(--ink)">
                                {{ performance.account?.name ?? '—' }}
                            </td>
                            <td class="whitespace-nowrap px-3 py-3.5 text-sm" style="color: var(--ink-muted)">
                                {{ formatPlatform(performance.platform) }}
                            </td>
                            <td class="whitespace-nowrap px-3 py-3.5 text-sm">
                                <StatusBadge :status="performance.follower_category" />
                            </td>
                            <td class="whitespace-nowrap px-3 py-3.5 text-sm" style="color: var(--ink-muted)">
                                {{ formatDate(performance.post_date) }}
                            </td>
                            <td class="px-3 py-3.5 text-sm" style="color: var(--ink-muted)">
                                {{ performance.ads === null ? '-' : performance.ads ? 'Yes' : 'No' }}
                            </td>
                            <td class="px-3 py-3.5 text-sm" style="color: var(--ink-muted)">
                                {{ performance.project_manager?.name ?? '—' }}
                            </td>
                            <td class="px-3 py-3.5 text-sm" style="color: var(--ink-muted)">
                                {{ performance.conceptor?.name ?? '—' }}
                            </td>
                            <td class="px-3 py-3.5 text-sm tabular-nums" style="color: var(--ink-muted)">
                                {{ formatNumber(performance.total_views_h7) }}
                            </td>
                            <td class="whitespace-nowrap px-3 py-3.5 text-sm">
                                <StatusBadge :status="performance.views_status" />
                            </td>
                            <td class="whitespace-nowrap px-3 py-3.5 text-right text-sm" @click.stop>
                                <ActionsMenu
                                    v-if="canEdit"
                                    :items="[
                                        { label: 'Edit', onClick: () => startEdit(performance) },
                                        { label: 'Delete', danger: true, onClick: () => confirmDestroy(performance) },
                                    ]"
                                />
                            </td>
                        </tr>
                        <tr v-if="performances.data.length === 0">
                            <td colspan="10" class="px-4 py-12 text-center text-sm" style="color: var(--ink-faint)">
                                No performance records yet. Add one to get started.
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <div
                v-if="performances.last_page > 1"
                class="flex items-center justify-between border-t px-4 py-3"
                style="border-color: var(--border)"
            >
                <p class="text-sm" style="color: var(--ink-muted)">
                    Showing <span class="font-medium tabular-nums" style="color: var(--ink)">{{ performances.from }}–{{ performances.to }}</span>
                    of <span class="font-medium tabular-nums" style="color: var(--ink)">{{ performances.total }}</span>
                </p>
                <div class="flex items-center gap-1">
                    <button
                        v-for="link in performances.links"
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

        <PerformanceDetailModal
            v-if="viewingPerformance"
            :performance="viewingPerformance"
            :views-buckets="viewsBuckets"
            :follower-buckets="followerBuckets"
            :default-ai-provider="defaultAiProvider"
            @close="closeDetail"
            @edit="editFromDetail"
        />

        <PerformanceFormModal
            v-if="showCreateModal"
            :performance="null"
            :accounts="accounts"
            :employees="employees"
            :account-department-employees="accountDepartmentEmployees"
            :note-options="noteOptions"
            @close="closeCreate"
            @saved="closeCreate"
        />

        <PerformanceFormModal
            v-if="editingPerformance"
            :performance="editingPerformance"
            :accounts="accounts"
            :employees="employees"
            :account-department-employees="accountDepartmentEmployees"
            :note-options="noteOptions"
            @close="cancelEdit"
            @saved="cancelEdit"
        />

        <ConfirmDialog
            :open="!!deletingPerformance"
            title="Delete this performance record?"
            message="This will permanently remove this performance record. This cannot be undone."
            :processing="deleting"
            @confirm="destroy"
            @cancel="cancelDestroy"
        />

        <FilterSummaryModal
            v-if="showFilterSummaryModal"
            :filter-query="filterQuery()"
            :filter-label="filterLabelParts"
            :default-ai-provider="defaultAiProvider"
            endpoint="/performances-summarize"
            count-key="performance_count"
            count-noun="record"
            @close="closeFilterSummaryModal"
            @generated="onSummaryGenerated"
        />

        <!-- Filter modal -->
        <div
            v-if="showFilterModal"
            class="fixed inset-0 z-10 flex items-center justify-center bg-black/50 px-4 backdrop-blur-sm"
        >
            <div
                class="max-h-[85vh] w-full max-w-md overflow-y-auto rounded-lg border p-6 shadow-2xl"
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
                        <label class="block text-sm font-medium" style="color: var(--ink-muted)">Post Date</label>
                        <div class="mt-1 grid grid-cols-2 gap-3">
                            <input
                                v-model="draftPostDateFromFilter"
                                type="date"
                                class="rounded-md border px-3 py-2 text-sm transition-colors focus:outline-none"
                                style="border-color: var(--border); background-color: var(--surface); color: var(--ink)"
                            />
                            <input
                                v-model="draftPostDateToFilter"
                                type="date"
                                class="rounded-md border px-3 py-2 text-sm transition-colors focus:outline-none"
                                style="border-color: var(--border); background-color: var(--surface); color: var(--ink)"
                            />
                        </div>
                    </div>

                    <div>
                        <label class="block text-sm font-medium" style="color: var(--ink-muted)">Brand (Account)</label>
                        <SearchableSelect v-model="draftAccountFilter" :options="accounts" placeholder="All brands" class="mt-1" />
                    </div>

                    <div>
                        <label class="block text-sm font-medium" style="color: var(--ink-muted)">Platform</label>
                        <select v-model="draftPlatformFilter" :class="inputStyle" style="border-color: var(--border); background-color: var(--surface); color: var(--ink)">
                            <option value="">All platforms</option>
                            <option value="instagram">Instagram</option>
                            <option value="tiktok">TikTok</option>
                        </select>
                    </div>

                    <div>
                        <label class="block text-sm font-medium" style="color: var(--ink-muted)">Project Manager</label>
                        <SearchableSelect v-model="draftPmFilter" :options="accountDepartmentEmployees" placeholder="All project managers" class="mt-1" />
                    </div>

                    <div>
                        <label class="block text-sm font-medium" style="color: var(--ink-muted)">Conceptor</label>
                        <SearchableSelect v-model="draftConceptorFilter" :options="employees" placeholder="All conceptors" class="mt-1" />
                    </div>

                    <div>
                        <label class="block text-sm font-medium" style="color: var(--ink-muted)">Performa (Status)</label>
                        <MultiSelectDropdown
                            v-model="draftViewsStatusFilter"
                            :options="viewsStatusOptions"
                            placeholder="All statuses"
                            class="mt-1"
                        />
                    </div>

                    <div>
                        <label class="block text-sm font-medium" style="color: var(--ink-muted)">Ads</label>
                        <select v-model="draftAdsFilter" :class="inputStyle" style="border-color: var(--border); background-color: var(--surface); color: var(--ink)">
                            <option value="">All</option>
                            <option value="1">Ads</option>
                            <option value="0">Tidak Ads</option>
                            <option value="null">-</option>
                        </select>
                    </div>

                    <div>
                        <label class="block text-sm font-medium" style="color: var(--ink-muted)">Views H+7</label>
                        <select v-model="draftViewsH7Filter" :class="inputStyle" style="border-color: var(--border); background-color: var(--surface); color: var(--ink)">
                            <option value="">All</option>
                            <option value="not_null">Not empty</option>
                            <option value="null">Empty</option>
                        </select>
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
