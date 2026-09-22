<script setup>
import { computed, ref } from 'vue';
import { useForm } from '@inertiajs/vue3';
import SearchableSelect from './SearchableSelect.vue';
import { useToast } from '../composables/useToast';

const props = defineProps({
    // Pass an existing row to edit; omit (null) to create a new one.
    insight: { type: Object, default: null },
    accounts: { type: Array, required: true },
});

const emit = defineEmits(['close', 'saved']);

const toast = useToast();
const isEdit = computed(() => !!props.insight);

const form = useForm({
    account_id: props.insight?.account_id ?? '',
    cycle_id: props.insight?.cycle_id ?? '',
    viewers_posts: props.insight?.viewers_posts ?? 0,
    viewers_reels: props.insight?.viewers_reels ?? 0,
    viewers_story: props.insight?.viewers_story ?? 0,
    interactions_posts: props.insight?.interactions_posts ?? 0,
    interactions_reels: props.insight?.interactions_reels ?? 0,
    interactions_story: props.insight?.interactions_story ?? 0,
});

// --- Dependent cycle select ---

// Compact range label — "28 Jul – 27 Aug 2026" (year shown once when both ends
// share it). Platform is surfaced separately as a tag, not crammed in here.
function cycleLabelFromRow(cycle) {
    const start = new Date(cycle.cycle_start_date);
    const end = new Date(cycle.cycle_end_date);
    const day = (d) => d.toLocaleDateString('en-GB', { day: '2-digit', month: 'short' });
    const year = (d) => d.getFullYear();

    return year(start) === year(end)
        ? `${day(start)} – ${day(end)} ${year(end)}`
        : `${day(start)} ${year(start)} – ${day(end)} ${year(end)}`;
}

const platformLabel = (p) => (p ? p.charAt(0).toUpperCase() + p.slice(1) : '');

const cycleOptions = ref(
    isEdit.value && props.insight.cycle
        ? [
              {
                  id: props.insight.cycle_id,
                  name: cycleLabelFromRow(props.insight.cycle),
                  platform: props.insight.cycle.platform,
              },
          ]
        : [],
);
const loadingCycles = ref(false);

const selectedCycle = computed(
    () => cycleOptions.value.find((c) => c.id === form.cycle_id) ?? null,
);

const onAccountChange = async () => {
    form.cycle_id = '';
    cycleOptions.value = [];
    if (!form.account_id) return;

    loadingCycles.value = true;
    try {
        const res = await fetch(`/accounts/${form.account_id}/insight-cycles`, {
            headers: { Accept: 'application/json' },
        });
        const data = await res.json();

        // Only tag options with their platform when this account actually mixes
        // platforms — otherwise the tag is just noise.
        const platforms = new Set(data.map((c) => c.platform).filter(Boolean));
        const mixed = platforms.size > 1;

        cycleOptions.value = data.map((c) => ({
            id: c.id,
            name: cycleLabelFromRow(c),
            platform: c.platform,
            badge: mixed && c.platform ? platformLabel(c.platform) : null,
        }));
    } catch {
        toast.error('Failed to load cycles for that account.');
    } finally {
        loadingCycles.value = false;
    }
};

const cyclePlaceholder = computed(() => {
    if (!form.account_id) return 'Pick an account first';
    if (loadingCycles.value) return 'Loading cycles…';
    return cycleOptions.value.length ? 'Select cycle' : 'No cycles for this account';
});

// --- Section model: drives both the Viewers and Interactions cards ---

const int = (v) => Math.max(0, Number(v) || 0);

const sections = computed(() => [
    {
        key: 'viewers',
        label: 'Viewers',
        hint: 'Views by content type',
        rows: [
            { key: 'posts', label: 'Posts', field: 'viewers_posts' },
            { key: 'reels', label: 'Reels', field: 'viewers_reels' },
            { key: 'story', label: 'Story', field: 'viewers_story' },
        ],
    },
    {
        key: 'interactions',
        label: 'Interactions',
        hint: 'Interactions by content type',
        rows: [
            { key: 'posts', label: 'Posts', field: 'interactions_posts' },
            { key: 'reels', label: 'Reels', field: 'interactions_reels' },
            { key: 'story', label: 'Story', field: 'interactions_story' },
        ],
    },
]);

const sectionTotal = (section) => section.rows.reduce((sum, r) => sum + int(form[r.field]), 0);

const rowShare = (section, row) => {
    const total = sectionTotal(section);
    if (!total) return 0;
    return (int(form[row.field]) / total) * 100;
};

const nf = (v) => Number(v || 0).toLocaleString('en-US');

// --- Submit ---

const submit = () => {
    const opts = {
        preserveScroll: true,
        onSuccess: () => emit('saved'),
        onError: () => toast.error('Failed to save. Check the fields.'),
    };

    if (isEdit.value) {
        form.put(`/content-insights/${props.insight.id}`, opts);
    } else {
        form.post('/content-insights', opts);
    }
};
</script>

