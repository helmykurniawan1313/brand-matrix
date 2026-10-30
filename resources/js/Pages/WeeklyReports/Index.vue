<script setup>
import { ref } from 'vue';
import { useForm, router } from '@inertiajs/vue3';
import AppLayout from '../../Layouts/AppLayout.vue';

import SearchableSelect from '../../Components/SearchableSelect.vue';
import ActionsMenu from '../../Components/ActionsMenu.vue';
import ConfirmDialog from '../../Components/ConfirmDialog.vue';
import { useToast } from '../../composables/useToast';
import { useAuth } from '../../composables/useAuth';

defineOptions({ layout: AppLayout });

const toast = useToast();
const { canEdit } = useAuth();

const props = defineProps({
    reports: {
        type: Object,
        required: true,
    },
    accounts: {
        type: Array,
        required: true,
    },
    filters: {
        type: Object,
        default: () => ({}),
    },
});

const platformOptions = [
    { id: 'instagram', name: 'Instagram' },
    { id: 'tiktok', name: 'TikTok' },
];

const accountOptions = props.accounts.map((account) => ({ id: account.id, name: account.name }));

// Filters

const search = ref(props.filters.search ?? '');
const filterAccountId = ref(props.filters.account_id ?? '');
const filterPlatform = ref(props.filters.platform ?? '');

const applyFilters = () => {
    router.get(
        '/weekly-reports',
        {
            search: search.value || undefined,
            account_id: filterAccountId.value || undefined,
            platform: filterPlatform.value || undefined,
        },
        { preserveState: true, preserveScroll: true, replace: true },
    );
};

const clearFilters = () => {
    search.value = '';
    filterAccountId.value = '';
    filterPlatform.value = '';
    applyFilters();
};

const goToPage = (url) => {
    if (!url) return;
    router.get(url, {}, { preserveState: true, preserveScroll: true });
};

// Monday snapping — a week is always Monday through the following Sunday, so
// only the start date is editable; the end date and its label are derived.

const toLocalDateString = (date) => {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
};

const mondayOnOrBefore = (dateStr) => {
    const date = new Date(`${dateStr}T00:00:00`);
    const day = date.getDay(); // 0 = Sunday .. 6 = Saturday
    const diff = day === 0 ? 6 : day - 1;
    date.setDate(date.getDate() - diff);
    return toLocalDateString(date);
};

const sundayFor = (mondayStr) => {
    const date = new Date(`${mondayStr}T00:00:00`);
    date.setDate(date.getDate() + 6);
    return toLocalDateString(date);
};

const formatRange = (startStr, endStr) => {
    const start = new Date(`${startStr}T00:00:00`);
    const end = new Date(`${endStr}T00:00:00`);
    const opts = { month: 'short', day: 'numeric' };
    const startLabel = start.toLocaleDateString('en-US', opts);
    const endLabel = end.toLocaleDateString('en-US', { ...opts, year: 'numeric' });

    return `${startLabel} – ${endLabel}`;
};

// Add / edit form

const showModal = ref(false);
const editingReport = ref(null);

const form = useForm({
    account_id: '',
    platform: 'instagram',
    week_start_date: '',
    follower_count: '',
    reach: '',
    views: '',
    profile_visits: '',
    link_clicks: '',
    engagement: '',
});

const weekEndDate = ref('');

const lastCompleteMonday = () => {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const monday = mondayOnOrBefore(toLocalDateString(today));
    const sunday = sundayFor(monday);
    // If this week isn't over yet, default to the prior complete week instead.
    if (new Date(`${sunday}T00:00:00`) >= today) {
        const priorMonday = new Date(`${monday}T00:00:00`);
        priorMonday.setDate(priorMonday.getDate() - 7);
        return toLocalDateString(priorMonday);
    }
    return monday;
};

const openCreate = () => {
    editingReport.value = null;
    form.reset();
    form.platform = 'instagram';
    form.week_start_date = lastCompleteMonday();
    weekEndDate.value = sundayFor(form.week_start_date);
    form.clearErrors();
    showModal.value = true;
};

const openEdit = (report) => {
    editingReport.value = report;
    form.account_id = report.account_id;
    form.platform = report.platform ?? 'instagram';
    form.week_start_date = report.week_start_date.slice(0, 10);
    form.follower_count = report.follower_count ?? '';
    form.reach = report.reach ?? '';
    form.views = report.views ?? '';
    form.profile_visits = report.profile_visits ?? '';
    form.link_clicks = report.link_clicks ?? '';
    form.engagement = report.engagement ?? '';
    weekEndDate.value = report.week_end_date.slice(0, 10);
    form.clearErrors();
    showModal.value = true;
};

