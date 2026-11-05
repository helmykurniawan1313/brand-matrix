<script setup>
import { useAuth } from '../composables/useAuth';
import { useEscapeKey } from '../composables/useEscapeKey';

const props = defineProps({
    report: {
        type: Object,
        required: true,
    },
});

const emit = defineEmits(['close', 'edit']);
useEscapeKey(true, () => emit('close'));

const { canEdit } = useAuth();

const platformLabels = { instagram: 'Instagram', tiktok: 'TikTok' };

const formatDate = (value) => {
    const date = new Date(`${value.slice(0, 10)}T00:00:00`);
    return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
};

const formatNumber = (value) => (value === null || value === undefined ? '—' : Number(value).toLocaleString());

const metricRows = [
    { key: 'follower_count', label: 'Followers' },
    { key: 'reach', label: 'Reach' },
    { key: 'views', label: 'Views' },
    { key: 'profile_visits', label: 'Profile visits' },
    { key: 'link_clicks', label: 'Link clicks' },
    { key: 'engagement', label: 'Engagement' },
];
</script>

<template>
    <div
        class="fixed inset-0 z-10 flex items-center justify-center bg-black/50 px-4 backdrop-blur-sm"
        @click.self="emit('close')"
    >
        <div
            class="max-h-[85vh] w-full max-w-lg overflow-y-auto rounded-lg border p-6 shadow-2xl"
            style="background-color: var(--surface-raised); border-color: var(--border)"
        >
            <div class="flex items-start justify-between gap-4">
                <div>
                    <h2 class="font-display text-lg font-bold" style="color: var(--ink)">
                        {{ report.account?.name ?? '—' }}
                    </h2>
                    <p class="mt-0.5 text-sm" style="color: var(--ink-muted)">
                        {{ formatDate(report.week_start_date) }} – {{ formatDate(report.week_end_date) }}
                    </p>
                    <p class="mt-0.5 text-xs capitalize" style="color: var(--ink-faint)">
                        {{ platformLabels[report.platform] ?? report.platform }}
                    </p>
                </div>
                <div class="flex shrink-0 items-center gap-1">
                    <button
                        v-if="canEdit"
                        type="button"
                        class="flex h-8 w-8 items-center justify-center rounded-md transition-colors hover:opacity-70"
                        style="color: var(--ink-muted)"
                        aria-label="Edit"
                        @click="emit('edit', report)"
                    >
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-5 w-5">
                            <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7" />
                            <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5Z" />
                        </svg>
                    </button>
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

            <!-- Raw weekly metrics — no scoring, matches this feature's "raw numbers
                 only" design (see CLAUDE.md). -->
            <div class="mt-6 grid grid-cols-2 gap-3 sm:grid-cols-3">
                <div
                    v-for="row in metricRows"
                    :key="row.key"
                    class="rounded-lg border p-3"
                    style="border-color: var(--border); background-color: var(--surface)"
                >
                    <p class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">
                        {{ row.label }}
                    </p>
                    <p class="mt-1 font-display text-lg font-bold tabular-nums" style="color: var(--ink)">
                        {{ formatNumber(report[row.key]) }}
                    </p>
                </div>
            </div>
        </div>
    </div>
</template>
