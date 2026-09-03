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
import StatusBadge from '../../Components/StatusBadge.vue';
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
            growth_label: growthFilter.value.length ? growthFilter.value.join(',') : undefined,
        },
        { preserveScroll: true, preserveState: true, replace: true },
    );
};

// --- Filter modal (Health / Growth Rate) ---
// Draft state pattern (matches Cycles' Filter modal): edits stay local to the
// modal until "Apply" commits them to the live refs above and triggers a
// navigation — closing/canceling discards any in-progress edits.

const showFilterModal = ref(false);
const draftHealthFilter = ref([]);
const draftGrowthFilter = ref([]);

const activeFilterCount = computed(() => healthFilter.value.length + growthFilter.value.length);

const openFilterModal = () => {
    draftHealthFilter.value = [...healthFilter.value];
    draftGrowthFilter.value = [...growthFilter.value];
    showFilterModal.value = true;
};

const closeFilterModal = () => {
    showFilterModal.value = false;
};

const applyFilterModal = () => {
    healthFilter.value = [...draftHealthFilter.value];
    growthFilter.value = [...draftGrowthFilter.value];
    showFilterModal.value = false;
    applySearch();
};

const clearFilterModal = () => {
    draftHealthFilter.value = [];
    draftGrowthFilter.value = [];
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

const sortBy = (column) => {
    if (sort.value === column) {
        direction.value = direction.value === 'asc' ? 'desc' : 'asc';
    } else {
        sort.value = column;
        direction.value = 'asc';
    }
    applySearch();
};

const pmOptions = props.accountDepartmentEmployees.map((employee) => ({ id: employee.id, name: employee.name }));

const platformMeta = {
    instagram: { label: 'IG', color: '#e1306c' },
    tiktok: { label: 'TT', color: '#010101' },
};

// Growth Rate labels are user-editable text (Settings → Buckets → Accounts
// Table — Growth Rate), so match case-insensitively against the default
// wording rather than hardcoding exact casing; anything unrecognized falls
// back to a neutral tone rather than breaking.
const growthLabelTones = {
    sip: { bg: 'var(--status-sip-bg)', ink: 'var(--status-sip-ink)' },
    good: { bg: 'var(--status-bagus-bg)', ink: 'var(--status-bagus-ink)' },
    cukup: { bg: 'var(--status-cukup-bg)', ink: 'var(--status-cukup-ink)' },
    'need attention': { bg: 'var(--status-parah-bg)', ink: 'var(--status-parah-ink)' },
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
</script>

<template>
        <h1 class="font-display text-2xl font-bold tracking-tight" style="color: var(--ink)">Accounts</h1>
        <p class="mt-1 text-sm" style="color: var(--ink-muted)">
            Manage the brand accounts being tracked across cycles.
        </p>

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

        <div v-if="canEdit" class="mt-6">
            <button
                type="button"
                class="shrink-0 rounded-md px-4 py-2 text-sm font-semibold transition-opacity hover:opacity-90"
                style="background-color: var(--accent); color: var(--accent-ink)"
                @click="openCreate"
            >
                + Add Account
            </button>
        </div>

        <div class="mt-6 flex flex-wrap items-center gap-3">
            <span class="text-xs font-medium uppercase tracking-wide" style="color: var(--ink-faint)">Filter</span>
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
                class="w-48"
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
        </div>

        <div
            class="mt-3 overflow-hidden rounded-lg border"
            style="border-color: var(--border); background-color: var(--surface)"
        >
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
                        <th class="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">
                            Growth Rate
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
                        class="cursor-pointer transition-colors hover:opacity-80"
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
                                    class="inline-flex h-5 w-5 items-center justify-center rounded-full text-[9px] font-bold text-white"
                                    :style="`background-color: ${platformMeta[platform]?.color ?? 'var(--ink-faint)'}`"
                                    :title="platformMeta[platform]?.label ?? platform"
                                >
                                    {{ platformMeta[platform]?.label ?? '?' }}
                                </span>
                            </div>
                            <span v-else style="color: var(--ink-faint)">—</span>
                        </td>
                        <td class="px-4 py-3.5 text-sm">
                            <StatusBadge v-if="account.health_label" :status="account.health_label" />
                            <span v-else style="color: var(--ink-faint)">No data</span>
                        </td>
                        <td class="px-4 py-3.5 text-sm">
                            <span v-if="account.growth_label" class="inline-flex items-center gap-1.5">
                                <span
                                    class="rounded-full px-2.5 py-1 text-xs font-semibold"
                                    :style="growthLabelTone(account.growth_label)"
                                >
                                    {{ account.growth_label }}
                                </span>
                                <span class="tabular-nums" style="color: var(--ink-faint)">
                                    ({{ account.growth_rate > 0 ? '+' : '' }}{{ account.growth_rate }}%)
                                </span>
                            </span>
                            <span v-else style="color: var(--ink-faint)">No data</span>
                        </td>
                        <td class="px-4 py-3.5 text-sm" style="color: var(--ink-muted)">
                            {{ account.project_manager?.name ?? '—' }}
                        </td>
                        <td class="px-4 py-3.5 text-right text-sm tabular-nums" style="color: var(--ink-muted)">
                            {{ account.cycles_count }}
                        </td>
                        <td class="px-4 py-3.5 text-right text-sm" @click.stop>
                            <ActionsMenu
                                :items="
                                    canEdit
                                        ? [
                                              { label: account.ig_business_id ? 'Instagram ✓' : 'Connect Instagram', onClick: () => openInstagram(account) },
                                              { label: 'Edit', onClick: () => openEdit(account) },
                                              { label: 'Delete', danger: true, onClick: () => confirmDestroy(account) },
                                          ]
                                        : [{ label: account.ig_business_id ? 'Instagram ✓' : 'Not connected', onClick: () => openInstagram(account) }]
                                "
                            />
                        </td>
                    </tr>
                    <tr v-if="accounts.data.length === 0">
                        <td colspan="7" class="px-4 py-12 text-center text-sm" style="color: var(--ink-faint)">
                            <template v-if="search">No accounts match "{{ search }}".</template>
                            <template v-else>No accounts yet. Add one to start tracking cycles.</template>
                        </td>
                    </tr>
                </tbody>
            </table>

            <div
                v-if="accounts.last_page > 1"
                class="flex items-center justify-between border-t px-4 py-3"
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
                        <p class="mt-1.5 text-xs" style="color: var(--ink-faint)">
                            Both filters use each account's latest cycle.
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