const closeModal = () => {
    showModal.value = false;
    editingReport.value = null;
    form.reset();
    form.clearErrors();
};

const applyPrefill = (data) => {
    ['follower_count', 'reach', 'views', 'profile_visits', 'link_clicks', 'engagement'].forEach((key) => {
        if (data[key] !== null && data[key] !== undefined) {
            form[key] = data[key];
        }
    });
};

const prefillFromSnapshots = async () => {
    if (editingReport.value || !form.account_id || !form.week_start_date) return;

    try {
        const params = new URLSearchParams({
            week_start_date: form.week_start_date,
            week_end_date: weekEndDate.value,
            platform: form.platform || 'instagram',
        });
        const response = await fetch(`/accounts/${form.account_id}/neighboring-weekly-report?${params}`, {
            headers: { Accept: 'application/json' },
        });
        const data = await response.json();
        applyPrefill(data);
    } catch {
        // Silently ignore — user can still fill values manually.
    }
};

const onWeekStartChange = () => {
    if (!form.week_start_date) {
        weekEndDate.value = '';
        return;
    }

    form.week_start_date = mondayOnOrBefore(form.week_start_date);
    weekEndDate.value = sundayFor(form.week_start_date);
    prefillFromSnapshots();
};

const submit = () => {
    const isEditing = !!editingReport.value;
    const options = {
        preserveScroll: true,
        onSuccess: () => {
            closeModal();
            toast.success(isEditing ? 'Weekly report updated.' : 'Weekly report added.');
        },
        onError: () => {
            toast.error(isEditing ? 'Failed to update weekly report.' : 'Failed to add weekly report.');
        },
    };

    if (isEditing) {
        form.put(`/weekly-reports/${editingReport.value.id}`, options);
    } else {
        form.post('/weekly-reports', options);
    }
};

// Delete confirmation

const deletingReport = ref(null);
const deleting = ref(false);

const confirmDestroy = (report) => {
    deletingReport.value = report;
};

const cancelDestroy = () => {
    deletingReport.value = null;
};

const destroy = () => {
    if (!deletingReport.value) return;
    deleting.value = true;

    router.delete(`/weekly-reports/${deletingReport.value.id}`, {
        preserveScroll: true,
        onSuccess: () => {
            toast.success('Weekly report deleted.');
            deletingReport.value = null;
        },
        onError: () => toast.error('Failed to delete weekly report.'),
        onFinish: () => {
            deleting.value = false;
        },
    });
};

const reportActions = (report) =>
    canEdit.value
        ? [
              { label: 'Edit', onClick: () => openEdit(report) },
              { label: 'Delete', danger: true, onClick: () => confirmDestroy(report) },
          ]
        : [];

const formatNumber = (value) => (value === null || value === undefined ? '—' : Number(value).toLocaleString());
</script>

