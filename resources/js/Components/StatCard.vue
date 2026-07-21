<script setup>
defineProps({
    label: { type: String, required: true },
    value: { type: String, required: true },
    hint: { type: String, default: null },
});
</script>

<template>
    <div class="rounded-lg border p-4" style="background-color: var(--surface); border-color: var(--border)">
        <p class="text-xs font-medium uppercase tracking-wide" style="color: var(--ink-faint)">{{ label }}</p>
        <p class="mt-1.5 font-display text-2xl font-bold tabular-nums" style="color: var(--ink)">{{ value }}</p>
        <p v-if="hint" class="mt-0.5 text-xs" style="color: var(--ink-muted)">{{ hint }}</p>
    </div>
</template>
