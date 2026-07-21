<script setup>
import { computed, ref } from 'vue';
import { router } from '@inertiajs/vue3';
import AppLayout from '../../Layouts/AppLayout.vue';
import PerformanceFormModal from '../../Components/PerformanceFormModal.vue';
import PerformanceDetailModal from '../../Components/PerformanceDetailModal.vue';
import StatusBadge from '../../Components/StatusBadge.vue';
import SearchableSelect from '../../Components/SearchableSelect.vue';

const props = defineProps({
    performances: {
        type: Object,
        required: true,
    },
    clients: {
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
});

// --- Filters ---

const search = ref(props.filters.search ?? '');
const clientFilter = ref(props.filters.client_id ?? '');
const pmFilter = ref(props.filters.project_manager_id ?? '');
const conceptorFilter = ref(props.filters.conceptor_id ?? '');
const editorFilter = ref(props.filters.editor_id ?? '');
const viewsStatusFilter = ref(props.filters.views_status ?? '');
const adsFilter = ref(props.filters.ads === null || props.filters.ads === undefined ? '' : props.filters.ads ? '1' : '0');
const postDateFromFilter = ref(props.filters.post_date_from ?? '');
const postDateToFilter = ref(props.filters.post_date_to ?? '');
let searchTimeout = null;

const filterQuery = () => ({
    search: search.value || undefined,
    client_id: clientFilter.value || undefined,
    project_manager_id: pmFilter.value || undefined,
    conceptor_id: conceptorFilter.value || undefined,
    editor_id: editorFilter.value || undefined,
    views_status: viewsStatusFilter.value || undefined,
    ads: adsFilter.value || undefined,
    post_date_from: postDateFromFilter.value || undefined,
    post_date_to: postDateToFilter.value || undefined,
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
    const { search: _search, ...rest } = filterQuery();
    return Object.values(rest).filter((v) => v !== undefined).length;
});
const hasActiveFilters = computed(() => !!search.value || activeFilterCount.value > 0);

const clearAllFilters = () => {
    search.value = '';
    clientFilter.value = '';
    pmFilter.value = '';
    conceptorFilter.value = '';
    editorFilter.value = '';
    viewsStatusFilter.value = '';
    adsFilter.value = '';
    postDateFromFilter.value = '';
    postDateToFilter.value = '';
    applyFilters();
};

// --- Filter modal (draft state, only applied on "Apply") ---

const showFilterModal = ref(false);
const draftClientFilter = ref('');
const draftPmFilter = ref('');
const draftConceptorFilter = ref('');
const draftEditorFilter = ref('');
const draftViewsStatusFilter = ref('');
const draftAdsFilter = ref('');
const draftPostDateFromFilter = ref('');
const draftPostDateToFilter = ref('');

const openFilterModal = () => {
    draftClientFilter.value = clientFilter.value;
    draftPmFilter.value = pmFilter.value;
    draftConceptorFilter.value = conceptorFilter.value;
    draftEditorFilter.value = editorFilter.value;
    draftViewsStatusFilter.value = viewsStatusFilter.value;
    draftAdsFilter.value = adsFilter.value;
    draftPostDateFromFilter.value = postDateFromFilter.value;
    draftPostDateToFilter.value = postDateToFilter.value;
    showFilterModal.value = true;
};

const closeFilterModal = () => {
    showFilterModal.value = false;
};

const applyFilterModal = () => {
    clientFilter.value = draftClientFilter.value;
    pmFilter.value = draftPmFilter.value;
    conceptorFilter.value = draftConceptorFilter.value;
    editorFilter.value = draftEditorFilter.value;
    viewsStatusFilter.value = draftViewsStatusFilter.value;
    adsFilter.value = draftAdsFilter.value;
    postDateFromFilter.value = draftPostDateFromFilter.value;
    postDateToFilter.value = draftPostDateToFilter.value;
    showFilterModal.value = false;
    applyFilters();
};

const clearFilterModal = () => {
    draftClientFilter.value = '';
    draftPmFilter.value = '';
    draftConceptorFilter.value = '';
    draftEditorFilter.value = '';
    draftViewsStatusFilter.value = '';
    draftAdsFilter.value = '';
    draftPostDateFromFilter.value = '';
    draftPostDateToFilter.value = '';
};

const inputStyle =
    'mt-1 w-full rounded-md border px-3 py-2 text-sm transition-colors focus:outline-none';

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

const cancelEdit = () => {
    editingPerformance.value = null;
};

const destroy = (performance) => {
    if (!confirm('Delete this performance record?')) {
        return;
    }

    router.delete(`/performances/${performance.id}`, { preserveScroll: true });
};

const formatDate = (value) => {
    if (!value) return '—';
    return new Date(value).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
};
</script>

<template>
    <AppLayout>
        <div class="flex items-start justify-between gap-4">
            <div>
                <h1 class="font-display text-2xl font-bold tracking-tight" style="color: var(--ink)">Performance</h1>
                <p class="mt-1 text-sm" style="color: var(--ink-muted)">
                    Track individual social media posts and their performance.
                </p>
            </div>
            <button
                type="button"
                class="shrink-0 rounded-md px-4 py-2 text-sm font-semibold transition-opacity hover:opacity-90"
                style="background-color: var(--accent); color: var(--accent-ink)"
                @click="openCreate"
            >
                + Add Performance
            </button>
        </div>

        <div class="mt-6 flex flex-wrap items-center gap-3">
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
        </div>

        <div
            class="mt-4 overflow-hidden rounded-lg border"
            style="border-color: var(--border); background-color: var(--surface)"
        >
            <div class="overflow-x-auto">
                <table class="w-full min-w-[900px]">
                    <thead>
                        <tr style="border-bottom: 1px solid var(--border)">
                            <th class="px-3 py-3 text-left text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Client</th>
                            <th class="px-3 py-3 text-left text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Account Category</th>
                            <th class="px-3 py-3 text-left text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Post Date</th>
                            <th class="px-3 py-3 text-left text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Ads</th>
                            <th class="px-3 py-3 text-left text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">PM Name</th>
                            <th class="px-3 py-3 text-left text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Conceptor Name</th>
                            <th class="px-3 py-3 text-left text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Editor Name</th>
                            <th class="px-3 py-3 text-left text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Views H+7</th>
                            <th class="px-3 py-3 text-left text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Status</th>
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
                                {{ performance.client?.name ?? '—' }}
                            </td>
                            <td class="whitespace-nowrap px-3 py-3.5 text-sm">
                                <StatusBadge :status="performance.follower_category" />
                            </td>
                            <td class="whitespace-nowrap px-3 py-3.5 text-sm" style="color: var(--ink-muted)">
                                {{ formatDate(performance.post_date) }}
                            </td>
                            <td class="px-3 py-3.5 text-sm" style="color: var(--ink-muted)">
                                {{ performance.ads ? 'Yes' : 'No' }}
                            </td>
                            <td class="px-3 py-3.5 text-sm" style="color: var(--ink-muted)">
                                {{ performance.project_manager?.name ?? '—' }}
                            </td>
                            <td class="px-3 py-3.5 text-sm" style="color: var(--ink-muted)">
                                {{ performance.conceptor?.name ?? '—' }}
                            </td>
                            <td class="px-3 py-3.5 text-sm" style="color: var(--ink-muted)">
                                {{ performance.editor?.name ?? '—' }}
                            </td>
                            <td class="px-3 py-3.5 text-sm tabular-nums" style="color: var(--ink-muted)">
                                {{ performance.total_views_h7 ?? '—' }}
                            </td>
                            <td class="whitespace-nowrap px-3 py-3.5 text-sm">
                                <StatusBadge :status="performance.views_status" />
                            </td>
                            <td class="whitespace-nowrap px-3 py-3.5 text-right text-sm" @click.stop>
                                <button
                                    class="mr-3 font-medium transition-colors hover:opacity-70"
                                    style="color: var(--ink-muted)"
                                    @click="startEdit(performance)"
                                >
                                    Edit
                                </button>
                                <button
                                    class="font-medium transition-colors hover:opacity-70"
                                    style="color: var(--status-parah-ink)"
                                    @click="destroy(performance)"
                                >
                                    Delete
                                </button>
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
            @close="closeDetail"
        />

        <PerformanceFormModal
            v-if="showCreateModal"
            :performance="null"
            :clients="clients"
            :employees="employees"
            :account-department-employees="accountDepartmentEmployees"
            @close="closeCreate"
            @saved="closeCreate"
        />

        <PerformanceFormModal
            v-if="editingPerformance"
            :performance="editingPerformance"
            :clients="clients"
            :employees="employees"
            :account-department-employees="accountDepartmentEmployees"
            @close="cancelEdit"
            @saved="cancelEdit"
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
                        <label class="block text-sm font-medium" style="color: var(--ink-muted)">Brand (Client)</label>
                        <SearchableSelect v-model="draftClientFilter" :options="clients" placeholder="All brands" class="mt-1" />
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
                        <label class="block text-sm font-medium" style="color: var(--ink-muted)">Editor</label>
                        <SearchableSelect v-model="draftEditorFilter" :options="employees" placeholder="All editors" class="mt-1" />
                    </div>

                    <div>
                        <label class="block text-sm font-medium" style="color: var(--ink-muted)">Performa (Status)</label>
                        <select v-model="draftViewsStatusFilter" :class="inputStyle" style="border-color: var(--border); background-color: var(--surface); color: var(--ink)">
                            <option value="">All statuses</option>
                            <option v-for="label in viewsStatusOptions" :key="label" :value="label">{{ label }}</option>
                        </select>
                    </div>

                    <div>
                        <label class="block text-sm font-medium" style="color: var(--ink-muted)">Ads</label>
                        <select v-model="draftAdsFilter" :class="inputStyle" style="border-color: var(--border); background-color: var(--surface); color: var(--ink)">
                            <option value="">All</option>
                            <option value="1">Ads</option>
                            <option value="0">Tidak Ads</option>
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
    </AppLayout>
</template>
