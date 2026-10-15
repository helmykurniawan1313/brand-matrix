<script setup>
import { computed, ref } from 'vue';
import { router } from '@inertiajs/vue3';
import AppLayout from '../../Layouts/AppLayout.vue';
import StatusBadge from '../../Components/StatusBadge.vue';
import SearchableSelect from '../../Components/SearchableSelect.vue';
import MultiSelectDropdown from '../../Components/MultiSelectDropdown.vue';
import ScoringInfoModal from '../../Components/ScoringInfoModal.vue';
import AccountPerformanceTrendModal from '../../Components/AccountPerformanceTrendModal.vue';

defineOptions({ layout: AppLayout });

const props = defineProps({
    rows: {
        type: Object,
        required: true,
    },
    summary: {
        type: Object,
        default: () => ({ total: 0 }),
    },
    filters: {
        type: Object,
        default: () => ({}),
    },
    accountDepartmentEmployees: {
        type: Array,
        default: () => [],
    },
    healthLabels: {
        type: Array,
        default: () => [],
    },
});

// --- Search / PM / Health filter — same convention as Cycles/Accounts/Index.vue.
const search = ref(props.filters.search ?? '');
const pmFilter = ref(props.filters.project_manager_id ? Number(props.filters.project_manager_id) : '');
const healthFilter = ref(Array.isArray(props.filters.health_label) ? props.filters.health_label : []);
let searchTimeout = null;

const applySearch = () => {
    router.get(
        '/account-performance',
        {
            search: search.value || undefined,
            project_manager_id: pmFilter.value || undefined,
            health_label: healthFilter.value.length ? healthFilter.value.join(',') : undefined,
        },
        { preserveScroll: true, preserveState: true, replace: true },
    );
};

const onSearchInput = () => {
    clearTimeout(searchTimeout);
    searchTimeout = setTimeout(applySearch, 300);
};

const clearSearch = () => {
    search.value = '';
    applySearch();
};

const onPmFilterChange = () => {
    applySearch();
};

const onHealthFilterChange = () => {
    applySearch();
};

const hasActiveFilters = computed(() => !!search.value || !!pmFilter.value || healthFilter.value.length > 0);
const clearAllFilters = () => {
    search.value = '';
    pmFilter.value = '';
    healthFilter.value = [];
    applySearch();
};

const pmOptions = props.accountDepartmentEmployees.map((employee) => ({ id: employee.id, name: employee.name }));

const goToPage = (url) => {
    if (!url) return;
    router.visit(url, { preserveScroll: true, preserveState: true });
};

const round = (v) => (v === null || v === undefined ? '—' : Math.round(v * 10) / 10);
const platformLabel = (p) => (p === 'tiktok' ? 'TikTok' : 'Instagram');

// --- Month-over-month trend drill-down ---
const viewingRow = ref(null);
const openTrend = (row) => (viewingRow.value = row);
const closeTrend = () => (viewingRow.value = null);

const showScoringInfo = ref(false);
</script>

