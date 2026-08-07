<script setup>
import { computed } from 'vue';

const props = defineProps({
    status: {
        type: String,
        default: null,
    },
});

// Label buckets are user-configurable text (e.g. Performance's Views status
// uses Title Case "Parah"/"Bagus" while Cycles' health labels are uppercase
// "PARAH"/"BAGUS") — match case-insensitively so both render with real colors.
const tone = computed(
    () =>
        ({
            SIP: { bg: 'var(--status-sip-bg)', ink: 'var(--status-sip-ink)' },
            BAGUS: { bg: 'var(--status-bagus-bg)', ink: 'var(--status-bagus-ink)' },
            CUKUP: { bg: 'var(--status-cukup-bg)', ink: 'var(--status-cukup-ink)' },
            KURANG: { bg: 'var(--status-kurang-bg)', ink: 'var(--status-kurang-ink)' },
            PARAH: { bg: 'var(--status-parah-bg)', ink: 'var(--status-parah-ink)' },
        })[props.status?.toUpperCase()] ?? { bg: 'var(--border)', ink: 'var(--ink-muted)' },
);
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
