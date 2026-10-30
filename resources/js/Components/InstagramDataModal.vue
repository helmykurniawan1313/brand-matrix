<script setup>
import { ref, reactive, computed } from 'vue';
import { useForm, router } from '@inertiajs/vue3';
import ConfirmDialog from './ConfirmDialog.vue';
import { useToast } from '../composables/useToast';
import { useAuth } from '../composables/useAuth';

const toast = useToast();
const { canEdit } = useAuth();

const props = defineProps({
    account: {
        type: Object,
        required: true,
    },
});

const emit = defineEmits(['close']);

const isConnected = computed(() => !!props.account.ig_business_id);

const connectForm = useForm({
    ig_business_id: '',
    ig_access_token: '',
});

const submitConnect = () => {
    connectForm.post(`/accounts/${props.account.id}/instagram/connect`, {
        preserveScroll: true,
        onSuccess: () => {
            connectForm.reset();
            toast.success('Instagram connected.');
            loadData();
        },
        onError: () => toast.error('Failed to connect Instagram.'),
    });
};

// Disconnect confirmation

const showDisconnectConfirm = ref(false);
const disconnecting = ref(false);

const confirmDisconnect = () => {
    showDisconnectConfirm.value = true;
};

const cancelDisconnect = () => {
    showDisconnectConfirm.value = false;
};

const disconnect = () => {
    disconnecting.value = true;

    router.delete(`/accounts/${props.account.id}/instagram/disconnect`, {
        preserveScroll: true,
        onSuccess: () => {
            data.profile = null;
            toast.success('Instagram disconnected.');
            showDisconnectConfirm.value = false;
        },
        onError: () => toast.error('Failed to disconnect Instagram.'),
        onFinish: () => {
            disconnecting.value = false;
        },
    });
};

const loading = ref(false);
const error = ref(null);
const data = reactive({
    profile: null,
    daily_insights: [],
    media: [],
});

const loadData = async () => {
    loading.value = true;
    error.value = null;

    try {
        const res = await fetch(`/accounts/${props.account.id}/instagram`, {
            headers: { Accept: 'application/json' },
        });
        const body = await res.json();

        if (!res.ok) {
            error.value = body.message ?? 'Failed to load Instagram data.';
            return;
        }

        data.profile = body.profile;
        data.daily_insights = body.daily_insights;
        data.media = body.media;
    } catch (e) {
        error.value = 'Network error while loading Instagram data.';
    } finally {
        loading.value = false;
    }
};

if (isConnected.value) {
    loadData();
}

// Bulk import from Meta Business Suite's daily export CSVs

const importFields = [
    { key: 'follows', label: 'Follows' },
    { key: 'viewers', label: 'Viewers' },
    { key: 'views', label: 'Views' },
    { key: 'interactions', label: 'Interactions' },
    { key: 'visits', label: 'Visits' },
    { key: 'link_clicks', label: 'Link clicks' },
];

const importFiles = reactive({
    follows: null,
    viewers: null,
    views: null,
    interactions: null,
    visits: null,
    link_clicks: null,
});

const startingFollowers = ref('');
const importing = ref(false);
const importError = ref(null);
const importResult = ref(null);

const onImportFileChange = (key, event) => {
    importFiles[key] = event.target.files?.[0] ?? null;
};

const submitImport = async () => {
    const chosen = Object.entries(importFiles).filter(([, file]) => file);

    if (chosen.length === 0) {
        importError.value = 'Choose at least one Meta export file.';
        return;
    }

    importing.value = true;
    importError.value = null;
    importResult.value = null;

    const formData = new FormData();
    chosen.forEach(([key, file]) => formData.append(key, file));
    if (startingFollowers.value !== '') {
        formData.append('starting_followers', startingFollowers.value);
    }

    try {
        const res = await fetch(`/accounts/${props.account.id}/instagram/import`, {
            method: 'POST',
            headers: {
                Accept: 'application/json',
                'X-XSRF-TOKEN': decodeURIComponent(document.cookie.match(/XSRF-TOKEN=([^;]+)/)?.[1] ?? ''),
            },
            body: formData,
        });
        const body = await res.json();

        if (!res.ok) {
            importError.value = body.message ?? 'Import failed.';
            return;
        }

        importResult.value = body;
        toast.success(`Imported ${body.dates_imported} day(s) of data.`);

        Object.keys(importFiles).forEach((key) => (importFiles[key] = null));
        document.querySelectorAll('[data-meta-import-input]').forEach((el) => (el.value = ''));

        if (isConnected.value) {
            loadData();
        }
    } catch (e) {
        importError.value = 'Network error while importing.';
    } finally {
        importing.value = false;
    }
};

