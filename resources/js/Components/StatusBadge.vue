<script setup>
import { computed } from 'vue';
import { usePage } from '@inertiajs/vue3';
import { resolveBucketColor } from '../utils/bucketColor';

const props = defineProps({
    status: {
        type: String,
        default: null,
    },
});

const page = usePage();

// Label buckets are user-configurable text (e.g. Performance's Views status
// uses Title Case "Parah"/"Bagus" while Cycles' health labels are uppercase
// "PARAH"/"BAGUS") — match case-insensitively so both render with real colors.
// Color now comes from the matching LabelBucket's own stored `color`
// (set in Settings → Score Buckets), not a hardcoded label-text map, so a
// renamed or recolored label stays correct everywhere it's shown.
const tone = computed(() => {
    const labelBuckets = page.props.labelBuckets ?? [];
    const statusUpper = props.status?.toUpperCase();
    if (!statusUpper) return { bg: 'var(--border)', ink: 'var(--ink-muted)' };

    // Buckets for whichever metric the matching label belongs to, ranked
    // best-to-worst by min_score, so an unmigrated/colorless bucket still
    // gets a sensible rank-based fallback tone instead of always gray.
    const match = labelBuckets.find((b) => b.label?.toUpperCase() === statusUpper);
    if (!match) return { bg: 'var(--border)', ink: 'var(--ink-muted)' };

    const siblings = labelBuckets
        .filter((b) => b.metric === match.metric)
        .sort((a, b) => (b.min_score ?? -Infinity) - (a.min_score ?? -Infinity));
    const rank = siblings.findIndex((b) => b.id === match.id);

    return resolveBucketColor(match, Math.max(rank, 0));
});
</script>

<template>
    <span
        class="inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-xs font-semibold"
        :style="`background-color: ${tone.bg}; color: ${tone.ink}`"
    >
        <span class="h-1.5 w-1.5 rounded-full" :style="`background-color: ${tone.ink}`" />
        {{ status ?? 'No data' }}
    </span>
</template>
