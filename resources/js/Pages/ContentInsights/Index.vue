<script setup>
import { computed, onBeforeUnmount, onMounted, ref, watch } from 'vue';
import { router } from '@inertiajs/vue3';
import AppLayout from '../../Layouts/AppLayout.vue';
import ContentInsightModal from '../../Components/ContentInsightModal.vue';
import ContentInsightDetailModal from '../../Components/ContentInsightDetailModal.vue';
import ActionsMenu from '../../Components/ActionsMenu.vue';
import ConfirmDialog from '../../Components/ConfirmDialog.vue';
import StatCard from '../../Components/StatCard.vue';
import { useToast } from '../../composables/useToast';
import { useAuth } from '../../composables/useAuth';

defineOptions({ layout: AppLayout });

const toast = useToast();
const { canEdit } = useAuth();

const props = defineProps({
    allInsights: { type: Array, default: () => [] },
    months: { type: Array, default: () => [] },
    accounts: { type: Array, required: true },
});

// The table is built from allInsights (a flat shape: account_name, platform,
// cycle_start_date... directly on the object), but the detail/edit modals
// expect a nested shape — insight.account.name / insight.cycle.{...}.
// Normalize a flat allInsights entry into that nested shape before opening
// either modal.
const toNestedInsight = (insight) => ({
    ...insight,
    account: { id: insight.account_id, name: insight.account_name },
    cycle: insight.cycle_id
        ? {
              id: insight.cycle_id,
              platform: insight.platform,
              cycle_start_date: insight.cycle_start_date,
              cycle_end_date: insight.cycle_end_date,
          }
        : null,
});

// --- Raw-data detail modal ---
const detailTarget = ref(null);
const openDetail = (row) => {
    // Full cycle history for this account, oldest first — lets the modal plot
    // the Weighted Score trend across a picked month range instead of just
    // the one current/previous pair the table row itself compares.
    const history = props.allInsights
        .filter((i) => i.account_id === row.current.account_id && i.cycle_start_date)
        .sort((a, b) => (a.cycle_start_date < b.cycle_start_date ? -1 : 1));

    detailTarget.value = {
        insight: toNestedInsight(row.current),
        previous: row.previous ? toNestedInsight(row.previous) : null,
        weightedScores: row.weightedScores,
        hasRange: hasRange.value,
        history,
    };
};
const closeDetail = () => (detailTarget.value = null);

// --- Add / edit modal ---
const modalTarget = ref(null);
const openCreate = () => (modalTarget.value = {});
const openEdit = (row) => (modalTarget.value = toNestedInsight(row));
const closeModal = () => (modalTarget.value = null);
const onSaved = () => {
    const wasEdit = !!modalTarget.value?.id;
    modalTarget.value = null;
    toast.success(wasEdit ? 'Content insight updated.' : 'Content insight saved.');
};

// --- Delete ---
const deleting = ref(null);
const deletingBusy = ref(false);
const destroy = () => {
    if (!deleting.value) return;
    deletingBusy.value = true;
    router.delete(`/content-insights/${deleting.value.id}`, {
        preserveScroll: true,
        onSuccess: () => {
            toast.success('Content insight deleted.');
            deleting.value = null;
        },
        onError: () => toast.error('Failed to delete.'),
        onFinish: () => {
            deletingBusy.value = false;
        },
    });
};

// --- Presentation helpers ---

const platformLabel = (p) => (p ? p.charAt(0).toUpperCase() + p.slice(1) : '');
const monthLabel = (ym) => {
    if (!ym) return '—';
    const [y, m] = ym.split('-');
    return new Date(Number(y), Number(m) - 1, 1).toLocaleDateString('en-US', {
        month: 'short',
        year: 'numeric',
    });
};

const cycleRange = (start, end) => {
    if (!start) return '—';
    const fmt = (d) =>
        new Date(d).toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric' });
    return `${fmt(start)} – ${fmt(end)}`;
};

const pct = (from, to) => {
    if (from === null || from === undefined || to === null || to === undefined || from === 0) return null;
    return ((to - from) / from) * 100;
};
const fmtPct = (v) => (v === null ? '—' : `${v > 0 ? '+' : ''}${Math.round(v * 10) / 10}%`);
const pctStyle = (v) =>
    v === null
        ? 'color: var(--ink-faint)'
        : v >= 0
          ? 'color: var(--status-sip-ink)'
          : 'color: var(--status-parah-ink)';