const expandedMediaId = ref(null);
const mediaInsightsLoading = ref(null);
const mediaInsightsError = reactive({});
const mediaInsightsCache = reactive({});

const toggleMediaInsights = async (item) => {
    if (expandedMediaId.value === item.id) {
        expandedMediaId.value = null;
        return;
    }

    expandedMediaId.value = item.id;

    if (mediaInsightsCache[item.id]) {
        return;
    }

    mediaInsightsLoading.value = item.id;
    mediaInsightsError[item.id] = null;

    try {
        const params = new URLSearchParams({
            media_id: item.id,
            media_product_type: item.media_product_type,
        });
        const res = await fetch(`/accounts/${props.account.id}/instagram/media-insights?${params}`, {
            headers: { Accept: 'application/json' },
        });
        const body = await res.json();

        if (!res.ok) {
            mediaInsightsError[item.id] = body.message ?? 'Failed to load post insights.';
            return;
        }

        mediaInsightsCache[item.id] = body.insights;
    } catch (e) {
        mediaInsightsError[item.id] = 'Network error while loading post insights.';
    } finally {
        mediaInsightsLoading.value = null;
    }
};
</script>

<template>
    <div class="fixed inset-0 z-50 flex items-center justify-center p-4" style="background-color: rgba(0, 0, 0, 0.5)">
        <div
            class="max-h-[85vh] w-full max-w-2xl overflow-y-auto rounded-lg border p-6"
            style="border-color: var(--border); background-color: var(--surface)"
        >
            <div class="flex items-start justify-between">
                <div>
                    <h2 class="font-display text-lg font-bold" style="color: var(--ink)">Instagram — {{ account.name }}</h2>
                    <p class="mt-1 text-sm" style="color: var(--ink-muted)">
                        {{ isConnected ? `Connected as @${account.ig_username ?? '...'}` : 'Not connected yet' }}
                    </p>
                </div>
                <button class="text-sm font-medium" style="color: var(--ink-muted)" @click="emit('close')">✕</button>
            </div>

            <div v-if="!isConnected" class="mt-6 space-y-6">
                <p v-if="!canEdit" class="text-sm" style="color: var(--ink-faint)">
                    You don't have permission to connect Instagram for this account.
                </p>
                <template v-else>
                    <div>
                        <a
                            :href="`/accounts/${account.id}/instagram/oauth/redirect`"
                            class="inline-block rounded-md px-4 py-2 text-sm font-semibold transition-opacity hover:opacity-90"
                            style="background-color: var(--accent); color: var(--accent-ink)"
                        >
                            Login with Instagram
                        </a>
                        <p class="mt-2 text-xs" style="color: var(--ink-faint)">
                            Redirects to Instagram to authorize read-only access, then returns here connected.
                        </p>
                    </div>

                    <details>
                        <summary class="cursor-pointer text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">
                            Or connect manually with an existing token
                        </summary>
                        <form @submit.prevent="submitConnect" class="mt-3 space-y-3">
                            <div>
                                <label class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">
                                    Instagram Business ID
                                </label>
                                <input
                                    v-model="connectForm.ig_business_id"
                                    type="text"
                                    placeholder="e.g. 27350904627911625"
                                    class="mt-1 w-full rounded-md border px-3 py-2 text-sm"
                                    style="border-color: var(--border); background-color: var(--bg); color: var(--ink)"
                                />
                                <p v-if="connectForm.errors.ig_business_id" class="mt-1 text-sm" style="color: var(--status-parah-ink)">
                                    {{ connectForm.errors.ig_business_id }}
                                </p>
                            </div>
                            <div>
                                <label class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">
                                    Access Token
                                </label>
                                <input
                                    v-model="connectForm.ig_access_token"
                                    type="password"
                                    placeholder="IGAAR..."
                                    class="mt-1 w-full rounded-md border px-3 py-2 text-sm"
                                    style="border-color: var(--border); background-color: var(--bg); color: var(--ink)"
                                />
                                <p v-if="connectForm.errors.ig_access_token" class="mt-1 text-sm" style="color: var(--status-parah-ink)">
                                    {{ connectForm.errors.ig_access_token }}
                                </p>
                            </div>
                            <button
                                type="submit"
                                :disabled="connectForm.processing"
                                class="rounded-md border px-4 py-2 text-sm font-semibold transition-opacity hover:opacity-90 disabled:opacity-50"
                                style="border-color: var(--border); color: var(--ink)"
                            >
                                Connect manually
                            </button>
                        </form>
                    </details>
                </template>
            </div>

            <div v-else class="mt-6">
                <div v-if="loading" class="py-8 text-center text-sm" style="color: var(--ink-faint)">Loading Instagram data…</div>

                <div v-else-if="error" class="rounded-md border px-4 py-3 text-sm" style="border-color: var(--status-parah-ink); color: var(--status-parah-ink)">
                    {{ error }}
                </div>

                <div v-else-if="data.profile" class="space-y-6">
                    <div class="grid grid-cols-3 gap-3">
                        <div class="rounded-md border p-3 text-center" style="border-color: var(--border)">
                            <p class="text-xs uppercase tracking-wide" style="color: var(--ink-faint)">Followers</p>
                            <p class="mt-1 text-xl font-bold tabular-nums" style="color: var(--ink)">{{ data.profile.followers_count }}</p>
                        </div>
                        <div class="rounded-md border p-3 text-center" style="border-color: var(--border)">
                            <p class="text-xs uppercase tracking-wide" style="color: var(--ink-faint)">Media Count</p>
                            <p class="mt-1 text-xl font-bold tabular-nums" style="color: var(--ink)">{{ data.profile.media_count }}</p>
                        </div>
                        <div class="rounded-md border p-3 text-center" style="border-color: var(--border)">
                            <p class="text-xs uppercase tracking-wide" style="color: var(--ink-faint)">Username</p>
                            <p class="mt-1 text-sm font-semibold" style="color: var(--ink)">@{{ data.profile.username }}</p>
                        </div>
                    </div>

                    <div>
                        <h3 class="text-sm font-semibold" style="color: var(--ink)">Today's Insights</h3>
                        <div class="mt-2 grid grid-cols-3 gap-3">
                            <div
                                v-for="metric in data.daily_insights"
                                :key="metric.name"
                                class="rounded-md border p-3 text-center"
                                style="border-color: var(--border)"
                            >
                                <p class="text-xs uppercase tracking-wide" style="color: var(--ink-faint)">{{ metric.name }}</p>
                                <p class="mt-1 text-xl font-bold tabular-nums" style="color: var(--ink)">
                                    {{ metric.total_value?.value ?? '—' }}
                                </p>
                            </div>
                        </div>
                    </div>

                    <div>
                        <h3 class="text-sm font-semibold" style="color: var(--ink)">Post Analytics ({{ data.media.length }})</h3>
                        <p class="mt-1 text-xs" style="color: var(--ink-faint)">Click a post to load its insights.</p>
                        <ul class="mt-2 max-h-80 space-y-2 overflow-y-auto">
                            <li
                                v-for="item in data.media"
                                :key="item.id"
                                class="cursor-pointer rounded-md border p-2 text-xs transition-colors"
                                style="border-color: var(--border); color: var(--ink-muted)"
                                @click="toggleMediaInsights(item)"
                            >
                                <div class="flex items-center justify-between">
                                    <div>
                                        <span class="font-semibold" style="color: var(--ink)">{{ item.media_product_type }}</span>
                                        — {{ item.timestamp }}
                                    </div>
                                    <span style="color: var(--ink-faint)">{{ expandedMediaId === item.id ? '▲' : '▼' }}</span>
                                </div>
                                <p class="mt-1 truncate" style="color: var(--ink-faint)">{{ item.caption }}</p>

                                <div v-if="expandedMediaId === item.id" class="mt-2 border-t pt-2" style="border-color: var(--border)" @click.stop>
                                    <div v-if="mediaInsightsLoading === item.id" style="color: var(--ink-faint)">Loading insights…</div>
                                    <div v-else-if="mediaInsightsError[item.id]" style="color: var(--status-parah-ink)">
                                        {{ mediaInsightsError[item.id] }}
                                    </div>
                                    <div v-else-if="mediaInsightsCache[item.id]" class="grid grid-cols-3 gap-2">
                                        <div
                                            v-for="metric in mediaInsightsCache[item.id]"
                                            :key="metric.name"
                                            class="rounded border px-2 py-1 text-center"
                                            style="border-color: var(--border)"
                                        >
                                            <p style="color: var(--ink-faint)">{{ metric.name }}</p>
                                            <p class="font-bold tabular-nums" style="color: var(--ink)">
                                                {{ metric.values?.[0]?.value ?? metric.total_value?.value ?? '—' }}
                                            </p>
                                        </div>
                                    </div>
                                </div>
                            </li>
                        </ul>
                    </div>
                </div>

                <div class="mt-6 flex justify-between border-t pt-4" style="border-color: var(--border)">
                    <button class="text-sm font-medium" style="color: var(--ink-muted)" @click="loadData">Refresh</button>
                    <button v-if="canEdit" class="text-sm font-medium" style="color: var(--status-parah-ink)" @click="confirmDisconnect">Disconnect</button>
                </div>
            </div>

            <details v-if="canEdit" class="mt-6 rounded-md border p-4" style="border-color: var(--border)">
                <summary class="cursor-pointer text-sm font-semibold" style="color: var(--ink)">
                    Import Meta Export (bulk daily data)
                </summary>
                <p class="mt-2 text-xs" style="color: var(--ink-faint)">
                    Upload the daily CSVs exported from Meta Business Suite ("Export data" on each Insights chart). Any
                    subset works — each file is matched by metric, not filename. Rows are merged into this account's
                    daily history, which Add Cycle's auto-fill already reads from.
                </p>

                <form @submit.prevent="submitImport" class="mt-4 space-y-3">
                    <div class="grid grid-cols-2 gap-3">
                        <div v-for="field in importFields" :key="field.key">
                            <label class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">
                                {{ field.label }}
                            </label>
                            <input
                                type="file"
                                accept=".csv,text/csv"
                                data-meta-import-input
                                class="mt-1 w-full text-xs"
                                style="color: var(--ink-muted)"
                                @change="onImportFileChange(field.key, $event)"
                            />
                        </div>
                    </div>

                    <div>
                        <label class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">
                            Starting follower count (optional)
                        </label>
                        <input
                            v-model="startingFollowers"
                            type="number"
                            min="0"
                            placeholder="Leave blank to use the last known count"
                            class="mt-1 w-full rounded-md border px-3 py-2 text-sm"
                            style="border-color: var(--border); background-color: var(--bg); color: var(--ink)"
                        />
                        <p class="mt-1 text-xs" style="color: var(--ink-faint)">
                            "Follows" in the export is the net change per day, not a running total — this seeds the
                            count it accumulates onto for the first imported day. If left blank, the last recorded
                            snapshot before the import range is used, if any.
                        </p>
                    </div>

                    <p v-if="importError" class="text-sm" style="color: var(--status-parah-ink)">{{ importError }}</p>
                    <p v-if="importResult" class="text-sm" style="color: var(--status-sip-ink)">
                        Imported {{ importResult.dates_imported }} day(s), {{ importResult.date_from }} to {{ importResult.date_to }}.
                    </p>

                    <button
                        type="submit"
                        :disabled="importing"
                        class="rounded-md px-4 py-2 text-sm font-semibold transition-opacity hover:opacity-90 disabled:opacity-50"
                        style="background-color: var(--accent); color: var(--accent-ink)"
                    >
                        {{ importing ? 'Importing…' : 'Import' }}
                    </button>
                </form>
            </details>
        </div>

        <ConfirmDialog
            :open="showDisconnectConfirm"
            title="Disconnect Instagram?"
            :message="`This will disconnect Instagram from “${account.name}”. You can reconnect it later.`"
            confirm-label="Disconnect"
            :processing="disconnecting"
            @confirm="disconnect"
            @cancel="cancelDisconnect"
        />
    </div>
</template>
