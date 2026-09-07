<script setup>
import { computed, ref } from 'vue';
import { useForm, router, usePage } from '@inertiajs/vue3';
import AppLayout from '../../Layouts/AppLayout.vue';

import AccountGrowthModal from '../../Components/AccountGrowthModal.vue';
import InstagramDataModal from '../../Components/InstagramDataModal.vue';
import ActionsMenu from '../../Components/ActionsMenu.vue';
import ConfirmDialog from '../../Components/ConfirmDialog.vue';
import SearchableSelect from '../../Components/SearchableSelect.vue';
import MultiSelectDropdown from '../../Components/MultiSelectDropdown.vue';
import StatCard from '../../Components/StatCard.vue';
import AccountStatusCell from '../../Components/AccountStatusCell.vue';
import { useToast } from '../../composables/useToast';
import { useAuth } from '../../composables/useAuth';

defineOptions({ layout: AppLayout });

const toast = useToast();
const { canEdit } = useAuth();

const props = defineProps({
    accounts: {
        type: Object,
        required: true,
    },
    summary: {
        type: Object,
        default: () => ({ total: 0, instagram_connected: 0, at_risk: 0 }),
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
    growthLabels: {
        type: Array,
        default: () => [],
    },
    reachStatusLabels: {
        type: Array,
        default: () => [],
    },
    viewsStatusLabels: {
        type: Array,
        default: () => [],
    },
    engagementStatusLabels: {
        type: Array,
        default: () => [],
    },
    defaultAiProvider: {
        type: String,
        default: 'groq',
    },
});

const flash = usePage().props.flash;

const goToPage = (url) => {
    if (!url) return;
    router.visit(url, { preserveScroll: true, preserveState: true });
};

const search = ref(props.filters.search ?? '');
const pmFilter = ref(props.filters.project_manager_id ? Number(props.filters.project_manager_id) : '');
const sort = ref(props.filters.sort ?? 'name');
const direction = ref(props.filters.direction ?? 'asc');
const healthFilter = ref(props.filters.health_label ?? []);
const growthFilter = ref(props.filters.growth_label ?? []);
const reachFilter = ref(props.filters.reach_status ?? []);
const viewsFilter = ref(props.filters.views_status ?? []);
const engagementFilter = ref(props.filters.engagement_status ?? []);
let searchTimeout = null;

const applySearch = () => {
    router.get(
        '/accounts',
        {
            search: search.value || undefined,
            project_manager_id: pmFilter.value || undefined,
            sort: sort.value !== 'name' || direction.value !== 'asc' ? sort.value : undefined,
            direction: sort.value !== 'name' || direction.value !== 'asc' ? direction.value : undefined,
            health_label: healthFilter.value.length ? healthFilter.value.join(',') : undefined,
            reach_status: reachFilter.value.length ? reachFilter.value.join(',') : undefined,
            views_status: viewsFilter.value.length ? viewsFilter.value.join(',') : undefined,
            engagement_status: engagementFilter.value.length ? engagementFilter.value.join(',') : undefined,
            growth_label: growthFilter.value.length ? growthFilter.value.join(',') : undefined,
        },
        { preserveScroll: true, preserveState: true, replace: true },
    );
};

const excelDownloadUrl = computed(() => {
    const params = new URLSearchParams();
    if (search.value) params.set('search', search.value);
    if (pmFilter.value) params.set('project_manager_id', pmFilter.value);
    if (healthFilter.value.length) params.set('health_label', healthFilter.value.join(','));
    if (growthFilter.value.length) params.set('growth_label', growthFilter.value.join(','));
    if (reachFilter.value.length) params.set('reach_status', reachFilter.value.join(','));
    if (viewsFilter.value.length) params.set('views_status', viewsFilter.value.join(','));
    if (engagementFilter.value.length) params.set('engagement_status', engagementFilter.value.join(','));
    const query = params.toString();
    return `/accounts-excel${query ? `?${query}` : ''}`;
});

// --- View mode (table / cards) — a lightweight per-viewer preference, not
// worth round-tripping to the server, so it lives in localStorage only.
const viewMode = ref('table');
try {
    const stored = localStorage.getItem('accounts-view-mode');
    if (stored === 'table' || stored === 'cards') viewMode.value = stored;
} catch {
    // Private-mode/blocked storage — fall back to the default silently.
}
const setViewMode = (mode) => {
    viewMode.value = mode;
    try {
        localStorage.setItem('accounts-view-mode', mode);
    } catch {
        // Non-fatal — the toggle still works for this page view.
    }
};

// --- Filter modal (Health / Growth Rate / Reach / Views / Engagement) ---
// Draft state pattern (matches Cycles' Filter modal): edits stay local to the
// modal until "Apply" commits them to the live refs above and triggers a
// navigation — closing/canceling discards any in-progress edits.

const showFilterModal = ref(false);
const draftHealthFilter = ref([]);
const draftGrowthFilter = ref([]);
const draftReachFilter = ref([]);
const draftViewsFilter = ref([]);
const draftEngagementFilter = ref([]);

const activeFilterCount = computed(
    () =>
        healthFilter.value.length +
        growthFilter.value.length +
        reachFilter.value.length +
        viewsFilter.value.length +
        engagementFilter.value.length,
);
const hasActiveFilters = computed(() => !!search.value || !!pmFilter.value || activeFilterCount.value > 0);

const openFilterModal = () => {
    draftHealthFilter.value = [...healthFilter.value];
    draftGrowthFilter.value = [...growthFilter.value];
    draftReachFilter.value = [...reachFilter.value];
    draftViewsFilter.value = [...viewsFilter.value];
    draftEngagementFilter.value = [...engagementFilter.value];
    showFilterModal.value = true;
};

const closeFilterModal = () => {
    showFilterModal.value = false;
};

const applyFilterModal = () => {
    healthFilter.value = [...draftHealthFilter.value];
    growthFilter.value = [...draftGrowthFilter.value];
    reachFilter.value = [...draftReachFilter.value];
    viewsFilter.value = [...draftViewsFilter.value];
    engagementFilter.value = [...draftEngagementFilter.value];
    showFilterModal.value = false;
    applySearch();
};

const clearFilterModal = () => {
    draftHealthFilter.value = [];
    draftGrowthFilter.value = [];
    draftReachFilter.value = [];
    draftViewsFilter.value = [];
    draftEngagementFilter.value = [];
};

const clearAllFilters = () => {
    search.value = '';
    pmFilter.value = '';
    healthFilter.value = [];
    growthFilter.value = [];
    reachFilter.value = [];
    viewsFilter.value = [];
    engagementFilter.value = [];
    applySearch();
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

const sortOptions = [
    { value: 'name', label: 'Name' },
    { value: 'health', label: 'Health' },
    { value: 'pm', label: 'PM' },
    { value: 'cycles', label: 'Cycles' },
];

const sortBy = (column) => {
    if (sort.value === column) {
        direction.value = direction.value === 'asc' ? 'desc' : 'asc';
    } else {
        sort.value = column;
        direction.value = 'asc';
    }
    applySearch();
};

// Card view uses a plain <select> instead of clickable column headers (there's
// no table), so sort key/direction are set together from one dropdown value.
const cardSortValue = computed(() => `${sort.value}:${direction.value}`);
const onCardSortChange = (event) => {
    const [column, dir] = event.target.value.split(':');
    sort.value = column;
    direction.value = dir;
    applySearch();
};

const pmOptions = props.accountDepartmentEmployees.map((employee) => ({ id: employee.id, name: employee.name }));

const platformMeta = {
    instagram: { label: 'IG', color: '#e1306c' },
    tiktok: { label: 'TT', color: '#010101' },
};

// Growth Rate / Views / Reach / Engagement status labels are all user-editable
// text (Settings → Buckets → Label Tiers), so match case-insensitively against
// the default wording rather than hardcoding exact casing; anything
// unrecognized falls back to a neutral tone rather than breaking. Growth Rate
// uses "Good"/"Need attention"; Views/Reach/Engagement use "Bagus"/"Perlu
// Perhatian" — both wordings map to the same tones.
const growthLabelTones = {
    sip: { bg: 'var(--status-sip-bg)', ink: 'var(--status-sip-ink)' },
    good: { bg: 'var(--status-bagus-bg)', ink: 'var(--status-bagus-ink)' },
    bagus: { bg: 'var(--status-bagus-bg)', ink: 'var(--status-bagus-ink)' },
    cukup: { bg: 'var(--status-cukup-bg)', ink: 'var(--status-cukup-ink)' },
    'need attention': { bg: 'var(--status-parah-bg)', ink: 'var(--status-parah-ink)' },
    'perlu perhatian': { bg: 'var(--status-parah-bg)', ink: 'var(--status-parah-ink)' },
};

const growthLabelTone = (label) => {
    const tone = growthLabelTones[label?.toLowerCase()] ?? { bg: 'var(--border)', ink: 'var(--ink-muted)' };
    return `background-color: ${tone.bg}; color: ${tone.ink}`;
};

// Create/Edit modal

const showFormModal = ref(false);
const editingAccount = ref(null);

const accountForm = useForm({
    name: '',
    project_manager_id: '',
});

const openCreate = () => {
    editingAccount.value = null;
    accountForm.reset();
    accountForm.clearErrors();
    showFormModal.value = true;
};

const openEdit = (account) => {
    editingAccount.value = account;
    accountForm.name = account.name;
    accountForm.project_manager_id = account.project_manager_id ?? '';
    accountForm.clearErrors();
    showFormModal.value = true;
};

const closeFormModal = () => {
    showFormModal.value = false;
    editingAccount.value = null;
    accountForm.reset();
    accountForm.clearErrors();
};

const submitAccountForm = () => {
    if (editingAccount.value) {
        accountForm.put(`/accounts/${editingAccount.value.id}`, {
            preserveScroll: true,
            onSuccess: () => {
                toast.success('Account updated.');
                closeFormModal();
            },
            onError: () => toast.error('Failed to update account.'),
        });
    } else {
        accountForm.post('/accounts', {
            preserveScroll: true,
            onSuccess: () => {
                toast.success('Account added.');
                closeFormModal();
            },
            onError: () => toast.error('Failed to add account.'),
        });
    }
};

// Delete confirmation

const deletingAccount = ref(null);
const deleting = ref(false);

const confirmDestroy = (account) => {
    deletingAccount.value = account;
};

const cancelDestroy = () => {
    deletingAccount.value = null;
};

const destroy = () => {
    if (!deletingAccount.value) return;
    deleting.value = true;

    router.delete(`/accounts/${deletingAccount.value.id}`, {
        preserveScroll: true,
        onSuccess: () => {
            toast.success('Account deleted.');
            deletingAccount.value = null;
        },
        onError: () => toast.error('Failed to delete account.'),
        onFinish: () => {
            deleting.value = false;
        },
    });
};

const viewingAccount = ref(null);

const openGrowth = (account) => {
    viewingAccount.value = account;
};

const closeGrowth = () => {
    viewingAccount.value = null;
};

const instagramAccount = ref(null);

const openInstagram = (account) => {
    instagramAccount.value = account;
};

const closeInstagram = () => {
    instagramAccount.value = null;
};

const accountActions = (account) =>
    canEdit.value
        ? [
              { label: account.ig_business_id ? 'Instagram ✓' : 'Connect Instagram', onClick: () => openInstagram(account) },
              { label: 'Edit', onClick: () => openEdit(account) },
              { label: 'Delete', danger: true, onClick: () => confirmDestroy(account) },
          ]
        : [{ label: account.ig_business_id ? 'Instagram ✓' : 'Not connected', onClick: () => openInstagram(account) }];
</script>

<template>
    <div class="flex flex-wrap items-start justify-between gap-4">
        <div>
            <h1 class="font-display text-2xl font-bold tracking-tight" style="color: var(--ink)">Accounts</h1>
            <p class="mt-1 text-sm" style="color: var(--ink-muted)">
                Manage the brand accounts being tracked across cycles.
            </p>
        </div>

        <div class="flex shrink-0 items-center gap-2">
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
            <button
                v-if="canEdit"
                type="button"
                class="shrink-0 rounded-md px-4 py-2 text-sm font-semibold transition-opacity hover:opacity-90"
                style="background-color: var(--accent); color: var(--accent-ink)"
                @click="openCreate"
            >
                + Add Account
            </button>
        </div>
    </div>

    <div
        v-if="flash?.ig_success"
        class="mt-4 rounded-md border px-4 py-3 text-sm"
        style="border-color: var(--accent); color: var(--ink)"
    >
        {{ flash.ig_success }}
    </div>
    <div
        v-if="flash?.ig_error"
        class="mt-4 rounded-md border px-4 py-3 text-sm"
        style="border-color: var(--status-parah-ink); color: var(--status-parah-ink)"
    >
        {{ flash.ig_error }}
    </div>

    <div class="mt-6 grid grid-cols-2 gap-3 sm:grid-cols-3">
        <StatCard label="Total Accounts" :value="String(summary.total)" />
        <StatCard label="Instagram Connected" :value="String(summary.instagram_connected)" :hint="`of ${summary.total} accounts`" />
        <StatCard label="Needs Attention" :value="String(summary.at_risk)" hint="latest cycle is KURANG or PARAH" />
    </div>

    <!-- Unified toolbar: filters on the left, view toggle on the right. -->
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

        <!-- Table / Cards view toggle -->
        <div class="ml-auto flex items-center gap-2">
            <select
                v-if="viewMode === 'cards'"
                :value="cardSortValue"
                class="rounded-md border px-2.5 py-1.5 text-sm transition-colors focus:outline-none"
                style="border-color: var(--border); background-color: var(--surface); color: var(--ink)"
                @change="onCardSortChange"
            >
                <optgroup v-for="option in sortOptions" :key="option.value" :label="option.label">
                    <option :value="`${option.value}:asc`">{{ option.label }} (A–Z / Low–High)</option>
                    <option :value="`${option.value}:desc`">{{ option.label }} (Z–A / High–Low)</option>
                </optgroup>
            </select>

            <div class="inline-flex rounded-md border p-0.5" style="border-color: var(--border)">
                <button
                    type="button"
                    class="flex h-8 w-8 items-center justify-center rounded transition-colors"
                    :style="
                        viewMode === 'table'
                            ? 'background-color: var(--accent); color: var(--accent-ink)'
                            : 'color: var(--ink-faint)'
                    "
                    aria-label="Table view"
                    title="Table view"
                    @click="setViewMode('table')"
                >
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-4 w-4">
                        <rect x="3" y="4" width="18" height="16" rx="1.5" />
                        <path d="M3 10h18M9 4v16" />
                    </svg>
                </button>
                <button
                    type="button"
                    class="flex h-8 w-8 items-center justify-center rounded transition-colors"
                    :style="
                        viewMode === 'cards'
                            ? 'background-color: var(--accent); color: var(--accent-ink)'
                            : 'color: var(--ink-faint)'
                    "
                    aria-label="Card view"
                    title="Card view"
                    @click="setViewMode('cards')"
                >
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-4 w-4">
                        <rect x="3" y="3" width="7" height="7" rx="1" />
                        <rect x="14" y="3" width="7" height="7" rx="1" />
                        <rect x="3" y="14" width="7" height="7" rx="1" />
                        <rect x="14" y="14" width="7" height="7" rx="1" />
                    </svg>
                </button>
            </div>
        </div>
    </div>

    <!-- ============ TABLE VIEW ============ -->
    <div
        v-if="viewMode === 'table'"
        class="mt-4 overflow-hidden rounded-lg border"
        style="border-color: var(--border); background-color: var(--surface)"
    >
        <div class="overflow-x-auto">
            <table class="min-w-full">
                <thead>
                    <tr style="border-bottom: 1px solid var(--border)">
                        <th
                            class="cursor-pointer select-none px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide transition-colors hover:opacity-70"
                            style="color: var(--ink-faint)"
                            @click="sortBy('name')"
                        >
                            Name
                            <span v-if="sort === 'name'">{{ direction === 'asc' ? '▲' : '▼' }}</span>
                        </th>
                        <th class="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">
                            Platforms
                        </th>
                        <th
                            class="cursor-pointer select-none px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide transition-colors hover:opacity-70"
                            style="color: var(--ink-faint)"
                            @click="sortBy('health')"
                        >
                            Health
                            <span v-if="sort === 'health'">{{ direction === 'asc' ? '▲' : '▼' }}</span>
                        </th>
                        <th
                            class="cursor-pointer select-none px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide transition-colors hover:opacity-70"
                            style="color: var(--ink-faint)"
                            @click="sortBy('growth')"
                        >
                            Growth Rate
                            <span v-if="sort === 'growth'">{{ direction === 'asc' ? '▲' : '▼' }}</span>
                        </th>
                        <th
                            class="cursor-pointer select-none px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide transition-colors hover:opacity-70"
                            style="color: var(--ink-faint)"
                            @click="sortBy('reach')"
                        >
                            Reach
                            <span v-if="sort === 'reach'">{{ direction === 'asc' ? '▲' : '▼' }}</span>
                        </th>
                        <th
                            class="cursor-pointer select-none px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide transition-colors hover:opacity-70"
                            style="color: var(--ink-faint)"
                            @click="sortBy('views')"
                        >
                            Views
                            <span v-if="sort === 'views'">{{ direction === 'asc' ? '▲' : '▼' }}</span>
                        </th>
                        <th
                            class="cursor-pointer select-none px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide transition-colors hover:opacity-70"
                            style="color: var(--ink-faint)"
                            @click="sortBy('engagement')"
                        >
                            Engagement
                            <span v-if="sort === 'engagement'">{{ direction === 'asc' ? '▲' : '▼' }}</span>
                        </th>
                        <th
                            class="cursor-pointer select-none px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide transition-colors hover:opacity-70"
                            style="color: var(--ink-faint)"
                            @click="sortBy('pm')"
                        >
                            PM
                            <span v-if="sort === 'pm'">{{ direction === 'asc' ? '▲' : '▼' }}</span>
                        </th>
                        <th
                            class="cursor-pointer select-none px-4 py-3 text-right text-xs font-semibold uppercase tracking-wide transition-colors hover:opacity-70"
                            style="color: var(--ink-faint)"
                            @click="sortBy('cycles')"
                        >
                            Cycles
                            <span v-if="sort === 'cycles'">{{ direction === 'asc' ? '▲' : '▼' }}</span>
                        </th>
                        <th class="px-4 py-3 text-right text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">
                            Actions
                        </th>
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
                        <td class="px-4 py-3.5 text-sm font-medium" style="color: var(--ink)">
                            {{ account.name }}
                        </td>
                        <td class="px-4 py-3.5 text-sm">
                            <div v-if="account.platforms?.length" class="flex items-center gap-1.5">
                                <span
                                    v-for="platform in account.platforms"
                                    :key="platform"
                                    class="inline-flex h-6 w-6 items-center justify-center rounded-full text-[10px] font-bold text-white"
                                    :style="`background-color: ${platformMeta[platform]?.color ?? 'var(--ink-faint)'}`"
                                    :title="platformMeta[platform]?.label ?? platform"
                                >
                                    {{ platformMeta[platform]?.label ?? '?' }}
                                </span>
                            </div>
                            <span v-else style="color: var(--ink-faint)">—</span>
                        </td>
                        <td class="px-4 py-3.5 text-sm">
                            <AccountStatusCell :account="account" field="health_label" />
                        </td>
                        <td class="px-4 py-3.5 text-sm">
                            <AccountStatusCell :account="account" field="growth_label" :tone="growthLabelTone" />
                        </td>
                        <td class="px-4 py-3.5 text-sm">
                            <AccountStatusCell :account="account" field="reach_status" :tone="growthLabelTone" />
                        </td>
                        <td class="px-4 py-3.5 text-sm">
                            <AccountStatusCell :account="account" field="views_status" :tone="growthLabelTone" />
                        </td>
                        <td class="px-4 py-3.5 text-sm">
                            <AccountStatusCell :account="account" field="engagement_status" :tone="growthLabelTone" />
                        </td>
                        <td class="px-4 py-3.5 text-sm" style="color: var(--ink-muted)">
                            {{ account.project_manager?.name ?? '—' }}
                        </td>
                        <td class="px-4 py-3.5 text-right text-sm tabular-nums" style="color: var(--ink-muted)">
                            {{ account.cycles_count }}
                        </td>
                        <td class="px-4 py-3.5 text-right text-sm" @click.stop>
                            <ActionsMenu :items="accountActions(account)" />
                        </td>
                    </tr>
                    <tr v-if="accounts.data.length === 0">
                        <td colspan="10" class="px-4 py-16 text-center text-sm" style="color: var(--ink-faint)">
                            <template v-if="hasActiveFilters">No accounts match these filters.</template>
                            <template v-else>No accounts yet. Add one to start tracking cycles.</template>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>

        <div
            v-if="accounts.last_page > 1"
            class="flex flex-wrap items-center justify-between gap-3 border-t px-4 py-3"
            style="border-color: var(--border)"
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
    </div>

    <!-- ============ CARD VIEW ============ -->
    <div v-else class="mt-4">
        <div v-if="accounts.data.length === 0" class="rounded-lg border py-16 text-center text-sm" style="border-color: var(--border); background-color: var(--surface); color: var(--ink-faint)">
            <template v-if="hasActiveFilters">No accounts match these filters.</template>
            <template v-else>No accounts yet. Add one to start tracking cycles.</template>
        </div>

        <div v-else class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
            <div
                v-for="account in accounts.data"
                :key="account.id"
                class="group flex cursor-pointer flex-col rounded-lg border p-4 shadow-sm transition-all hover:-translate-y-0.5 hover:shadow-md"
                style="border-color: var(--border); background-color: var(--surface)"
                @click="openGrowth(account)"
            >
                <div class="flex items-start justify-between gap-2">
                    <div class="min-w-0">
                        <h3 class="truncate font-display text-base font-bold" style="color: var(--ink)" :title="account.name">
                            {{ account.name }}
                        </h3>
                        <p class="mt-0.5 truncate text-xs" style="color: var(--ink-muted)">
                            {{ account.project_manager?.name ?? 'No PM assigned' }}
                        </p>
                    </div>
                    <div class="flex shrink-0 items-center gap-1.5" @click.stop>
                        <span
                            v-for="platform in account.platforms ?? []"
                            :key="platform"
                            class="inline-flex h-6 w-6 items-center justify-center rounded-full text-[10px] font-bold text-white"
                            :style="`background-color: ${platformMeta[platform]?.color ?? 'var(--ink-faint)'}`"
                            :title="platformMeta[platform]?.label ?? platform"
                        >
                            {{ platformMeta[platform]?.label ?? '?' }}
                        </span>
                        <ActionsMenu :items="accountActions(account)" />
                    </div>
                </div>

                <div class="mt-4 grid grid-cols-2 gap-2">
                    <div class="rounded-md border p-2.5" style="border-color: var(--border); background-color: var(--bg)">
                        <p class="text-[10px] font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Health</p>
                        <div class="mt-1">
                            <AccountStatusCell :account="account" field="health_label" size="sm" />
                        </div>
                    </div>
                    <div class="rounded-md border p-2.5" style="border-color: var(--border); background-color: var(--bg)">
                        <p class="text-[10px] font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Growth</p>
                        <div class="mt-1">
                            <AccountStatusCell :account="account" field="growth_label" :tone="growthLabelTone" size="sm" />
                        </div>
                    </div>
                    <div class="rounded-md border p-2.5" style="border-color: var(--border); background-color: var(--bg)">
                        <p class="text-[10px] font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Reach</p>
                        <div class="mt-1">
                            <AccountStatusCell :account="account" field="reach_status" :tone="growthLabelTone" size="sm" />
                        </div>
                    </div>
                    <div class="rounded-md border p-2.5" style="border-color: var(--border); background-color: var(--bg)">
                        <p class="text-[10px] font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Views</p>
                        <div class="mt-1">
                            <AccountStatusCell :account="account" field="views_status" :tone="growthLabelTone" size="sm" />
                        </div>
                    </div>
                    <div class="col-span-2 rounded-md border p-2.5" style="border-color: var(--border); background-color: var(--bg)">
                        <p class="text-[10px] font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Engagement</p>
                        <div class="mt-1">
                            <AccountStatusCell :account="account" field="engagement_status" :tone="growthLabelTone" size="sm" />
                        </div>
                    </div>
                </div>

                <div class="mt-3 flex items-center justify-between border-t pt-3 text-xs" style="border-color: var(--border)">
                    <span style="color: var(--ink-faint)">
                        {{ account.cycles_count }} cycle{{ account.cycles_count === 1 ? '' : 's' }} tracked
                    </span>
                    <span
                        class="font-medium transition-opacity group-hover:opacity-100"
                        style="color: var(--accent); opacity: 0.7"
                    >
                        View details →
                    </span>
                </div>
            </div>
        </div>

        <div v-if="accounts.last_page > 1" class="mt-4 flex flex-wrap items-center justify-between gap-3">
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
    </div>

    <div
        v-if="showFormModal"
        class="fixed inset-0 z-40 flex items-center justify-center p-4"
        style="background-color: rgba(0, 0, 0, 0.5)"
    >
        <div
            class="w-full max-w-md rounded-lg border p-6"
            style="border-color: var(--border); background-color: var(--surface)"
        >
            <div class="flex items-start justify-between">
                <h2 class="font-display text-lg font-bold" style="color: var(--ink)">
                    {{ editingAccount ? 'Edit Account' : 'Add Account' }}
                </h2>
                <button
                    type="button"
                    class="transition-colors hover:opacity-70"
                    style="color: var(--ink-faint)"
                    aria-label="Close"
                    @click="closeFormModal"
                >
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-5 w-5">
                        <path d="M18 6 6 18M6 6l12 12" />
                    </svg>
                </button>
            </div>

            <form @submit.prevent="submitAccountForm" class="mt-5 space-y-4">
                <div>
                    <label class="block text-sm font-medium" style="color: var(--ink-muted)">Account Name</label>
                    <input
                        v-model="accountForm.name"
                        type="text"
                        placeholder="Account name"
                        class="mt-1.5 w-full rounded-md border px-3 py-2 text-sm transition-colors focus:outline-none"
                        style="border-color: var(--border); background-color: var(--surface); color: var(--ink)"
                    />
                    <p v-if="accountForm.errors.name" class="mt-1 text-sm" style="color: var(--status-parah-ink)">
                        {{ accountForm.errors.name }}
                    </p>
                </div>

                <div>
                    <label class="block text-sm font-medium" style="color: var(--ink-muted)">Project Manager</label>
                    <div class="mt-1.5">
                        <SearchableSelect
                            v-model="accountForm.project_manager_id"
                            :options="pmOptions"
                            placeholder="Select PM…"
                            clearable
                            clear-label="No PM"
                        />
                    </div>
                    <p v-if="accountForm.errors.project_manager_id" class="mt-1 text-sm" style="color: var(--status-parah-ink)">
                        {{ accountForm.errors.project_manager_id }}
                    </p>
                </div>

                <div class="flex justify-end gap-3 pt-2">
                    <button
                        type="button"
                        class="rounded-md px-4 py-2 text-sm font-medium transition-colors hover:opacity-70"
                        style="color: var(--ink-muted)"
                        @click="closeFormModal"
                    >
                        Cancel
                    </button>
                    <button
                        type="submit"
                        :disabled="accountForm.processing"
                        class="rounded-md px-4 py-2 text-sm font-semibold transition-opacity hover:opacity-90 disabled:opacity-50"
                        style="background-color: var(--accent); color: var(--accent-ink)"
                    >
                        {{ editingAccount ? 'Save' : 'Add Account' }}
                    </button>
                </div>
            </form>
        </div>
    </div>

    <AccountGrowthModal
        v-if="viewingAccount"
        :account="viewingAccount"
        :default-ai-provider="defaultAiProvider"
        @close="closeGrowth"
    />

    <InstagramDataModal
        v-if="instagramAccount"
        :account="instagramAccount"
        @close="closeInstagram"
    />

    <ConfirmDialog
        :open="!!deletingAccount"
        title="Delete this account?"
        :message="deletingAccount ? `This will permanently remove “${deletingAccount.name}” and all ${deletingAccount.cycles_count} cycle${deletingAccount.cycles_count === 1 ? '' : 's'} recorded for it. This cannot be undone.` : ''"
        checkbox-label="I understand this will also delete all cycles for this account."
        :processing="deleting"
        @confirm="destroy"
        @cancel="cancelDestroy"
    />

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
                    <label class="block text-sm font-medium" style="color: var(--ink-muted)">Health Status</label>
                    <MultiSelectDropdown
                        v-model="draftHealthFilter"
                        :options="healthLabels"
                        placeholder="All health statuses"
                        class="mt-1"
                    />
                </div>

                <div>
                    <label class="block text-sm font-medium" style="color: var(--ink-muted)">Growth Rate</label>
                    <MultiSelectDropdown
                        v-model="draftGrowthFilter"
                        :options="growthLabels"
                        placeholder="All growth rates"
                        class="mt-1"
                    />
                </div>

                <div>
                    <label class="block text-sm font-medium" style="color: var(--ink-muted)">Reach Status</label>
                    <MultiSelectDropdown
                        v-model="draftReachFilter"
                        :options="reachStatusLabels"
                        placeholder="All reach statuses"
                        class="mt-1"
                    />
                </div>

                <div>
                    <label class="block text-sm font-medium" style="color: var(--ink-muted)">Views Status</label>
                    <MultiSelectDropdown
                        v-model="draftViewsFilter"
                        :options="viewsStatusLabels"
                        placeholder="All views statuses"
                        class="mt-1"
                    />
                </div>

                <div>
                    <label class="block text-sm font-medium" style="color: var(--ink-muted)">Engagement Status</label>
                    <MultiSelectDropdown
                        v-model="draftEngagementFilter"
                        :options="engagementStatusLabels"
                        placeholder="All engagement statuses"
                        class="mt-1"
                    />
                    <p class="mt-1.5 text-xs" style="color: var(--ink-faint)">
                        All filters use each account's latest cycle (Reach/Views/Engagement compare it to the one before it).
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
</template>