// Weighted Content Score — one score per content type, blending that type's
// Views % change, Interactions % change, and (Posts/Reels only) the account's
// own follower Growth % change, by fixed weights. A missing input drops out
// and the remaining weights renormalize, so a missing growth figure never
// silently drags a score to 0.
const contentScoreWeights = {
    posts: [
        { source: 'views', weight: 0.5 },
        { source: 'interactions', weight: 0.2 },
        { source: 'growth', weight: 0.3 },
    ],
    reels: [
        { source: 'views', weight: 0.5 },
        { source: 'interactions', weight: 0.2 },
        { source: 'growth', weight: 0.3 },
    ],
    story: [
        { source: 'views', weight: 0.8 },
        { source: 'interactions', weight: 0.2 },
    ],
};
const contentTypeLabels = { posts: 'Posts', reels: 'Reels', story: 'Story' };

const weightedScoresFor = (from, to) => {
    const growthRate = pct(from.end_follower, to.end_follower);

    return Object.entries(contentScoreWeights).map(([type, components]) => {
        const values = {
            views: pct(from[`viewers_${type}`], to[`viewers_${type}`]),
            interactions: pct(from[`interactions_${type}`], to[`interactions_${type}`]),
            growth: growthRate,
        };

        const available = components.filter((c) => values[c.source] !== null);
        const weightSum = available.reduce((sum, c) => sum + c.weight, 0);

        const score =
            available.length === 0
                ? null
                : available.reduce((sum, c) => sum + (values[c.source] * c.weight) / weightSum, 0);

        return {
            key: type,
            label: contentTypeLabels[type],
            score,
            components: components.map((c) => ({ source: c.source, weight: c.weight, value: values[c.source] })),
        };
    });
};

// --- Month range: which two cycles each row's Weighted Score compares.
// Empty = "latest cycle vs. the one right before it" per account (default).
// Picking From/To scores each account's cycle in the From-month against its
// cycle in the To-month instead — same range control style used elsewhere
// in the app (a trigger button + floating panel). ---

const fromMonth = ref('');
const toMonth = ref('');
const hasRange = computed(() => !!fromMonth.value && !!toMonth.value);
const rangeOpen = ref(false);
const rangeRef = ref(null);

const resetRange = () => {
    fromMonth.value = '';
    toMonth.value = '';
};

const onClickOutsideRange = (event) => {
    if (rangeRef.value && !rangeRef.value.contains(event.target)) {
        rangeOpen.value = false;
    }
};

onMounted(() => document.addEventListener('click', onClickOutsideRange));
onBeforeUnmount(() => document.removeEventListener('click', onClickOutsideRange));

// The account's insight with the closest cycle_start_date strictly before
// the given one — used for the default (no range picked) "latest vs.
// previous cycle" reading.
const previousInsightFor = (insight) => {
    const candidates = props.allInsights
        .filter(
            (i) =>
                i.account_id === insight.account_id &&
                i.cycle_start_date &&
                i.cycle_start_date < insight.cycle_start_date,
        )
        .sort((a, b) => (a.cycle_start_date < b.cycle_start_date ? 1 : -1));

    return candidates[0] ?? null;
};

// One row per account. Default: each account's latest cycle, scored against
// the cycle right before it. With a From→To range picked: each account's
// cycle in the From-month scored against its cycle in the To-month — an
// account missing either month is left out of the range view.
const accountRows = computed(() => {
    if (hasRange.value) {
        const byAccount = new Map();
        for (const ins of props.allInsights) {
            if (ins.month !== fromMonth.value && ins.month !== toMonth.value) continue;
            if (!byAccount.has(ins.account_id)) byAccount.set(ins.account_id, {});
            byAccount.get(ins.account_id)[ins.month] = ins;
        }

        const rows = [];
        for (const pair of byAccount.values()) {
            const from = pair[fromMonth.value];
            const to = pair[toMonth.value];
            if (!from || !to) continue;
            rows.push({ current: to, previous: from, weightedScores: weightedScoresFor(from, to) });
        }
        return rows.sort((a, b) => (a.current.account_name || '').localeCompare(b.current.account_name || ''));
    }

    const latestByAccount = new Map();
    for (const ins of props.allInsights) {
        if (!ins.cycle_start_date) continue;
        const existing = latestByAccount.get(ins.account_id);
        if (!existing || ins.cycle_start_date > existing.cycle_start_date) {
            latestByAccount.set(ins.account_id, ins);
        }
    }

    return [...latestByAccount.values()]
        .sort((a, b) => (a.account_name || '').localeCompare(b.account_name || ''))
        .map((insight) => {
            const prev = previousInsightFor(insight);
            return { current: insight, previous: prev, weightedScores: prev ? weightedScoresFor(prev, insight) : null };
        });
});

