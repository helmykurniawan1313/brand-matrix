<script setup>
import AppLayout from '../../Layouts/AppLayout.vue';

defineOptions({ layout: AppLayout });
</script>

<template>
    <h1 class="font-display text-2xl font-bold tracking-tight" style="color: var(--ink)">Views Trackers</h1>
    <p class="mt-1 text-sm" style="color: var(--ink-muted)">
        Track views performance over time.
    </p>

    <div
        class="mt-8 flex flex-col items-center gap-2 rounded-xl border border-dashed p-14 text-center"
        style="border-color: var(--border-strong)"
    >
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" class="h-8 w-8" style="color: var(--ink-faint)">
            <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" />
            <circle cx="12" cy="12" r="3" />
        </svg>
        <p class="text-sm font-medium" style="color: var(--ink)">Nothing here yet</p>
        <p class="text-xs" style="color: var(--ink-faint)">This page is a placeholder — content is coming soon.</p>
    </div>
</template>
