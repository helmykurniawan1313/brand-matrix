<script setup>
import { computed } from 'vue';
import { usePage, Link } from '@inertiajs/vue3';
import { resolveBucketColor } from '../utils/bucketColor';

const props = defineProps({
    // Which LabelBucket metrics this table's badges can show, in display
    // order — e.g. ['health', 'account_growth', 'reach_change', 'views_change',
    // 'engagement_change']. See app/Models/LabelBucket.php METRICS for the
    // full list of valid keys.
    metrics: {
        type: Array,
        required: true,
    },
});

const emit = defineEmits(['close']);

const page = usePage();

const metricLabels = {
    growth: 'Growth',
    visibility: 'Visibility',
    engagement: 'Engagement',
    health: 'Health',
    views: 'Views',
    followers: 'Followers',
    account_growth: 'Follower Growth',
    views_change: 'Views (vs. last cycle)',
    reach_change: 'Reach (vs. last cycle)',
    engagement_change: 'Engagement (vs. last cycle)',
};

const formatNumber = (value) => {
    const n = Number(value);
    return Math.abs(n) >= 1000 ? new Intl.NumberFormat('en-US', { notation: 'compact' }).format(n) : n;
};

// The floor tier (min_score = null, e.g. Kurang) has no lower bound — it
// catches everything below the next-best tier, including negative values.
// Showing it as "≥ 0" would wrongly tie it with a tier that starts AT 0, so
// it's displayed as "< {next tier's threshold}" instead, using whichever
// tier sits directly above it in this same ladder.
const formatTier = (tier, nextBest) => {
    if (tier.min_score === null || tier.min_score === undefined) {
        return nextBest ? `< ${formatNumber(nextBest.min_score ?? 0)}` : 'any value';
    }
    return `≥ ${formatNumber(tier.min_score)}`;
};

const tierTone = (bucket, index) => resolveBucketColor(bucket, index);

// One ladder per metric, best-to-worst by min_score — mirrors the same
// ranking StatusBadge/Settings/Buckets use, so what's shown here always
// matches the colors/order badges actually render with.
const ladders = computed(() => {
    const labelBuckets = page.props.labelBuckets ?? [];

    return props.metrics
        .map((metric) => ({
            metric,
            title: metricLabels[metric] ?? metric,
            tiers: labelBuckets
                .filter((b) => b.metric === metric)
                .sort((a, b) => (b.min_score ?? -Infinity) - (a.min_score ?? -Infinity)),
        }))
        .filter((ladder) => ladder.tiers.length > 0);
});
</script>

<template>
    <div class="fixed inset-0 z-10 flex items-center justify-center bg-black/50 px-4 backdrop-blur-sm">
        <div
            class="flex max-h-[85vh] w-full max-w-lg flex-col overflow-hidden rounded-xl border shadow-2xl"
            style="background-color: var(--surface-raised); border-color: var(--border)"
        >
            <div class="flex shrink-0 items-start justify-between gap-4 border-b px-6 py-5" style="border-color: var(--border)">
                <div>
                    <h2 class="font-display text-lg font-bold" style="color: var(--ink)">How these statuses are scored</h2>
                    <p class="mt-0.5 text-sm" style="color: var(--ink-muted)">
                        Each label's threshold, best to worst. Set in Scoring Buckets.
                    </p>
                </div>
                <button
                    type="button"
                    class="flex h-8 w-8 shrink-0 items-center justify-center rounded-md transition-colors hover:opacity-70"
                    style="color: var(--ink-muted)"
                    aria-label="Close"
                    @click="emit('close')"
                >
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-5 w-5">
                        <path d="M18 6 6 18M6 6l12 12" />
                    </svg>
                </button>
            </div>

            <div class="min-h-0 flex-1 overflow-y-auto px-6 py-5">
                <div v-for="(ladder, i) in ladders" :key="ladder.metric" :class="i > 0 ? 'mt-5 border-t pt-5' : ''" :style="i > 0 ? 'border-color: var(--border)' : ''">
                    <p class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">{{ ladder.title }}</p>
                    <ul class="mt-2 space-y-1.5">
                        <li
                            v-for="(tier, j) in ladder.tiers"
                            :key="tier.id"
                            class="flex items-center justify-between gap-2 text-sm"
                        >
                            <span class="flex items-center gap-2">
                                <span class="h-2 w-2 shrink-0 rounded-full" :style="`background-color: ${tierTone(tier, j).ink}`" />
                                <span style="color: var(--ink)">{{ tier.label }}</span>
                            </span>
                            <span class="tabular-nums" style="color: var(--ink-faint)">{{ formatTier(tier, ladder.tiers[j - 1]) }}</span>
                        </li>
                    </ul>
                </div>

                <p v-if="ladders.length === 0" class="py-8 text-center text-sm" style="color: var(--ink-faint)">
                    No scoring tiers configured yet.
                </p>
            </div>

            <div class="flex shrink-0 items-center justify-end border-t px-6 py-4" style="border-color: var(--border)">
                <Link
                    href="/score-buckets"
                    class="rounded-md px-4 py-2 text-sm font-semibold transition-opacity hover:opacity-90"
                    style="background-color: var(--accent); color: var(--accent-ink)"
                >
                    Edit in Scoring Buckets
                </Link>
            </div>
        </div>
    </div>
</template>
