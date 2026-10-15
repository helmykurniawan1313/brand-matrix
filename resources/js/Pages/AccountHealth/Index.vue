<script setup>
import { computed, ref } from 'vue';
import { Link, router } from '@inertiajs/vue3';
import AppLayout from '../../Layouts/AppLayout.vue';
import AccountGrowthModal from '../../Components/AccountGrowthModal.vue';
import StatusBadge from '../../Components/StatusBadge.vue';
import SearchableSelect from '../../Components/SearchableSelect.vue';
import StatCard from '../../Components/StatCard.vue';
import ScoringInfoModal from '../../Components/ScoringInfoModal.vue';

defineOptions({ layout: AppLayout });

const props = defineProps({
    accounts: {
        type: Object,
        required: true,
    },
    summary: {
        type: Object,
        default: () => ({ total: 0, at_risk: 0, improving: 0 }),
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
});

// --- Search / PM filter — same convention as Accounts/Index.vue.
const search = ref(props.filters.search ?? '');
const pmFilter = ref(props.filters.project_manager_id ? Number(props.filters.project_manager_id) : '');
let searchTimeout = null;

const applySearch = () => {
    router.get(
        '/account-health',
        {
            search: search.value || undefined,
            project_manager_id: pmFilter.value || undefined,
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

const hasActiveFilters = computed(() => !!search.value || !!pmFilter.value);
const clearAllFilters = () => {
    search.value = '';
    pmFilter.value = '';
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
            <h1 class="font-display text-2xl font-bold tracking-tight" style="color: var(--ink)">Account Health</h1>
            <p class="mt-1 text-sm" style="color: var(--ink-muted)">
                How healthy each account is right now, based on its latest cycle — a current LEVEL, not a trend.
                For whether accounts are improving or declining, see
                <Link href="/account-growth" class="font-medium underline" style="color: var(--accent)">Account Growth</Link>.
            </p>
        </div>
    </div>

    <div class="mt-6 grid grid-cols-2 gap-3 sm:grid-cols-3">
        <StatCard label="Total Accounts" :value="String(summary.total)" />
        <StatCard label="Needs Attention" :value="String(summary.at_risk)" hint="Health is KURANG or PARAH" />
        <StatCard label="In Good Standing" :value="String(summary.total - summary.at_risk)" hint="Health is SIP, BAGUS, or CUKUP" />
    </div>

    <!-- Toolbar: search + PM filter -->
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
                        <th class="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Account / Platform</th>
                        <th class="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Latest Cycle</th>
                        <th class="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Health Score</th>
                        <th class="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Health</th>
                        <th class="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Visibility</th>
                        <th class="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Engagement</th>
                        <th class="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">PM</th>
                    </tr>
                </thead>
                <tbody v-for="account in accounts.data" :key="account.id">
                    <!-- Account group header — not clickable itself when it has
                         multiple platforms (ambiguous which to drill into);
                         single-platform accounts open the modal directly. -->
                    <tr
                        class="transition-colors"
                        :class="account.platforms.length <= 1 ? 'cursor-pointer hover:bg-[var(--bg)]' : ''"
                        style="border-top: 1px solid var(--border); background-color: var(--bg)"
                        @click="account.platforms.length <= 1 && openGrowth(account)"
                    >
                        <td class="px-4 py-2.5 text-sm font-semibold" style="color: var(--ink)" :colspan="account.platforms.length > 1 ? 7 : 1">
                            {{ account.name }}
                        </td>
                        <template v-if="account.platforms.length <= 1">
                            <td class="px-4 py-2.5 text-sm" style="color: var(--ink-muted)">{{ account.platforms[0]?.latest_cycle_label ?? '—' }}</td>
                            <td class="px-4 py-2.5 text-sm tabular-nums" style="color: var(--ink)">
                                <span v-if="account.platforms[0]?.health_score != null">{{ account.platforms[0].health_score }}</span>
                                <span v-else style="color: var(--ink-faint)">—</span>
                            </td>
                            <td class="px-4 py-2.5 text-sm">
                                <StatusBadge v-if="account.platforms[0]" :status="account.platforms[0].health_label" />
                                <span v-else style="color: var(--ink-faint)">No data</span>
                            </td>
                            <td class="px-4 py-2.5 text-sm tabular-nums" style="color: var(--ink-muted)">
                                <span v-if="account.platforms[0]?.visibility_rate != null">{{ account.platforms[0].visibility_rate }}</span>
                                <span v-else style="color: var(--ink-faint)">—</span>
                            </td>
                            <td class="px-4 py-2.5 text-sm tabular-nums" style="color: var(--ink-muted)">
                                <span v-if="account.platforms[0]?.engagement_score != null">{{ account.platforms[0].engagement_score }}</span>
                                <span v-else style="color: var(--ink-faint)">—</span>
                            </td>
                            <td class="px-4 py-2.5 text-sm" style="color: var(--ink-muted)">{{ account.project_manager?.name ?? '—' }}</td>
                        </template>
                    </tr>

                    <!-- Platform sub-rows — only rendered when there's more than
                         one, so a single-platform account stays a flat one-row
                         entry instead of an unnecessary extra indent level. -->
                    <tr
                        v-if="account.platforms.length > 1"
                        v-for="platform in account.platforms"
                        :key="platform.platform"
                        class="cursor-pointer transition-colors hover:bg-[var(--bg)]"
                        style="border-bottom: 1px solid var(--border)"
                        @click="openGrowth(account)"
                    >
                        <td class="py-2.5 pl-10 pr-4 text-sm" style="color: var(--ink-muted)">
                            <span class="mr-1.5 inline-block w-5 rounded px-1 py-0.5 text-center text-[10px] font-bold uppercase" style="background-color: var(--accent-soft); color: var(--accent)">
                                {{ platform.platform === 'tiktok' ? 'TT' : 'IG' }}
                            </span>
                        </td>
                        <td class="px-4 py-2.5 text-sm" style="color: var(--ink-muted)">{{ platform.latest_cycle_label ?? '—' }}</td>
                        <td class="px-4 py-2.5 text-sm tabular-nums" style="color: var(--ink)">
                            <span v-if="platform.health_score != null">{{ platform.health_score }}</span>
                            <span v-else style="color: var(--ink-faint)">—</span>
                        </td>
                        <td class="px-4 py-2.5 text-sm">
                            <StatusBadge :status="platform.health_label" />
                        </td>
                        <td class="px-4 py-2.5 text-sm tabular-nums" style="color: var(--ink-muted)">
                            <span v-if="platform.visibility_rate != null">{{ platform.visibility_rate }}</span>
                            <span v-else style="color: var(--ink-faint)">—</span>
                        </td>
                        <td class="px-4 py-2.5 text-sm tabular-nums" style="color: var(--ink-muted)">
                            <span v-if="platform.engagement_score != null">{{ platform.engagement_score }}</span>
                            <span v-else style="color: var(--ink-faint)">—</span>
                        </td>
                        <td class="px-4 py-2.5 text-sm" style="color: var(--ink-muted)">{{ account.project_manager?.name ?? '—' }}</td>
                    </tr>
                </tbody>
                <tbody v-if="accounts.data.length === 0">
                    <tr>
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
        :metrics="['health']"
        @close="showScoringInfo = false"
    />
</template>
