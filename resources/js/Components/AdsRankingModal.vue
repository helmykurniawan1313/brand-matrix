<script setup>
import { computed, onBeforeUnmount, onMounted, ref, watch } from 'vue';
import MonthRangePicker from './MonthRangePicker.vue';

const emit = defineEmits(['close']);

const loading = ref(true);
const error = ref(null);
const rows = ref([]);
const months = ref([]);

// Single range calendar — this is a sum over a continuous span of cycles, not
// a before/after comparison, so the in-range shading correctly communicates
// "everything between these two months is included."
const monthFrom = ref('');
const monthTo = ref('');
const hasRange = computed(() => !!monthFrom.value || !!monthTo.value);

const rangePickerOpen = ref(false);
const rangePickerRef = ref(null);

const onClickOutside = (event) => {
    if (rangePickerRef.value && !rangePickerRef.value.contains(event.target)) {
        rangePickerOpen.value = false;
    }
};
onMounted(() => document.addEventListener('click', onClickOutside));
onBeforeUnmount(() => document.removeEventListener('click', onClickOutside));

const formatMonthLabel = (ym) => {
    if (!ym) return '';
    const [y, m] = ym.split('-');
    return new Date(Number(y), Number(m) - 1, 1).toLocaleString('en-US', { month: 'short', year: 'numeric' });
};

const clearRange = () => {
    monthFrom.value = '';
    monthTo.value = '';
    rangePickerOpen.value = false;
};

// Spend is currency-specific per cycle (ads_currency) — different currencies
// are never summed or ranked together. Rows arrive pre-split by the backend
// (one row per account per currency); group them here and show one currency
// at a time via a tab, so "#1" always means "#1 within this currency."
const currencies = computed(() => [...new Set(rows.value.map((r) => r.currency))].sort());
const activeCurrency = ref(null);

watch(currencies, (list) => {
    if (!list.includes(activeCurrency.value)) {
        activeCurrency.value = list[0] ?? null;
    }
});

const rowsForActiveCurrency = computed(() => rows.value.filter((r) => r.currency === activeCurrency.value));

const sortKey = ref('total_ads_spend');
const sortDir = ref('desc');

const sortBy = (key) => {
    if (sortKey.value === key) {
        sortDir.value = sortDir.value === 'asc' ? 'desc' : 'asc';
    } else {
        sortKey.value = key;
        sortDir.value = 'desc';
    }
};

const sortedRows = computed(() =>
    [...rowsForActiveCurrency.value].sort((a, b) => {
        const result = a[sortKey.value] - b[sortKey.value];
        return sortDir.value === 'asc' ? result : -result;
    }),
);

const isRanked = computed(() => sortKey.value === 'total_ads_spend' && sortDir.value === 'desc');

const formatNumber = (value) => new Intl.NumberFormat('en-US').format(value ?? 0);

const filterParams = () => {
    const params = new URLSearchParams();
    if (monthFrom.value) params.set('month_from', monthFrom.value);
    if (monthTo.value) params.set('month_to', monthTo.value || monthFrom.value);
    return params;
};

const load = async () => {
    loading.value = true;
    error.value = null;

    try {
        const response = await fetch(`/cycles-ads-ranking?${filterParams().toString()}`, {
            headers: { Accept: 'application/json' },
        });

        if (!response.ok) throw new Error('Failed to load ranking.');

        const data = await response.json();
        rows.value = data.rows ?? [];
        months.value = data.months ?? [];

        if (rows.value.length === 0) {
            error.value = 'No accounts with ads spend recorded for this range.';
        }
    } catch (e) {
        error.value = e.message;
    } finally {
        loading.value = false;
    }
};

watch([monthFrom, monthTo], load);

load();

const pdfUrl = computed(() => `/cycles-ads-ranking-pdf?${filterParams().toString()}`);
const excelUrl = computed(() => `/cycles-ads-ranking-excel?${filterParams().toString()}`);
</script>