<template>
    <div class="fixed inset-0 z-10 flex items-center justify-center bg-black/50 p-4 backdrop-blur-sm">
        <div
            class="flex max-h-[90vh] w-full max-w-2xl flex-col overflow-hidden rounded-2xl border shadow-2xl"
            style="background-color: var(--surface-raised); border-color: var(--border)"
        >
            <!-- Sticky header -->
            <div
                class="flex items-start justify-between gap-4 border-b px-6 py-5"
                style="border-color: var(--border)"
            >
                <div>
                    <h2 class="font-display text-lg font-bold" style="color: var(--ink)">
                        {{ isEdit ? 'Edit Content Insight' : 'Add Content Insight' }}
                    </h2>
                    <p class="mt-0.5 text-sm" style="color: var(--ink-muted)">
                        <template v-if="isEdit">
                            {{ insight.account?.name }}
                            <span v-if="insight.cycle"> · {{ cycleLabelFromRow(insight.cycle) }}</span>
                        </template>
                        <template v-else>
                            Type the numbers straight from the Instagram Insights "Overview" screen.
                        </template>
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

            <!-- Scrollable body -->
            <form id="content-insight-form" class="flex-1 space-y-5 overflow-y-auto px-6 py-5" @submit.prevent="submit">
                <!-- Context strip: account + cycle -->
                <div
                    v-if="!isEdit"
                    class="rounded-xl border p-4"
                    style="border-color: var(--border); background-color: var(--surface)"
                >
                    <div class="grid grid-cols-1 gap-x-4 gap-y-3 sm:grid-cols-2">
                        <div class="min-w-0">
                            <label class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Account</label>
                            <div class="mt-1.5">
                                <SearchableSelect
                                    v-model="form.account_id"
                                    :options="accounts"
                                    placeholder="Select account"
                                    @update:modelValue="onAccountChange"
                                />
                            </div>
                            <p v-if="form.errors.account_id" class="mt-1 text-sm" style="color: var(--status-parah-ink)">
                                {{ form.errors.account_id }}
                            </p>
                        </div>
                        <div class="min-w-0">
                            <label class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Cycle</label>
                            <div class="mt-1.5">
                                <SearchableSelect
                                    v-model="form.cycle_id"
                                    :options="cycleOptions"
                                    :placeholder="cyclePlaceholder"
                                />
                            </div>
                            <p v-if="form.errors.cycle_id" class="mt-1 text-sm" style="color: var(--status-parah-ink)">
                                {{ form.errors.cycle_id }}
                            </p>
                        </div>
                    </div>

                    <!-- Resolved selection summary — one clean line, platform as a tag -->
                    <p
                        v-if="selectedCycle"
                        class="mt-3 flex items-center gap-2 border-t pt-3 text-xs"
                        style="border-color: var(--border); color: var(--ink-muted)"
                    >
                        <span
                            v-if="selectedCycle.platform"
                            class="rounded px-1.5 py-0.5 text-[11px] font-semibold uppercase tracking-wide"
                            style="background-color: var(--accent-soft); color: var(--accent)"
                        >
                            {{ platformLabel(selectedCycle.platform) }}
                        </span>
                        <span class="tabular-nums">{{ selectedCycle.name }}</span>
                    </p>
                </div>

                <!-- Section cards: Viewers + Interactions -->
                <div
                    v-for="section in sections"
                    :key="section.key"
                    class="rounded-xl border p-4"
                    style="border-color: var(--border); background-color: var(--surface)"
                >
                    <div class="flex items-start justify-between gap-4">
                        <div>
                            <h3 class="text-sm font-semibold" style="color: var(--ink)">{{ section.label }}</h3>
                            <p class="text-xs" style="color: var(--ink-faint)">{{ section.hint }}</p>
                        </div>
                        <div class="text-right">
                            <p class="font-display text-2xl font-bold tabular-nums leading-none" style="color: var(--ink)">
                                {{ nf(sectionTotal(section)) }}
                            </p>
                            <p class="mt-1 text-[11px] uppercase tracking-wide" style="color: var(--ink-faint)">Total</p>
                        </div>
                    </div>

                    <div class="mt-4 space-y-3">
                        <div v-for="row in section.rows" :key="row.key">
                            <div class="flex items-center gap-3">
                                <label
                                    :for="`${section.key}-${row.key}`"
                                    class="w-16 shrink-0 text-sm font-medium"
                                    style="color: var(--ink-muted)"
                                >
                                    {{ row.label }}
                                </label>
                                <input
                                    :id="`${section.key}-${row.key}`"
                                    v-model="form[row.field]"
                                    type="number"
                                    min="0"
                                    inputmode="numeric"
                                    class="h-11 w-full rounded-lg border px-3 text-right text-base tabular-nums transition-colors focus:outline-none"
                                    style="border-color: var(--border); background-color: var(--surface-raised); color: var(--ink)"
                                />
                            </div>
                            <!-- proportion bar: each type's share of the section total -->
                            <div
                                class="mt-1.5 ml-[76px] h-1 overflow-hidden rounded-full"
                                style="background-color: var(--border)"
                            >
                                <div
                                    class="h-full rounded-full transition-all"
                                    :style="{ width: `${rowShare(section, row)}%`, backgroundColor: 'var(--accent)' }"
                                />
                            </div>
                        </div>
                    </div>
                </div>
            </form>

            <!-- Sticky footer -->
            <div
                class="flex items-center justify-end gap-2 border-t px-6 py-4"
                style="border-color: var(--border)"
            >
                <button
                    type="button"
                    class="rounded-md px-4 py-2 text-sm font-medium transition-colors hover:opacity-70"
                    style="color: var(--ink-muted)"
                    @click="emit('close')"
                >
                    Cancel
                </button>
                <button
                    type="submit"
                    form="content-insight-form"
                    :disabled="form.processing"
                    class="rounded-md px-5 py-2 text-sm font-semibold transition-opacity hover:opacity-90 disabled:opacity-50"
                    style="background-color: var(--accent); color: var(--accent-ink)"
                >
                    {{ isEdit ? 'Save changes' : 'Save insight' }}
                </button>
            </div>
        </div>
    </div>
</template>