<template>
    <div class="flex flex-wrap items-start justify-between gap-4">
        <div>
            <h1 class="font-display text-2xl font-bold tracking-tight" style="color: var(--ink)">Account Performance</h1>
            <p class="mt-1 text-sm" style="color: var(--ink-muted)">
                Each account's most recent cycle — same Growth/Visibility/Engagement/Health breakdown as Cycles, grouped
                down to one row per account and platform. Click a row for its month-over-month trend.
            </p>
        </div>
    </div>

    <!-- Toolbar: search + PM + Health filter -->
    <div class="mt-6 flex flex-wrap items-center gap-3">
        <div class="relative w-full max-w-xs sm:w-64">
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
                placeholder="Search accounts…"
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

        <SearchableSelect
            v-model="pmFilter"
            :options="pmOptions"
            placeholder="All PMs"
            clearable
            clear-label="All PMs"
            class="w-44"
            @change="onPmFilterChange"
        />

        <MultiSelectDropdown
            v-model="healthFilter"
            :options="healthLabels"
            placeholder="All health statuses"
            class="w-52"
            @update:model-value="onHealthFilterChange"
        />

        <button
            v-if="hasActiveFilters"
            type="button"
            class="text-sm font-medium transition-colors hover:opacity-70"
            style="color: var(--ink-muted)"
            @click="clearAllFilters"
        >
            Clear filters
        </button>
    </div>

    <div class="mt-4 overflow-hidden rounded-lg border" style="border-color: var(--border); background-color: var(--surface)">
        <div class="flex items-center justify-end border-b px-3 py-2" style="border-color: var(--border)">
            <button
                type="button"
                class="flex h-7 w-7 shrink-0 items-center justify-center rounded-md transition-colors hover:opacity-70"
                style="color: var(--ink-muted)"
                aria-label="How statuses are scored"
                title="How statuses are scored"
                @click="showScoringInfo = true"
            >
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-4 w-4">
                    <circle cx="12" cy="12" r="10" />
                    <path d="M12 16v-4m0-4h.01" />
                </svg>
            </button>
        </div>
        <div class="overflow-x-auto">
            <table class="min-w-full">
                <thead>
                    <tr style="border-bottom: 1px solid var(--border)">
                        <th class="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Account</th>
                        <th class="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Platform</th>
                        <th class="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Latest Cycle</th>
                        <th class="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Growth</th>
                        <th class="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Visibility</th>
                        <th class="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Engagement</th>
                        <th class="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Health Rate</th>
                        <th class="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Health</th>
                        <th class="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">PM</th>
                    </tr>
                </thead>
                <tbody>
                    <tr
                        v-for="row in rows.data"
                        :key="`${row.account_id}-${row.platform}`"
                        class="cursor-pointer transition-colors hover:bg-[var(--bg)]"
                        style="border-bottom: 1px solid var(--border)"
                        @click="openTrend(row)"
                    >
                        <td class="px-4 py-3.5 text-sm font-medium" style="color: var(--ink)">{{ row.account_name }}</td>
                        <td class="px-4 py-3.5 text-sm">
                            <span
                                class="rounded px-1.5 py-0.5 text-[10px] font-semibold uppercase tracking-wide"
                                style="background-color: var(--accent-soft); color: var(--accent)"
                            >
                                {{ platformLabel(row.platform) }}
                            </span>
                        </td>
                        <td class="px-4 py-3.5 text-sm" style="color: var(--ink-muted)">{{ row.latest_cycle_label ?? '—' }}</td>
                        <td
                            class="px-4 py-3.5 text-sm tabular-nums"
                            :style="row.growth_rate < 0 ? 'color: var(--status-parah-ink)' : 'color: var(--ink)'"
                        >
                            {{ round(row.growth_rate) }}%
                        </td>
                        <td class="px-4 py-3.5 text-sm tabular-nums" style="color: var(--ink-muted)">{{ round(row.visibility_rate) }}</td>
                        <td class="px-4 py-3.5 text-sm tabular-nums" style="color: var(--ink-muted)">{{ round(row.engagement_score) }}</td>
                        <td class="px-4 py-3.5 text-sm tabular-nums" style="color: var(--ink)">{{ round(row.health_rate) }}</td>
                        <td class="px-4 py-3.5 text-sm">
                            <StatusBadge :status="row.health_label" />
                        </td>
                        <td class="px-4 py-3.5 text-sm" style="color: var(--ink-muted)">{{ row.project_manager?.name ?? '—' }}</td>
                    </tr>
                    <tr v-if="rows.data.length === 0">
                        <td colspan="9" class="px-4 py-16 text-center text-sm" style="color: var(--ink-faint)">
                            <template v-if="hasActiveFilters">No accounts match these filters.</template>
                            <template v-else>No accounts yet.</template>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>

    <div
        v-if="rows.last_page > 1"
        class="mt-4 flex flex-wrap items-center justify-between gap-3"
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

    <AccountPerformanceTrendModal
        v-if="viewingRow"
        :account-id="viewingRow.account_id"
        :account-name="viewingRow.account_name"
        :platform="viewingRow.platform"
        @close="closeTrend"
    />

    <ScoringInfoModal
        v-if="showScoringInfo"
        :metrics="['growth', 'visibility', 'engagement', 'health']"
        @close="showScoringInfo = false"
    />
</template>