// --- Search (by account name) + platform filter — narrow the account list
// before sorting/paginating, so both apply on top of whichever set the
// range picker produced. ---

const search = ref('');
const platformFilter = ref('all');

const availablePlatforms = computed(() => [...new Set(props.allInsights.map((i) => i.platform).filter(Boolean))].sort());

const filteredRows = computed(() => {
    const query = search.value.trim().toLowerCase();

    return accountRows.value.filter((row) => {
        const matchesSearch = !query || (row.current.account_name || '').toLowerCase().includes(query);
        const matchesPlatform = platformFilter.value === 'all' || row.current.platform === platformFilter.value;
        return matchesSearch && matchesPlatform;
    });
});

// --- Sorting — click a column header to sort by it; click again to flip
// direction. 'account' sorts alphabetically; 'posts'/'reels'/'story' sort by
// that content type's Weighted Score (nulls — no prior cycle to compare —
// always sink to the bottom regardless of direction, since they aren't a
// value on the scale being sorted). ---

const sortKey = ref('account');
const sortDir = ref('asc');

const sortBy = (key) => {
    if (sortKey.value === key) {
        sortDir.value = sortDir.value === 'asc' ? 'desc' : 'asc';
    } else {
        sortKey.value = key;
        sortDir.value = key === 'account' ? 'asc' : 'desc';
    }
    page.value = 1;
};

const scoreFor = (row, type) => row.weightedScores?.find((s) => s.key === type)?.score ?? null;

const sortedRows = computed(() => {
    if (sortKey.value === 'account') {
        const rows = [...filteredRows.value];
        rows.sort((a, b) => (a.current.account_name || '').localeCompare(b.current.account_name || ''));
        return sortDir.value === 'asc' ? rows : rows.reverse();
    }

    const withValue = [];
    const withoutValue = [];
    for (const row of filteredRows.value) {
        const value = scoreFor(row, sortKey.value);
        (value === null ? withoutValue : withValue).push(row);
    }
    withValue.sort((a, b) => scoreFor(a, sortKey.value) - scoreFor(b, sortKey.value));
    if (sortDir.value === 'desc') withValue.reverse();
    return [...withValue, ...withoutValue];
});

// --- Client-side pagination — the table is one row per account, so a plain
// page-through keeps a large account list from turning into one long scroll. ---

const PAGE_SIZE = 15;
const page = ref(1);

watch([search, platformFilter], () => {
    page.value = 1;
});

const pageCount = computed(() => Math.max(1, Math.ceil(sortedRows.value.length / PAGE_SIZE)));
const pagedRows = computed(() => {
    const start = (page.value - 1) * PAGE_SIZE;
    return sortedRows.value.slice(start, start + PAGE_SIZE);
});

// Reset to page 1 whenever the underlying row set changes shape (range picked
// / cleared) so the user isn't stranded on a now out-of-range page.
const goToPage = (n) => {
    page.value = Math.min(Math.max(1, n), pageCount.value);
};

const applyRange = () => {
    rangeOpen.value = false;
    page.value = 1;
};

const clearRange = () => {
    resetRange();
    rangeOpen.value = false;
    page.value = 1;
};

// --- Summary tiles ---

const totalAccounts = computed(() => accountRows.value.length);
const monthsCovered = computed(() => props.months.length);
const platformsCovered = computed(
    () => new Set(props.allInsights.map((i) => i.platform).filter(Boolean)).size,
);
</script>

