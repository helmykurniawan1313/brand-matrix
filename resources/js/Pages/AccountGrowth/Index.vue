<script setup>
import { computed, ref } from 'vue';
import { router } from '@inertiajs/vue3';
import AppLayout from '../../Layouts/AppLayout.vue';
import AccountGrowthModal from '../../Components/AccountGrowthModal.vue';
import StatusBadge from '../../Components/StatusBadge.vue';
import SearchableSelect from '../../Components/SearchableSelect.vue';
import MultiSelectDropdown from '../../Components/MultiSelectDropdown.vue';
import ScoringInfoModal from '../../Components/ScoringInfoModal.vue';

defineOptions({ layout: AppLayout });

const props = defineProps({
    accounts: {
        type: Object,
        required: true,
    },
    summary: {
        type: Object,
        default: () => ({ total: 0, improving: 0, declining: 0 }),
    },
    filters: {
        type: Object,
        default: () => ({}),
    },
    accountDepartmentEmployees: {
        type: Array,
        default: () => [],
    },
    defaultAiProvider: {
        type: String,
        default: 'groq',
    },
    growthLabels: {
        type: Array,
        default: () => [],
    },
    reachLabels: {
        type: Array,
        default: () => [],
    },
    viewsLabels: {
        type: Array,
        default: () => [],
    },
    engagementLabels: {
        type: Array,
        default: () => [],
    },
});

// --- Search / PM / status filters — same convention as Accounts/Index.vue.
const search = ref(props.filters.search ?? '');
const pmFilter = ref(props.filters.project_manager_id ? Number(props.filters.project_manager_id) : '');
const growthFilter = ref(Array.isArray(props.filters.growth_label) ? props.filters.growth_label : []);
const reachFilter = ref(Array.isArray(props.filters.reach_status) ? props.filters.reach_status : []);
const viewsFilter = ref(Array.isArray(props.filters.views_status) ? props.filters.views_status : []);
const engagementFilter = ref(Array.isArray(props.filters.engagement_status) ? props.filters.engagement_status : []);
let searchTimeout = null;

