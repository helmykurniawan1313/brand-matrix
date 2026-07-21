<script setup>
defineProps({
    title: { type: String, required: true },
    subtitle: { type: String, default: null },
});
</script>

<template>
    <div class="flex min-h-screen items-center justify-center px-4" style="background-color: var(--bg)">
        <div class="w-full max-w-sm">
            <div class="mb-8 flex flex-col items-center text-center">
                <span
                    class="flex h-10 w-10 items-center justify-center rounded-md font-display text-base font-bold"
                    style="background-color: var(--accent); color: var(--accent-ink)"
                >
                    BM
                </span>
                <h1 class="mt-4 font-display text-xl font-bold tracking-tight" style="color: var(--ink)">
                    {{ title }}
                </h1>
                <p v-if="subtitle" class="mt-1 text-sm" style="color: var(--ink-muted)">
                    {{ subtitle }}
                </p>
            </div>

            <div
                class="rounded-lg border p-6 shadow-sm"
                style="background-color: var(--surface); border-color: var(--border)"
            >
                <slot />
            </div>
        </div>
    </div>
</template>