<template>
    <div class="flex flex-wrap items-start justify-between gap-4">
        <div>
            <h1 class="font-display text-2xl font-bold tracking-tight" style="color: var(--ink)">Weekly Reports</h1>
            <p class="mt-1 text-sm" style="color: var(--ink-muted)">
                Raw weekly numbers per account — Monday through Sunday. No scoring, just the metrics.
            </p>
        </div>
        <button
            v-if="canEdit"
            type="button"
            class="rounded-md px-4 py-2 text-sm font-semibold transition-opacity hover:opacity-90"
            style="background-color: var(--accent); color: var(--accent-ink)"
            @click="openCreate"
        >
            Add Weekly Report
        </button>
    </div>

    <div class="mt-6 flex flex-wrap items-center gap-3">
        <input
            v-model="search"
            type="text"
            placeholder="Search account…"
            class="w-56 rounded-md border px-3 py-2 text-sm"
            style="border-color: var(--border); background-color: var(--bg); color: var(--ink)"
            @keyup.enter="applyFilters"
        />
        <div class="w-48">
            <SearchableSelect
                v-model="filterAccountId"
                :options="accountOptions"
                placeholder="All accounts"
                clearable
                clear-label="All accounts"
                @update:model-value="applyFilters"
            />
        </div>
        <div class="w-40">
            <SearchableSelect
                v-model="filterPlatform"
                :options="platformOptions"
                placeholder="All platforms"
                clearable
                clear-label="All platforms"
                @update:model-value="applyFilters"
            />
        </div>
        <button type="button" class="text-sm font-medium" style="color: var(--ink-muted)" @click="clearFilters">
            Clear filters
        </button>
    </div>

    <div class="mt-4 overflow-hidden rounded-lg border" style="border-color: var(--border); background-color: var(--surface)">
        <div class="overflow-x-auto">
            <table class="w-full text-sm">
                <thead>
                    <tr class="border-b text-left" style="border-color: var(--border)">
                        <th class="px-4 py-3 font-semibold" style="color: var(--ink-muted)">Account</th>
                        <th class="px-4 py-3 font-semibold" style="color: var(--ink-muted)">Platform</th>
                        <th class="px-4 py-3 font-semibold" style="color: var(--ink-muted)">Week</th>
                        <th class="px-4 py-3 text-right font-semibold" style="color: var(--ink-muted)">Followers</th>
                        <th class="px-4 py-3 text-right font-semibold" style="color: var(--ink-muted)">Reach</th>
                        <th class="px-4 py-3 text-right font-semibold" style="color: var(--ink-muted)">Views</th>
                        <th class="px-4 py-3 text-right font-semibold" style="color: var(--ink-muted)">Visits</th>
                        <th class="px-4 py-3 text-right font-semibold" style="color: var(--ink-muted)">Link clicks</th>
                        <th class="px-4 py-3 text-right font-semibold" style="color: var(--ink-muted)">Engagement</th>
                        <th v-if="canEdit" class="px-4 py-3" />
                    </tr>
                </thead>
                <tbody>
                    <tr v-if="reports.data.length === 0">
                        <td colspan="10" class="px-4 py-8 text-center text-sm" style="color: var(--ink-faint)">
                            No weekly reports yet.
                        </td>
                    </tr>
                    <tr
                        v-for="report in reports.data"
                        :key="report.id"
                        class="border-b last:border-0"
                        style="border-color: var(--border)"
                    >
                        <td class="px-4 py-3 font-medium" style="color: var(--ink)">{{ report.account?.name ?? '—' }}</td>
                        <td class="px-4 py-3 capitalize" style="color: var(--ink-muted)">{{ report.platform }}</td>
                        <td class="px-4 py-3 tabular-nums" style="color: var(--ink-muted)">
                            {{ formatRange(report.week_start_date.slice(0, 10), report.week_end_date.slice(0, 10)) }}
                        </td>
                        <td class="px-4 py-3 text-right tabular-nums" style="color: var(--ink)">{{ formatNumber(report.follower_count) }}</td>
                        <td class="px-4 py-3 text-right tabular-nums" style="color: var(--ink)">{{ formatNumber(report.reach) }}</td>
                        <td class="px-4 py-3 text-right tabular-nums" style="color: var(--ink)">{{ formatNumber(report.views) }}</td>
                        <td class="px-4 py-3 text-right tabular-nums" style="color: var(--ink)">{{ formatNumber(report.profile_visits) }}</td>
                        <td class="px-4 py-3 text-right tabular-nums" style="color: var(--ink)">{{ formatNumber(report.link_clicks) }}</td>
                        <td class="px-4 py-3 text-right tabular-nums" style="color: var(--ink)">{{ formatNumber(report.engagement) }}</td>
                        <td v-if="canEdit" class="px-4 py-3 text-right">
                            <ActionsMenu :items="reportActions(report)" />
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>

        <div
            v-if="reports.last_page > 1"
            class="flex items-center justify-between border-t px-4 py-3"
            style="border-color: var(--border)"
        >
            <p class="text-sm" style="color: var(--ink-muted)">
                Showing <span class="font-medium tabular-nums" style="color: var(--ink)">{{ reports.from }}–{{ reports.to }}</span>
                of <span class="font-medium tabular-nums" style="color: var(--ink)">{{ reports.total }}</span>
            </p>
            <div class="flex items-center gap-1">
                <button
                    v-for="link in reports.links"
                    :key="link.label"
                    type="button"
                    class="min-w-[2.25rem] rounded-md px-2.5 py-1.5 text-sm font-medium transition-colors"
                    :class="{ 'cursor-not-allowed opacity-40': !link.url }"
                    :style="link.active ? 'background-color: var(--accent); color: var(--accent-ink)' : 'color: var(--ink-muted)'"
                    :disabled="!link.url"
                    v-html="link.label"
                    @click="goToPage(link.url)"
                />
            </div>
        </div>
    </div>

    <!-- Add / edit modal -->
    <div
        v-if="showModal"
        class="fixed inset-0 z-50 flex items-center justify-center p-4"
        style="background-color: rgba(0, 0, 0, 0.5)"
    >
        <div
            class="max-h-[85vh] w-full max-w-lg overflow-y-auto rounded-lg border p-6"
            style="border-color: var(--border); background-color: var(--surface)"
        >
            <div class="flex items-start justify-between">
                <h2 class="font-display text-lg font-bold" style="color: var(--ink)">
                    {{ editingReport ? 'Edit Weekly Report' : 'Add Weekly Report' }}
                </h2>
                <button class="text-sm font-medium" style="color: var(--ink-muted)" @click="closeModal">✕</button>
            </div>

            <form class="mt-6 space-y-4" @submit.prevent="submit">
                <div>
                    <label class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Account</label>
                    <SearchableSelect
                        v-model="form.account_id"
                        :options="accountOptions"
                        placeholder="Select account"
                        class="mt-1"
                        @update:model-value="prefillFromSnapshots"
                    />
                    <p v-if="form.errors.account_id" class="mt-1 text-sm" style="color: var(--status-parah-ink)">{{ form.errors.account_id }}</p>
                </div>

                <div>
                    <label class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Platform</label>
                    <SearchableSelect
                        v-model="form.platform"
                        :options="platformOptions"
                        placeholder="Select platform"
                        class="mt-1"
                        @update:model-value="prefillFromSnapshots"
                    />
                    <p v-if="form.errors.platform" class="mt-1 text-sm" style="color: var(--status-parah-ink)">{{ form.errors.platform }}</p>
                </div>

                <div>
                    <label class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">
                        Week start (Monday)
                    </label>
                    <input
                        v-model="form.week_start_date"
                        type="date"
                        class="mt-1 w-full rounded-md border px-3 py-2 text-sm"
                        style="border-color: var(--border); background-color: var(--bg); color: var(--ink)"
                        @change="onWeekStartChange"
                    />
                    <p class="mt-1 text-xs" style="color: var(--ink-faint)">
                        Any date picked snaps to that week's Monday. Week ends Sunday:
                        <span class="font-medium tabular-nums" style="color: var(--ink-muted)">{{ weekEndDate || '—' }}</span>
                    </p>
                    <p v-if="form.errors.week_start_date" class="mt-1 text-sm" style="color: var(--status-parah-ink)">{{ form.errors.week_start_date }}</p>
                </div>

                <div class="grid grid-cols-2 gap-3">
                    <div>
                        <label class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Followers</label>
                        <input
                            v-model="form.follower_count"
                            type="number"
                            min="0"
                            class="mt-1 w-full rounded-md border px-3 py-2 text-sm"
                            style="border-color: var(--border); background-color: var(--bg); color: var(--ink)"
                        />
                    </div>
                    <div>
                        <label class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Reach</label>
                        <input
                            v-model="form.reach"
                            type="number"
                            min="0"
                            class="mt-1 w-full rounded-md border px-3 py-2 text-sm"
                            style="border-color: var(--border); background-color: var(--bg); color: var(--ink)"
                        />
                    </div>
                    <div>
                        <label class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Views</label>
                        <input
                            v-model="form.views"
                            type="number"
                            min="0"
                            class="mt-1 w-full rounded-md border px-3 py-2 text-sm"
                            style="border-color: var(--border); background-color: var(--bg); color: var(--ink)"
                        />
                    </div>
                    <div>
                        <label class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Profile visits</label>
                        <input
                            v-model="form.profile_visits"
                            type="number"
                            min="0"
                            class="mt-1 w-full rounded-md border px-3 py-2 text-sm"
                            style="border-color: var(--border); background-color: var(--bg); color: var(--ink)"
                        />
                    </div>
                    <div>
                        <label class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Link clicks</label>
                        <input
                            v-model="form.link_clicks"
                            type="number"
                            min="0"
                            class="mt-1 w-full rounded-md border px-3 py-2 text-sm"
                            style="border-color: var(--border); background-color: var(--bg); color: var(--ink)"
                        />
                    </div>
                    <div>
                        <label class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Engagement</label>
                        <input
                            v-model="form.engagement"
                            type="number"
                            class="mt-1 w-full rounded-md border px-3 py-2 text-sm"
                            style="border-color: var(--border); background-color: var(--bg); color: var(--ink)"
                        />
                    </div>
                </div>

                <div class="flex justify-end gap-3 border-t pt-4" style="border-color: var(--border)">
                    <button
                        type="button"
                        class="rounded-md border px-4 py-2 text-sm font-semibold"
                        style="border-color: var(--border); color: var(--ink)"
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
                        {{ editingReport ? 'Save changes' : 'Add report' }}
                    </button>
                </div>
            </form>
        </div>
    </div>

    <ConfirmDialog
        :open="!!deletingReport"
        title="Delete weekly report?"
        :message="`This will permanently delete the weekly report for “${deletingReport?.account?.name ?? ''}”.`"
        confirm-label="Delete"
        :processing="deleting"
        @confirm="destroy"
        @cancel="cancelDestroy"
    />
</template>
