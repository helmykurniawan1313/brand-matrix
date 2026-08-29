<script setup>
import { ref } from 'vue';
import { router } from '@inertiajs/vue3';
import AppLayout from '../../Layouts/AppLayout.vue';
import { useToast } from '../../composables/useToast';

defineOptions({ layout: AppLayout });

const toast = useToast();

const props = defineProps({
    maintenanceMode: {
        type: Boolean,
        required: true,
    },
});

const maintenanceMode = ref(props.maintenanceMode);
const saving = ref(false);

const toggle = () => {
    const next = !maintenanceMode.value;
    saving.value = true;

    router.put(
        '/settings/site',
        { maintenance_mode: next },
        {
            preserveScroll: true,
            onSuccess: () => {
                maintenanceMode.value = next;
                toast.success(next ? 'Maintenance mode turned on.' : 'Maintenance mode turned off.');
            },
            onError: () => toast.error('Failed to update maintenance mode.'),
            onFinish: () => {
                saving.value = false;
            },
        },
    );
};
</script>

<template>
    <div>
        <h1 class="font-display text-2xl font-bold tracking-tight" style="color: var(--ink)">Site Settings</h1>
        <p class="mt-1 text-sm" style="color: var(--ink-muted)">Controls that affect the whole site for every user.</p>
    </div>

    <div class="mt-6 max-w-xl rounded-lg border p-5" style="border-color: var(--border); background-color: var(--surface)">
        <div class="flex items-start justify-between gap-4">
            <div>
                <p class="text-sm font-semibold" style="color: var(--ink)">Under Construction Mode</p>
                <p class="mt-1 text-sm" style="color: var(--ink-muted)">
                    When on, everyone except super admins sees an under-construction page instead of the app.
                    You'll always be able to sign in and use the site normally to turn this back off.
                </p>
            </div>

            <button
                type="button"
                role="switch"
                :aria-checked="maintenanceMode"
                :disabled="saving"
                class="relative inline-flex h-6 w-11 shrink-0 items-center rounded-full transition-colors disabled:opacity-50"
                :style="maintenanceMode ? 'background-color: var(--accent)' : 'background-color: var(--border-strong)'"
                @click="toggle"
            >
                <span
                    class="inline-block h-4 w-4 transform rounded-full bg-white transition-transform"
                    :style="maintenanceMode ? 'transform: translateX(1.375rem)' : 'transform: translateX(0.25rem)'"
                />
            </button>
        </div>

        <div
            v-if="maintenanceMode"
            class="mt-4 flex items-center gap-2 rounded-md border p-3 text-sm"
            style="border-color: var(--status-kurang-ink); background-color: var(--status-kurang-bg); color: var(--status-kurang-ink)"
        >
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-4 w-4 shrink-0">
                <path d="M12 9v4m0 4h.01M10.29 3.86 1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0Z" />
            </svg>
            The site is currently showing the under-construction page to everyone but super admins.
        </div>
    </div>
</template>