const applySearch = () => {
    router.get(
        '/account-growth',
        {
            search: search.value || undefined,
            project_manager_id: pmFilter.value || undefined,
            growth_label: growthFilter.value.length ? growthFilter.value.join(',') : undefined,
            reach_status: reachFilter.value.length ? reachFilter.value.join(',') : undefined,
            views_status: viewsFilter.value.length ? viewsFilter.value.join(',') : undefined,
            engagement_status: engagementFilter.value.length ? engagementFilter.value.join(',') : undefined,
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

const onStatusFilterChange = () => {
    applySearch();
};

const hasActiveFilters = computed(
    () =>
        !!search.value ||
        !!pmFilter.value ||
        growthFilter.value.length > 0 ||
        reachFilter.value.length > 0 ||
        viewsFilter.value.length > 0 ||
        engagementFilter.value.length > 0,
);
const clearAllFilters = () => {
    search.value = '';
    pmFilter.value = '';
    growthFilter.value = [];
    reachFilter.value = [];
    viewsFilter.value = [];
    engagementFilter.value = [];
    applySearch();
};

const pmOptions = props.accountDepartmentEmployees.map((employee) => ({ id: employee.id, name: employee.name }));

const goToPage = (url) => {
    if (!url) return;
    router.visit(url, { preserveScroll: true, preserveState: true });
};

// --- Growth modal drill-down (reused as-is from Accounts/Index.vue) ---
const viewingAccount = ref(null);
const openGrowth = (account) => (viewingAccount.value = account);
const closeGrowth = () => (viewingAccount.value = null);

const showScoringInfo = ref(false);
</script>

<template>
    <div class="flex flex-wrap items-start justify-between gap-4">
        <div>
            <h1 class="font-display text-2xl font-bold tracking-tight" style="color: var(--ink)">Account Growth</h1>
        </div>
    </div>

    <!-- Toolbar: search + PM + status filters -->
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
            v-model="growthFilter"
            :options="growthLabels"
            placeholder="All follower growth"
            class="w-48"
            @update:model-value="onStatusFilterChange"
        />

        <MultiSelectDropdown
            v-model="reachFilter"
            :options="reachLabels"
            placeholder="All reach statuses"
            class="w-44"
            @update:model-value="onStatusFilterChange"
        />

        <MultiSelectDropdown
            v-model="viewsFilter"
            :options="viewsLabels"
            placeholder="All views statuses"
            class="w-44"
            @update:model-value="onStatusFilterChange"
        />

        <MultiSelectDropdown
            v-model="engagementFilter"
            :options="engagementLabels"
            placeholder="All engagement statuses"
            class="w-52"
            @update:model-value="onStatusFilterChange"
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
                        <th rowspan="2" class="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide align-bottom" style="color: var(--ink-faint)">Account</th>
                        <th rowspan="2" class="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide align-bottom" style="color: var(--ink-faint)">Latest Cycle</th>
                        <th rowspan="2" class="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide align-bottom" style="color: var(--ink-faint)">Follower Growth</th>
                        <th colspan="3" class="px-4 py-2 text-center text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint); border-bottom: 1px solid var(--border)">
                            vs. previous cycle
                        </th>
                        <th rowspan="2" class="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide align-bottom" style="color: var(--ink-faint)">PM</th>
                    </tr>
                    <tr style="border-bottom: 1px solid var(--border)">
                        <th class="px-4 py-2 text-left text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Reach</th>
                        <th class="px-4 py-2 text-left text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Views</th>
                        <th class="px-4 py-2 text-left text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Engagement</th>
                    </tr>
                </thead>
                <tbody>
                    <tr
                        v-for="account in accounts.data"
                        :key="account.id"
                        class="cursor-pointer transition-colors hover:bg-[var(--bg)]"
                        style="border-bottom: 1px solid var(--border)"
                        @click="openGrowth(account)"
                    >
                        <td class="px-4 py-3.5 text-sm font-medium" style="color: var(--ink)">{{ account.name }}</td>
                        <td class="px-4 py-3.5 text-sm" style="color: var(--ink-muted)">{{ account.latest_cycle_label ?? '—' }}</td>
                        <td class="px-4 py-3.5 text-sm">
                            <StatusBadge v-if="account.growth_label" :status="account.growth_label" />
                            <span v-else style="color: var(--ink-faint)">No data</span>
                        </td>
                        <td class="px-4 py-3.5 text-sm">
                            <StatusBadge v-if="account.reach_status" :status="account.reach_status" />
                            <span v-else style="color: var(--ink-faint)">No prior cycle</span>
                        </td>
                        <td class="px-4 py-3.5 text-sm">
                            <StatusBadge v-if="account.views_status" :status="account.views_status" />
                            <span v-else style="color: var(--ink-faint)">No prior cycle</span>
                        </td>
                        <td class="px-4 py-3.5 text-sm">
                            <StatusBadge v-if="account.engagement_status" :status="account.engagement_status" />
                            <span v-else style="color: var(--ink-faint)">No prior cycle</span>
                        </td>
                        <td class="px-4 py-3.5 text-sm" style="color: var(--ink-muted)">{{ account.project_manager?.name ?? '—' }}</td>
                    </tr>
                    <tr v-if="accounts.data.length === 0">
                        <td colspan="7" class="px-4 py-16 text-center text-sm" style="color: var(--ink-faint)">
                            <template v-if="hasActiveFilters">No accounts match these filters.</template>
                            <template v-else>No accounts yet.</template>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>

    <div
        v-if="accounts.last_page > 1"
        class="mt-4 flex flex-wrap items-center justify-between gap-3"
    >
        <p class="text-sm" style="color: var(--ink-muted)">
            Showing <span class="font-medium tabular-nums" style="color: var(--ink)">{{ accounts.from }}–{{ accounts.to }}</span>
            of <span class="font-medium tabular-nums" style="color: var(--ink)">{{ accounts.total }}</span>
        </p>
        <div class="flex items-center gap-1">
            <button
                v-for="link in accounts.links"
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

    <AccountGrowthModal
        v-if="viewingAccount"
        :account="viewingAccount"
        :default-ai-provider="defaultAiProvider"
        @close="closeGrowth"
    />

    <ScoringInfoModal
        v-if="showScoringInfo"
        :metrics="['account_growth', 'reach_change', 'views_change', 'engagement_change']"
        @close="showScoringInfo = false"
    />
</template>