<template>
    <div class="fixed inset-0 z-10 flex items-center justify-center bg-black/50 px-4 py-6 backdrop-blur-sm">
        <div
            class="flex h-[82vh] w-full max-w-3xl flex-col overflow-hidden rounded-lg border shadow-2xl"
            style="background-color: var(--surface-raised); border-color: var(--border)"
        >
            <!-- Header -->
            <div class="flex shrink-0 items-start justify-between gap-4 px-6 pt-5 pb-3">
                <div class="min-w-0">
                    <h2 class="font-display text-lg font-bold leading-tight" style="color: var(--ink)">Ads Nominal Ranking</h2>
                    <p class="mt-1 text-sm" style="color: var(--ink-muted)">Accounts ranked by total ads spend</p>
                </div>
                <div class="flex shrink-0 items-center gap-1">
                    <a
                        :href="pdfUrl"
                        title="Download PDF"
                        aria-label="Download PDF"
                        class="flex h-8 w-8 items-center justify-center rounded-md transition-colors hover:opacity-70"
                        style="color: var(--ink-muted)"
                    >
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" class="h-4 w-4">
                            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z" />
                            <path d="M14 2v6h6" />
                            <text x="7.5" y="17.5" font-size="6" font-weight="700" fill="currentColor" stroke="none">PDF</text>
                        </svg>
                    </a>
                    <a
                        :href="excelUrl"
                        title="Download Excel"
                        aria-label="Download Excel"
                        class="flex h-8 w-8 items-center justify-center rounded-md transition-colors hover:opacity-70"
                        style="color: var(--ink-muted)"
                    >
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" class="h-4 w-4">
                            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z" />
                            <path d="M14 2v6h6" />
                            <path d="m9 13 2 3 M13 13l-2 3" />
                        </svg>
                    </a>
                    <div class="mx-1 h-5 w-px" style="background-color: var(--border)" />
                    <button
                        type="button"
                        class="flex h-8 w-8 items-center justify-center rounded-md transition-colors hover:opacity-70"
                        style="color: var(--ink-muted)"
                        aria-label="Close"
                        @click="emit('close')"
                    >
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-5 w-5">
                            <path d="M18 6 6 18M6 6l12 12" />
                        </svg>
                    </button>
                </div>
            </div>

            <!-- Filter panel -->
            <div class="shrink-0 border-b px-6 pb-3" style="border-color: var(--border)">
                <div class="flex flex-wrap items-center gap-2">
                    <div ref="rangePickerRef" class="relative">
                        <button
                            type="button"
                            class="inline-flex items-center gap-1.5 rounded-lg border px-2.5 py-1.5 text-xs font-medium transition-colors hover:opacity-80"
                            :style="
                                hasRange
                                    ? 'border-color: var(--accent); background-color: var(--accent-soft); color: var(--accent)'
                                    : 'border-color: var(--border); background-color: var(--surface); color: var(--ink-muted)'
                            "
                            @click="rangePickerOpen = !rangePickerOpen"
                        >
                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-3.5 w-3.5">
                                <rect x="3" y="4" width="18" height="18" rx="2" />
                                <path d="M3 10h18M8 2v4M16 2v4" />
                            </svg>
                            <template v-if="hasRange">
                                {{ formatMonthLabel(monthFrom) || '…' }} → {{ formatMonthLabel(monthTo || monthFrom) }}
                            </template>
                            <template v-else>Cycle Month Range</template>
                        </button>

                        <div v-if="rangePickerOpen" class="absolute left-0 top-full z-20 mt-2 w-72 shadow-xl">
                            <MonthRangePicker
                                v-model:model-from="monthFrom"
                                v-model:model-to="monthTo"
                                :allowed-months="months"
                                class="!max-w-none"
                            />
                            <button
                                type="button"
                                class="mt-2 w-full rounded-md py-1.5 text-xs font-semibold transition-opacity hover:opacity-90"
                                style="background-color: var(--accent); color: var(--accent-ink)"
                                @click="rangePickerOpen = false"
                            >
                                Done
                            </button>
                        </div>
                    </div>

                    <button
                        v-if="hasRange"
                        type="button"
                        class="text-xs font-medium transition-opacity hover:opacity-70"
                        style="color: var(--accent)"
                        @click="clearRange"
                    >
                        Reset
                    </button>

                    <span class="ml-auto text-xs" style="color: var(--ink-faint)">
                        {{ hasRange ? `${formatMonthLabel(monthFrom) || '…'} – ${formatMonthLabel(monthTo || monthFrom)}` : 'All time' }}
                    </span>
                </div>
            </div>

            <!-- Currency tabs — only shown when spend was recorded in more than
                 one currency, since otherwise there's nothing to switch between. -->
            <div
                v-if="!loading && !error && currencies.length > 1"
                class="flex shrink-0 gap-1 border-b px-6 pt-3"
                style="border-color: var(--border)"
            >
                <button
                    v-for="currency in currencies"
                    :key="currency"
                    type="button"
                    class="relative -mb-px rounded-t-md border-b-2 px-3 pb-2.5 pt-1 text-sm font-semibold transition-colors"
                    :style="
                        activeCurrency === currency
                            ? 'border-color: var(--accent); color: var(--ink)'
                            : 'border-color: transparent; color: var(--ink-faint)'
                    "
                    @click="activeCurrency = currency"
                >
                    {{ currency }}
                </button>
            </div>

            <!-- Body -->
            <div class="min-h-0 flex-1 overflow-y-auto px-6 pb-6" style="background-color: var(--surface-raised)">
                <div v-if="loading" class="flex h-40 items-center justify-center">
                    <span class="text-sm" style="color: var(--ink-faint)">Loading…</span>
                </div>

                <div v-else-if="error" class="flex h-40 flex-col items-center justify-center gap-1 text-center">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" class="h-8 w-8" style="color: var(--ink-faint)">
                        <path d="M3 3v18h18" />
                        <path d="m19 9-5 5-4-4-3 3" />
                    </svg>
                    <p class="text-sm" style="color: var(--ink-faint)">{{ error }}</p>
                </div>

                <table v-else class="min-w-full">
                    <thead class="sticky top-0" style="background-color: var(--surface-raised)">
                        <tr style="border-bottom: 1px solid var(--border)">
                            <th class="w-12 py-2.5 pr-2 text-left text-[11px] font-semibold uppercase tracking-wide" style="color: var(--ink-faint)"></th>
                            <th class="py-2.5 text-left text-[11px] font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Account</th>
                            <th
                                class="cursor-pointer select-none py-2.5 text-right text-[11px] font-semibold uppercase tracking-wide transition-colors hover:opacity-70"
                                style="color: var(--ink-faint)"
                                @click="sortBy('reach_views_ads_spend')"
                            >
                                Reach/Views Ads ({{ activeCurrency }})<span v-if="sortKey === 'reach_views_ads_spend'" class="ml-0.5">{{ sortDir === 'asc' ? '↑' : '↓' }}</span>
                            </th>
                            <th
                                class="cursor-pointer select-none py-2.5 text-right text-[11px] font-semibold uppercase tracking-wide transition-colors hover:opacity-70"
                                style="color: var(--ink-faint)"
                                @click="sortBy('engagement_ads_spend')"
                            >
                                Engagement Ads ({{ activeCurrency }})<span v-if="sortKey === 'engagement_ads_spend'" class="ml-0.5">{{ sortDir === 'asc' ? '↑' : '↓' }}</span>
                            </th>
                            <th
                                class="cursor-pointer select-none py-2.5 pr-1 text-right text-[11px] font-semibold uppercase tracking-wide transition-colors hover:opacity-70"
                                style="color: var(--ink-faint)"
                                @click="sortBy('total_ads_spend')"
                            >
                                Total Ads Spend ({{ activeCurrency }})<span v-if="sortKey === 'total_ads_spend'" class="ml-0.5">{{ sortDir === 'asc' ? '↑' : '↓' }}</span>
                            </th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr
                            v-for="(row, index) in sortedRows"
                            :key="row.account_id"
                            :style="
                                isRanked && index === 0
                                    ? `border-bottom: 1px solid var(--border); background-color: var(--accent-soft)`
                                    : 'border-bottom: 1px solid var(--border)'
                            "
                        >
                            <td class="py-3 pr-2">
                                <span
                                    v-if="isRanked && index < 3"
                                    class="inline-flex h-6 w-6 items-center justify-center rounded-full text-xs font-bold"
                                    :style="[
                                        index === 0
                                            ? 'background-color: var(--status-cukup-bg); color: var(--status-cukup-ink)'
                                            : index === 1
                                            ? 'background-color: var(--surface); color: var(--ink-muted)'
                                            : 'background-color: var(--status-kurang-bg); color: var(--status-kurang-ink)',
                                    ]"
                                >
                                    {{ index + 1 }}
                                </span>
                                <span v-else class="pl-1.5 text-sm tabular-nums" style="color: var(--ink-faint)">
                                    {{ index + 1 }}
                                </span>
                            </td>
                            <td class="py-3 text-sm font-medium" style="color: var(--ink)">
                                {{ row.account_name }}
                            </td>
                            <td class="py-3 text-right text-sm tabular-nums" style="color: var(--ink-muted)">
                                {{ formatNumber(row.reach_views_ads_spend) }}
                            </td>
                            <td class="py-3 text-right text-sm tabular-nums" style="color: var(--ink-muted)">
                                {{ formatNumber(row.engagement_ads_spend) }}
                            </td>
                            <td class="py-3 pr-1 text-right text-sm font-semibold tabular-nums" style="color: var(--ink)">
                                {{ formatNumber(row.total_ads_spend) }}
                            </td>
                        </tr>
                        <tr v-if="sortedRows.length === 0">
                            <td colspan="5" class="py-12 text-center text-sm" style="color: var(--ink-faint)">
                                No accounts with ads spend recorded for this range.
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</template>