<template>
    <div class="flex flex-wrap items-start justify-between gap-4">
        <div>
            <h1 class="font-display text-2xl font-bold tracking-tight" style="color: var(--ink)">Content Insights</h1>
            <p class="mt-1 text-sm" style="color: var(--ink-muted)">
                Viewers and Interactions from Instagram Insights, split by content type — Posts, Reels, Story.
            </p>
        </div>
        <button
            v-if="canEdit"
            type="button"
            class="inline-flex shrink-0 items-center gap-1.5 rounded-md px-4 py-2 text-sm font-semibold transition-opacity hover:opacity-90"
            style="background-color: var(--accent); color: var(--accent-ink)"
            @click="openCreate"
        >
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-4 w-4">
                <path d="M12 5v14M5 12h14" />
            </svg>
            Add insight
        </button>
    </div>

    <!-- Summary tiles -->
    <div class="mt-6 grid grid-cols-2 gap-3 sm:grid-cols-3">
        <StatCard label="Accounts Shown" :value="String(totalAccounts)" />
        <StatCard label="Months Tracked" :value="String(monthsCovered)" />
        <StatCard label="Platforms" :value="String(platformsCovered)" hint="with recorded insights" />
    </div>

    <!-- Toolbar: month-range control -->
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
            />
            <button
                v-if="search"
                type="button"
                class="absolute right-2.5 top-1/2 -translate-y-1/2 transition-colors hover:opacity-70"
                style="color: var(--ink-faint)"
                aria-label="Clear search"
                @click="search = ''"
            >
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-4 w-4">
                    <path d="M18 6 6 18M6 6l12 12" />
                </svg>
            </button>
        </div>

        <select
            v-model="platformFilter"
            class="rounded-md border px-3 py-2 text-sm transition-colors focus:outline-none"
            style="border-color: var(--border); background-color: var(--surface); color: var(--ink)"
        >
            <option value="all">All platforms</option>
            <option v-for="p in availablePlatforms" :key="p" :value="p">{{ platformLabel(p) }}</option>
        </select>

        <div ref="rangeRef" class="relative">
            <button
                type="button"
                class="relative inline-flex items-center gap-1.5 rounded-md border px-3 py-2 text-sm font-medium transition-colors hover:opacity-70"
                :style="
                    hasRange
                        ? 'border-color: var(--accent); color: var(--accent); background-color: var(--accent-soft)'
                        : 'border-color: var(--border); color: var(--ink)'
                "
                @click="rangeOpen = !rangeOpen"
            >
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-4 w-4">
                    <path d="M3 3v18h18M7 15l4-4 4 4 5-6" />
                </svg>
                <template v-if="hasRange">{{ monthLabel(fromMonth) }} → {{ monthLabel(toMonth) }}</template>
                <template v-else>Compare specific months</template>
            </button>

            <div
                v-if="rangeOpen"
                class="absolute left-0 top-full z-20 mt-2 w-72 rounded-xl border p-4 shadow-xl"
                style="border-color: var(--border); background-color: var(--surface-raised)"
            >
                <p class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Compare two months</p>
                <p class="mt-1 text-xs" style="color: var(--ink-muted)">
                    Score each account's cycle in the first month against its cycle in the second.
                    Leave blank to use each account's latest cycle vs. the one before it.
                </p>

                <div class="mt-3 flex items-center gap-2">
                    <select
                        v-model="fromMonth"
                        class="w-full rounded-md border px-2.5 py-2 text-sm focus:outline-none"
                        style="border-color: var(--border); background-color: var(--surface); color: var(--ink)"
                    >
                        <option value="">From…</option>
                        <option v-for="m in months" :key="m" :value="m">{{ monthLabel(m) }}</option>
                    </select>
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-4 w-4 shrink-0" style="color: var(--ink-faint)">
                        <path d="M5 12h14M13 6l6 6-6 6" />
                    </svg>
                    <select
                        v-model="toMonth"
                        class="w-full rounded-md border px-2.5 py-2 text-sm focus:outline-none"
                        style="border-color: var(--border); background-color: var(--surface); color: var(--ink)"
                    >
                        <option value="">To…</option>
                        <option v-for="m in months" :key="m" :value="m">{{ monthLabel(m) }}</option>
                    </select>
                </div>

                <div class="mt-3 flex items-center justify-between">
                    <button
                        v-if="fromMonth || toMonth"
                        type="button"
                        class="text-xs font-medium underline transition-opacity hover:opacity-70"
                        style="color: var(--ink-muted)"
                        @click="clearRange"
                    >
                        Reset
                    </button>
                    <span v-else />
                    <button
                        type="button"
                        class="rounded-md px-3 py-1.5 text-xs font-semibold transition-opacity hover:opacity-90"
                        style="background-color: var(--accent); color: var(--accent-ink)"
                        @click="applyRange"
                    >
                        Done
                    </button>
                </div>
            </div>
        </div>

        <button
            v-if="hasRange"
            type="button"
            class="text-sm font-medium transition-colors hover:opacity-70"
            style="color: var(--ink-muted)"
            @click="clearRange"
        >
            Clear
        </button>

        <p class="ml-auto text-xs" style="color: var(--ink-faint)">
            {{ hasRange ? 'Scored against the picked months' : "Scored against each account's previous cycle" }}
        </p>
    </div>

    <!-- Weighted Content Score table -->
    <div
        v-if="filteredRows.length === 0"
        class="mt-4 flex flex-col items-center gap-2 rounded-xl border border-dashed p-14 text-center"
        style="border-color: var(--border-strong)"
    >
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" class="h-8 w-8" style="color: var(--ink-faint)">
            <rect x="3" y="3" width="18" height="18" rx="2" />
            <path d="M8 12h8M8 16h5M8 8h3" />
        </svg>
        <p class="text-sm font-medium" style="color: var(--ink)">
            <template v-if="accountRows.length > 0">No accounts match your search or filter</template>
            <template v-else-if="hasRange">No overlap between these months</template>
            <template v-else>No content insights yet</template>
        </p>
        <p class="text-xs" style="color: var(--ink-faint)">
            <template v-if="accountRows.length > 0">Try a different name or platform.</template>
            <template v-else-if="hasRange">
                No account has a Content Insight in both {{ monthLabel(fromMonth) }} and {{ monthLabel(toMonth) }}.
            </template>
            <template v-else>Add one to start tracking Viewers and Interactions by content type.</template>
        </p>
    </div>

    <div v-else class="mt-4 overflow-x-auto rounded-xl border" style="border-color: var(--border); background-color: var(--surface)">
        <table class="min-w-full">
            <thead>
                <tr style="border-bottom: 1px solid var(--border)">
                    <th
                        class="cursor-pointer select-none px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide transition-colors hover:opacity-70"
                        style="color: var(--ink-faint)"
                        @click="sortBy('account')"
                    >
                        Account<span v-if="sortKey === 'account'" class="ml-0.5">{{ sortDir === 'asc' ? '↑' : '↓' }}</span>
                    </th>
                    <th
                        v-for="type in ['posts', 'reels', 'story']"
                        :key="type"
                        class="cursor-pointer select-none px-2 py-3 text-center text-xs font-semibold uppercase tracking-wide transition-colors hover:opacity-70"
                        :style="type === 'posts' ? 'color: var(--ink-faint); border-left: 1px solid var(--border)' : 'color: var(--ink-faint)'"
                        :title="hasRange ? 'vs. the picked From month' : `vs. this account's previous cycle`"
                        @click="sortBy(type)"
                    >
                        {{ contentTypeLabels[type] }}<span v-if="sortKey === type" class="ml-0.5">{{ sortDir === 'asc' ? '↑' : '↓' }}</span>
                    </th>
                    <th class="px-4 py-3 text-right text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)"></th>
                </tr>
            </thead>
            <tbody>
                <tr
                    v-for="row in pagedRows"
                    :key="row.current.id"
                    class="cursor-pointer transition-colors hover:opacity-80"
                    style="border-bottom: 1px solid var(--border)"
                    @click="openDetail(row)"
                >
                    <td class="px-4 py-3.5">
                        <div class="flex items-center gap-2">
                            <div class="min-w-0">
                                <p class="truncate text-sm font-medium" style="color: var(--ink)">{{ row.current.account_name || '—' }}</p>
                                <p class="flex items-center gap-1.5 text-[11px]" style="color: var(--ink-faint)">
                                    <span v-if="row.current.platform" class="font-semibold uppercase tracking-wide">
                                        {{ platformLabel(row.current.platform) }}
                                    </span>
                                    <span class="tabular-nums">{{ cycleRange(row.current.cycle_start_date, row.current.cycle_end_date) }}</span>
                                </p>
                            </div>
                        </div>
                    </td>
                    <template v-if="row.weightedScores">
                        <td
                            v-for="(score, i) in row.weightedScores"
                            :key="`w-${score.key}`"
                            class="px-2 py-3.5 text-center text-sm font-semibold tabular-nums"
                            :style="[i === 0 ? 'border-left: 1px solid var(--border)' : '', pctStyle(score.score)]"
                            :title="score.score === null ? 'Not enough data' : `${score.label}: ${fmtPct(score.score)}`"
                        >
                            <span v-if="score.score !== null" class="inline-flex items-center gap-0.5">
                                {{ score.score >= 0 ? '▲' : '▼' }} {{ fmtPct(score.score) }}
                            </span>
                            <span v-else style="color: var(--ink-faint)">—</span>
                        </td>
                    </template>
                    <td v-else colspan="3" class="px-2 py-3.5 text-center text-xs" style="color: var(--ink-faint); border-left: 1px solid var(--border)">
                        No prior cycle
                    </td>
                    <td class="px-4 py-3.5 text-right">
                        <ActionsMenu
                            v-if="canEdit"
                            :items="[
                                { label: 'Edit', onClick: () => openEdit(row.current) },
                                { label: 'Delete', danger: true, onClick: () => (deleting = toNestedInsight(row.current)) },
                            ]"
                            @click.stop
                        />
                    </td>
                </tr>
            </tbody>
        </table>
    </div>

    <!-- Pagination — client-side, since the table is one row per account. -->
    <div v-if="accountRows.length > 0 && pageCount > 1" class="mt-6 flex items-center justify-between">
        <p class="text-sm" style="color: var(--ink-muted)">
            Page <span class="font-medium tabular-nums" style="color: var(--ink)">{{ page }}</span>
            of <span class="font-medium tabular-nums" style="color: var(--ink)">{{ pageCount }}</span>
            <span class="ml-1">({{ filteredRows.length }} account{{ filteredRows.length === 1 ? '' : 's' }})</span>
        </p>
        <div class="flex items-center gap-1">
            <button
                type="button"
                class="min-w-[2.25rem] rounded-md px-2.5 py-1.5 text-sm font-medium transition-colors"
                :class="{ 'cursor-not-allowed opacity-40': page === 1 }"
                style="color: var(--ink-muted)"
                :disabled="page === 1"
                @click="goToPage(page - 1)"
            >
                ‹
            </button>
            <button
                v-for="n in pageCount"
                :key="n"
                type="button"
                class="min-w-[2.25rem] rounded-md px-2.5 py-1.5 text-sm font-medium transition-colors"
                :style="n === page ? 'background-color: var(--accent); color: var(--accent-ink)' : 'color: var(--ink-muted)'"
                @click="goToPage(n)"
            >
                {{ n }}
            </button>
            <button
                type="button"
                class="min-w-[2.25rem] rounded-md px-2.5 py-1.5 text-sm font-medium transition-colors"
                :class="{ 'cursor-not-allowed opacity-40': page === pageCount }"
                style="color: var(--ink-muted)"
                :disabled="page === pageCount"
                @click="goToPage(page + 1)"
            >
                ›
            </button>
        </div>
    </div>

    <ContentInsightDetailModal
        v-if="detailTarget"
        :insight="detailTarget.insight"
        :previous="detailTarget.previous"
        :has-range="detailTarget.hasRange"
        :history="detailTarget.history"
        @close="closeDetail"
    />

    <ContentInsightModal
        v-if="modalTarget"
        :insight="modalTarget.id ? modalTarget : null"
        :accounts="accounts"
        @close="closeModal"
        @saved="onSaved"
    />

    <ConfirmDialog
        :open="!!deleting"
        title="Delete this content insight?"
        :message="deleting ? `This removes the record for ${deleting.account?.name}. This cannot be undone.` : ''"
        :processing="deletingBusy"
        @confirm="destroy"
        @cancel="deleting = null"
    />
</template>
