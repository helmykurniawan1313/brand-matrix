<script setup>
import { ref } from 'vue';

// Reusable "who edited what" collapsible timeline — fetched lazily on first
// expand (not eager-loaded with the rest of a detail view), since most
// opened records are never checked for history. Backs onto a GET {url}
// endpoint returning { logs: [{ id, action, changes, user_name, created_at }] }
// — see App\Models\Concerns\LogsActivity / each controller's activity()
// method (PerformanceController, CycleController, WeeklyReportController).
const props = defineProps({
    url: {
        type: String,
        required: true,
    },
    // metric/column key => human label, for rendering a changed field's name
    // instead of its raw database column (e.g. 'post_date' => 'Post date').
    fieldLabels: {
        type: Object,
        default: () => ({}),
    },
});

const open = ref(false);
const loading = ref(false);
const error = ref(null);
const logs = ref([]);
const loaded = ref(false);

// Date-cast fields come back as full ISO timestamps (e.g.
// "2026-11-12T00:00:00.000000Z") even though they're really just a date —
// detect that shape and render dd/mm/yyyy instead of the raw timestamp.
const isoDatePattern = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/;

const formatFieldValue = (value) => {
    if (value === null || value === undefined || value === '') return '—';
    if (Array.isArray(value)) return value.length ? value.join(', ') : '—';
    if (typeof value === 'boolean') return value ? 'Yes' : 'No';
    if (typeof value === 'string' && isoDatePattern.test(value)) {
        const [year, month, day] = value.slice(0, 10).split('-');
        return `${day}/${month}/${year}`;
    }
    return String(value);
};

const formatLogDate = (value) => new Date(value).toLocaleString('en-US', { month: 'short', day: 'numeric', year: 'numeric', hour: 'numeric', minute: '2-digit' });

const actionDotColor = (action) => {
    if (action === 'created') return 'var(--status-sip-ink)';
    if (action === 'deleted') return 'var(--status-parah-ink)';
    return 'var(--accent)';
};

const actionVerb = (action) => {
    if (action === 'created') return 'created';
    if (action === 'deleted') return 'deleted';
    return 'updated';
};

const toggle = async () => {
    open.value = !open.value;
    if (open.value && !loaded.value) {
        loading.value = true;
        error.value = null;
        try {
            const response = await fetch(props.url, { headers: { Accept: 'application/json' } });
            if (!response.ok) throw new Error('Failed to load activity.');
            const data = await response.json();
            logs.value = data.logs;
            loaded.value = true;
        } catch (e) {
            error.value = 'Failed to load activity history.';
        } finally {
            loading.value = false;
        }
    }
};
</script>

<template>
    <div class="mt-6 border-t pt-4" style="border-color: var(--border)">
        <button type="button" class="flex w-full items-center justify-between text-left" @click="toggle">
            <h3 class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Activity</h3>
            <svg
                xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                class="h-4 w-4 shrink-0 transition-transform"
                :class="{ 'rotate-180': open }"
                style="color: var(--ink-faint)"
            >
                <path d="m6 9 6 6 6-6" />
            </svg>
        </button>

        <div v-if="open" class="mt-4">
            <p v-if="loading" class="text-sm" style="color: var(--ink-faint)">Loading…</p>
            <p v-else-if="error" class="text-sm" style="color: var(--status-parah-ink)">{{ error }}</p>
            <p v-else-if="logs.length === 0" class="text-sm" style="color: var(--ink-faint)">No activity recorded.</p>

            <!-- Plain activity feed: a dot + connecting line down the left edge,
                 content flows directly beside it with no per-entry box — reads as
                 one continuous log, not a stack of cards. -->
            <ol v-else>
                <li
                    v-for="(log, i) in logs"
                    :key="log.id"
                    class="relative pl-5"
                    :class="i < logs.length - 1 ? 'pb-4' : ''"
                >
                    <span
                        class="absolute left-0 top-[5px] h-[7px] w-[7px] rounded-full"
                        :style="`background-color: ${actionDotColor(log.action)}`"
                    />
                    <span
                        v-if="i < logs.length - 1"
                        class="absolute left-[3px] top-3 bottom-0 w-px"
                        style="background-color: var(--border)"
                    />

                    <div class="flex flex-wrap items-baseline justify-between gap-x-3">
                        <p class="text-sm leading-snug" style="color: var(--ink)">
                            <span class="font-semibold">{{ log.user_name ?? 'System' }}</span>
                            {{ ' ' }}<span style="color: var(--ink-muted)">{{ actionVerb(log.action) }}</span>
                        </p>
                        <time class="shrink-0 text-xs tabular-nums" style="color: var(--ink-faint)">{{ formatLogDate(log.created_at) }}</time>
                    </div>

                    <div
                        v-if="log.action === 'updated' && log.changes"
                        class="mt-1.5 space-y-1"
                    >
                        <div
                            v-for="(change, field) in log.changes"
                            :key="field"
                            class="flex flex-wrap items-center gap-1.5 text-xs"
                        >
                            <span class="font-medium" style="color: var(--ink-muted)">{{ fieldLabels[field] ?? field }}</span>
                            <span
                                class="rounded px-1.5 py-0.5 line-through"
                                style="background-color: var(--status-parah-bg); color: var(--status-parah-ink)"
                            >
                                {{ formatFieldValue(change.old) }}
                            </span>
                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-3 w-3 shrink-0" style="color: var(--ink-faint)">
                                <path d="M5 12h14M13 6l6 6-6 6" />
                            </svg>
                            <span
                                class="rounded px-1.5 py-0.5 font-medium"
                                style="background-color: var(--status-sip-bg); color: var(--status-sip-ink)"
                            >
                                {{ formatFieldValue(change.new) }}
                            </span>
                        </div>
                    </div>
                </li>
            </ol>
        </div>
    </div>
</template>
