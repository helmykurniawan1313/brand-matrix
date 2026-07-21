<script setup>
import { useToast } from '../composables/useToast';

const { toasts, dismiss } = useToast();
</script>

<template>
    <div class="pointer-events-none fixed bottom-4 right-4 z-50 flex flex-col gap-2">
        <TransitionGroup name="toast">
            <div
                v-for="toast in toasts"
                :key="toast.id"
                class="pointer-events-auto flex min-w-[260px] max-w-sm items-start gap-2.5 rounded-md border px-4 py-3 shadow-lg"
                :style="
                    toast.type === 'error'
                        ? 'background-color: var(--status-parah-bg); border-color: var(--status-parah-ink); color: var(--status-parah-ink)'
                        : 'background-color: var(--status-sip-bg); border-color: var(--status-sip-ink); color: var(--status-sip-ink)'
                "
            >
                <svg v-if="toast.type === 'error'" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="mt-0.5 h-4 w-4 shrink-0">
                    <circle cx="12" cy="12" r="10" />
                    <path d="M12 8v4M12 16h.01" />
                </svg>
                <svg v-else xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="mt-0.5 h-4 w-4 shrink-0">
                    <path d="M20 6 9 17l-5-5" />
                </svg>
                <p class="flex-1 text-sm font-medium">{{ toast.message }}</p>
                <button
                    type="button"
                    class="shrink-0 transition-opacity hover:opacity-70"
                    aria-label="Dismiss"
                    @click="dismiss(toast.id)"
                >
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-4 w-4">
                        <path d="M18 6 6 18M6 6l12 12" />
                    </svg>
                </button>
            </div>
        </TransitionGroup>
    </div>
</template>

<style scoped>
.toast-enter-active,
.toast-leave-active {
    transition: all 0.2s ease;
}
.toast-enter-from {
    opacity: 0;
    transform: translateX(20px);
}
.toast-leave-to {
    opacity: 0;
    transform: translateX(20px);
}
</style>
