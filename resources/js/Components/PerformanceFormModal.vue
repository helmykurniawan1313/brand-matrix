<script setup>
import { computed, onBeforeUnmount, ref, watch } from 'vue';
import { useForm } from '@inertiajs/vue3';
import SearchableSelect from './SearchableSelect.vue';
import MultiSelectDropdown from './MultiSelectDropdown.vue';
import { useToast } from '../composables/useToast';

const toast = useToast();

const props = defineProps({
    performance: {
        type: Object,
        default: null,
    },
    accounts: {
        type: Array,
        required: true,
    },
    employees: {
        type: Array,
        required: true,
    },
    accountDepartmentEmployees: {
        type: Array,
        required: true,
    },
    noteOptions: {
        type: Array,
        default: () => [],
    },
});

const emit = defineEmits(['close', 'saved']);

const isEdit = !!props.performance;

const form = useForm({
    account_id: props.performance?.account_id ?? '',
    platform: props.performance?.platform ?? '',
    post_date: props.performance?.post_date?.slice(0, 10) ?? '',
    preview_date: props.performance?.preview_date?.slice(0, 10) ?? '',
    video_links: props.performance?.video_links?.length
        ? props.performance.video_links.map((link) => link.url)
        : [''],
    ads: isEdit ? (props.performance.ads ?? null) : null,
    notes: props.performance?.notes ?? [],
    project_manager_id: props.performance?.project_manager_id ?? '',
    conceptor_id: props.performance?.conceptor_id ?? '',
    editor_id: props.performance?.editor_id ?? '',
    followers: props.performance?.followers ?? '',
    total_views_h7: props.performance?.total_views_h7 ?? '',
    proof: null,
    remove_proof: false,
    ig_media_id: props.performance?.ig_media_id ?? null,
    ig_media_product_type: props.performance?.ig_media_product_type ?? null,
});

const followersCapturedDate = ref(props.performance?.followers_captured_date?.slice(0, 10) ?? null);

const fileSizeError = ref('');

// --- Instagram post linking ---

const selectedAccount = computed(() => props.accounts.find((account) => account.id === form.account_id) ?? null);
const isAccountConnected = computed(() => !!selectedAccount.value?.ig_connected_at);

const linkedMediaId = ref(props.performance?.ig_media_id ?? null);
const linkedMediaProductType = ref(props.performance?.ig_media_product_type ?? null);

const mediaList = ref([]);
const mediaLoading = ref(false);
const mediaError = ref('');
const linking = ref(false);
const showMediaPicker = ref(false);

const csrfToken = () => decodeURIComponent(document.cookie.match(/XSRF-TOKEN=([^;]+)/)?.[1] ?? '');

const loadMedia = async () => {
    if (!selectedAccount.value) return;

    mediaLoading.value = true;
    mediaError.value = '';

    try {
        const res = await fetch(`/accounts/${selectedAccount.value.id}/instagram/media`, {
            headers: { Accept: 'application/json' },
        });
        const body = await res.json();

        if (!res.ok) {
            mediaError.value = body.message ?? 'Failed to load Instagram posts.';
            return;
        }

        mediaList.value = body.media;
    } catch (e) {
        mediaError.value = 'Network error while loading Instagram posts.';
    } finally {
        mediaLoading.value = false;
    }
};

const openMediaPicker = () => {
    showMediaPicker.value = true;
    if (mediaList.value.length === 0) {
        loadMedia();
    }
};

const closeMediaPicker = () => {
    showMediaPicker.value = false;
};

const linkMedia = async (item) => {
    // New (unsaved) records: just stash the selection on the form — store() links
    // and fetches the initial snapshot as part of the create request itself.
    if (!isEdit) {
        form.ig_media_id = item.id;
        form.ig_media_product_type = item.media_product_type;
        linkedMediaId.value = item.id;
        linkedMediaProductType.value = item.media_product_type;

        // Fill Post Date from the post's own timestamp if the user hasn't already set one.
        if (!form.post_date && item.timestamp) {
            form.post_date = item.timestamp.slice(0, 10);
        }

        showMediaPicker.value = false;
        return;
    }

    linking.value = true;

    try {
        const res = await fetch(`/performances/${props.performance.id}/instagram/link`, {
            method: 'POST',
            headers: {
                Accept: 'application/json',
                'Content-Type': 'application/json',
                'X-Requested-With': 'XMLHttpRequest',
                'X-XSRF-TOKEN': csrfToken(),
            },
            body: JSON.stringify({
                ig_media_id: item.id,
                ig_media_product_type: item.media_product_type,
            }),
        });
        const body = await res.json();

        if (!res.ok) {
            toast.error(body.message ?? 'Failed to link Instagram post.');
            return;
        }

        linkedMediaId.value = item.id;
        linkedMediaProductType.value = item.media_product_type;
        form.ig_media_id = item.id;
        form.ig_media_product_type = item.media_product_type;
        form.followers = body.followers ?? form.followers;
        followersCapturedDate.value = body.followers_captured_date ?? null;
        showMediaPicker.value = false;
        toast.success('Linked to Instagram post — metrics will refresh automatically.');
    } catch (e) {
        toast.error('Network error while linking Instagram post.');
    } finally {
        linking.value = false;
    }
};

const unlinkMedia = async () => {
    if (!isEdit) {
        form.ig_media_id = null;
        form.ig_media_product_type = null;
        linkedMediaId.value = null;
        linkedMediaProductType.value = null;
        followersCapturedDate.value = null;
        return;
    }

    linking.value = true;

    try {
        const res = await fetch(`/performances/${props.performance.id}/instagram/link`, {
            method: 'DELETE',
            headers: {
                Accept: 'application/json',
                'X-Requested-With': 'XMLHttpRequest',
                'X-XSRF-TOKEN': csrfToken(),
            },
        });

        if (!res.ok) {
            toast.error('Failed to unlink Instagram post.');
            return;
        }

        linkedMediaId.value = null;
        linkedMediaProductType.value = null;
        form.ig_media_id = null;
        form.ig_media_product_type = null;
        followersCapturedDate.value = null;
        toast.success('Unlinked from Instagram post.');
    } catch (e) {
        toast.error('Network error while unlinking Instagram post.');
    } finally {
        linking.value = false;
    }
};

const linkedMediaCaption = computed(() => {
    const match = mediaList.value.find((item) => item.id === linkedMediaId.value);
    return match?.caption ?? null;
});

// Switching to an unconnected/different account invalidates any link picked from the old account's media list.
watch(() => form.account_id, () => {
    mediaList.value = [];
});

const proofUrl = (path) => (path ? `/storage/${path}` : null);

const newProofPreviewUrl = ref(null);
const isDraggingProof = ref(null);
const proofFileInput = ref(null);

const handleFile = (file) => {
    fileSizeError.value = '';

    if (newProofPreviewUrl.value) {
        URL.revokeObjectURL(newProofPreviewUrl.value);
        newProofPreviewUrl.value = null;
    }

    if (!file) {
        form.proof = null;
        return;
    }

    if (!['image/png', 'image/jpeg', 'image/webp'].includes(file.type)) {
        fileSizeError.value = 'Only PNG, JPG, or WEBP images are allowed.';
        form.proof = null;
        return;
    }

    if (file.size > 700 * 1024) {
        fileSizeError.value = 'File exceeds 700KB — please choose a smaller image.';
        form.proof = null;
        return;
    }

    form.remove_proof = false;
    form.proof = file;
    newProofPreviewUrl.value = URL.createObjectURL(file);
};

const onFileChange = (event) => {
    handleFile(event.target.files[0] ?? null);
};

const onProofDrop = (event) => {
    isDraggingProof.value = false;
    handleFile(event.dataTransfer.files[0] ?? null);
};

const removeNewProof = () => {
    if (proofFileInput.value) {
        proofFileInput.value.value = '';
    }
    handleFile(null);
};

const removeCurrentProof = () => {
    form.remove_proof = true;
    removeNewProof();
};

onBeforeUnmount(() => {
    if (newProofPreviewUrl.value) {
        URL.revokeObjectURL(newProofPreviewUrl.value);
    }
});

const addVideoLink = () => {
    form.video_links.push('');
};

const removeVideoLink = (index) => {
    form.video_links.splice(index, 1);
    if (form.video_links.length === 0) {
        form.video_links.push('');
    }
};

const submit = () => {
    const url = isEdit ? `/performances/${props.performance.id}` : '/performances';
    const options = { forceFormData: true, preserveScroll: true, onSuccess: () => emit('saved') };

    if (isEdit) {
        form.transform((data) => ({ ...data, _method: 'put' })).post(url, options);
    } else {
        form.post(url, options);
    }
};

const inputStyle =
    'mt-1 w-full rounded-md border px-3 py-2 text-sm transition-colors focus:outline-none focus:ring-2';
const inputColors = 'border-color: var(--border); background-color: var(--surface); color: var(--ink)';

// Followers/Views inputs are plain <input type="text"> (not type="number") so they
// can display thousand separators — the underlying form field stays a plain integer,
// only the displayed text is comma-formatted.
const formatThousands = (value) => (value === null || value === undefined || value === '' ? '' : Number(value).toLocaleString('en-US'));

const onThousandsInput = (field, event) => {
    const digitsOnly = event.target.value.replace(/[^\d]/g, '');
    form[field] = digitsOnly === '' ? '' : Number(digitsOnly);
    event.target.value = formatThousands(form[field]);
};
</script>

<template>
    <div class="fixed inset-0 z-10 flex items-center justify-center bg-black/50 px-4 backdrop-blur-sm">
        <div
            class="max-h-[90vh] w-full max-w-2xl overflow-y-auto rounded-lg border p-6 shadow-2xl"
            style="background-color: var(--surface-raised); border-color: var(--border)"
        >
            <div class="flex items-start justify-between gap-4">
                <h2 class="font-display text-lg font-bold" style="color: var(--ink)">
                    {{ isEdit ? 'Edit Performance' : 'Add Performance' }}
                </h2>
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

            <form class="mt-5 space-y-4" @submit.prevent="submit">
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label class="block text-sm font-medium" style="color: var(--ink-muted)">Account</label>
                        <SearchableSelect
                            v-model="form.account_id"
                            :options="accounts"
                            placeholder="Select an account"
                            class="mt-1"
                        />
                        <p v-if="form.errors.account_id" class="mt-1 text-sm" style="color: var(--status-parah-ink)">
                            {{ form.errors.account_id }}
                        </p>
                    </div>

                    <div>
                        <label class="block text-sm font-medium" style="color: var(--ink-muted)">Platform</label>
                        <select v-model="form.platform" :class="inputStyle" :style="inputColors">
                            <option value="">Select a platform</option>
                            <option value="instagram">Instagram</option>
                            <option value="tiktok">TikTok</option>
                        </select>
                        <p v-if="form.errors.platform" class="mt-1 text-sm" style="color: var(--status-parah-ink)">
                            {{ form.errors.platform }}
                        </p>
                    </div>
                </div>

                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label class="block text-sm font-medium" style="color: var(--ink-muted)">Post Date</label>
                        <input v-model="form.post_date" type="date" :class="inputStyle" :style="inputColors" />
                        <p v-if="form.errors.post_date" class="mt-1 text-sm" style="color: var(--status-parah-ink)">
                            {{ form.errors.post_date }}
                        </p>
                    </div>
                    <div>
                        <label class="block text-sm font-medium" style="color: var(--ink-muted)">Preview Date</label>
                        <input v-model="form.preview_date" type="date" :class="inputStyle" :style="inputColors" />
                        <p v-if="form.errors.preview_date" class="mt-1 text-sm" style="color: var(--status-parah-ink)">
                            {{ form.errors.preview_date }}
                        </p>
                    </div>
                </div>

                <div>
                    <label class="block text-sm font-medium" style="color: var(--ink-muted)">Video Links</label>
                    <div class="mt-1 space-y-2">
                        <div v-for="(link, index) in form.video_links" :key="index" class="flex items-center gap-2">
                            <input
                                v-model="form.video_links[index]"
                                type="url"
                                placeholder="https://instagram.com/... or https://tiktok.com/..."
                                class="w-full rounded-md border px-3 py-2 text-sm transition-colors focus:outline-none"
                                :style="inputColors"
                            />
                            <button
                                type="button"
                                class="shrink-0 text-sm font-medium transition-colors hover:opacity-70"
                                style="color: var(--status-parah-ink)"
                                @click="removeVideoLink(index)"
                            >
                                Remove
                            </button>
                        </div>
                    </div>
                    <button
                        type="button"
                        class="mt-2 text-sm font-medium transition-colors hover:opacity-70"
                        style="color: var(--accent)"
                        @click="addVideoLink"
                    >
                        + Add another link
                    </button>
                    <p v-if="form.errors['video_links.0']" class="mt-1 text-sm" style="color: var(--status-parah-ink)">
                        {{ form.errors['video_links.0'] }}
                    </p>
                </div>

                <div>
                    <label class="block text-sm font-medium" style="color: var(--ink-muted)">Ads</label>
                    <div class="mt-1.5 flex items-center gap-4">
                        <label class="inline-flex items-center gap-1.5 text-sm" style="color: var(--ink)">
                            <input v-model="form.ads" type="radio" :value="true" />
                            Yes
                        </label>
                        <label class="inline-flex items-center gap-1.5 text-sm" style="color: var(--ink)">
                            <input v-model="form.ads" type="radio" :value="false" />
                            No
                        </label>
                        <label class="inline-flex items-center gap-1.5 text-sm" style="color: var(--ink)">
                            <input v-model="form.ads" type="radio" :value="null" />
                            -
                        </label>
                    </div>
                    <p v-if="form.errors.ads" class="mt-1 text-sm" style="color: var(--status-parah-ink)">
                        {{ form.errors.ads }}
                    </p>
                </div>

                <div>
                    <label class="block text-sm font-medium" style="color: var(--ink-muted)">Note</label>
                    <MultiSelectDropdown
                        v-model="form.notes"
                        :options="noteOptions"
                        placeholder="Select note(s)"
                        class="mt-1"
                    />
                    <p v-if="form.errors.notes" class="mt-1 text-sm" style="color: var(--status-parah-ink)">
                        {{ form.errors.notes }}
                    </p>
                </div>

                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label class="block text-sm font-medium" style="color: var(--ink-muted)">Project Manager</label>
                        <SearchableSelect
                            v-model="form.project_manager_id"
                            :options="accountDepartmentEmployees"
                            placeholder="Select a project manager"
                            class="mt-1"
                        />
                        <p v-if="form.errors.project_manager_id" class="mt-1 text-sm" style="color: var(--status-parah-ink)">
                            {{ form.errors.project_manager_id }}
                        </p>
                    </div>

                    <div>
                        <label class="block text-sm font-medium" style="color: var(--ink-muted)">Conceptor</label>
                        <SearchableSelect
                            v-model="form.conceptor_id"
                            :options="employees"
                            placeholder="Select a conceptor"
                            class="mt-1"
                        />
                        <p v-if="form.errors.conceptor_id" class="mt-1 text-sm" style="color: var(--status-parah-ink)">
                            {{ form.errors.conceptor_id }}
                        </p>
                    </div>
                </div>

                <div v-if="isAccountConnected">
                    <label class="block text-sm font-medium" style="color: var(--ink-muted)">Instagram Post</label>

                    <div v-if="linkedMediaId" class="mt-1.5 flex items-center justify-between gap-2 rounded-md border p-2.5" style="border-color: var(--border); background-color: var(--bg)">
                        <p class="truncate text-sm" style="color: var(--ink)">
                            {{ linkedMediaCaption ?? linkedMediaId }}
                            <span class="ml-1 text-xs" style="color: var(--ink-faint)">({{ linkedMediaProductType }})</span>
                        </p>
                        <div class="flex shrink-0 items-center gap-2">
                            <button type="button" class="text-xs font-medium hover:opacity-70" style="color: var(--accent)" :disabled="linking" @click="openMediaPicker">
                                Change
                            </button>
                            <button type="button" class="text-xs font-medium hover:opacity-70" style="color: var(--status-parah-ink)" :disabled="linking" @click="unlinkMedia">
                                Unlink
                            </button>
                        </div>
                    </div>
                    <button
                        v-else
                        type="button"
                        class="mt-1.5 w-full rounded-md border border-dashed px-3 py-2 text-sm font-medium transition-colors hover:opacity-70"
                        style="border-color: var(--border); color: var(--ink-muted)"
                        @click="openMediaPicker"
                    >
                        + Link an Instagram post to auto-fill metrics
                    </button>
                    <p v-if="!isEdit && linkedMediaId" class="mt-1 text-xs" style="color: var(--ink-faint)">
                        Metrics will be fetched once this record is saved.
                    </p>

                    <!-- Media picker -->
                    <div v-if="showMediaPicker" class="fixed inset-0 z-20 flex items-center justify-center bg-black/50 px-4" @click.self="closeMediaPicker">
                        <div class="max-h-[70vh] w-full max-w-lg overflow-y-auto rounded-lg border p-4 shadow-2xl" style="background-color: var(--surface-raised); border-color: var(--border)">
                            <div class="flex items-center justify-between">
                                <h3 class="text-sm font-semibold" style="color: var(--ink)">Select an Instagram post</h3>
                                <button type="button" class="text-sm" style="color: var(--ink-muted)" @click="closeMediaPicker">Close</button>
                            </div>

                            <div v-if="mediaLoading" class="mt-3 text-sm" style="color: var(--ink-faint)">Loading posts…</div>
                            <div v-else-if="mediaError" class="mt-3 text-sm" style="color: var(--status-parah-ink)">{{ mediaError }}</div>
                            <ul v-else class="mt-3 space-y-1.5">
                                <li v-for="item in mediaList" :key="item.id">
                                    <button
                                        type="button"
                                        class="w-full rounded-md border p-2 text-left text-sm transition-colors hover:opacity-80 disabled:opacity-50"
                                        style="border-color: var(--border); background-color: var(--bg); color: var(--ink)"
                                        :disabled="linking"
                                        @click="linkMedia(item)"
                                    >
                                        <span class="font-medium">{{ item.media_product_type }}</span>
                                        <span class="ml-1 text-xs" style="color: var(--ink-faint)">{{ item.timestamp }}</span>
                                        <p class="mt-0.5 truncate" style="color: var(--ink-muted)">{{ item.caption ?? '—' }}</p>
                                    </button>
                                </li>
                                <li v-if="mediaList.length === 0" class="text-sm" style="color: var(--ink-faint)">No posts found.</li>
                            </ul>
                        </div>
                    </div>
                </div>

                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label class="block text-sm font-medium" style="color: var(--ink-muted)">Followers</label>
                        <input
                            type="text"
                            inputmode="numeric"
                            :value="formatThousands(form.followers)"
                            :readonly="!!linkedMediaId"
                            :class="inputStyle"
                            :style="inputColors"
                            @input="onThousandsInput('followers', $event)"
                        />
                        <p v-if="linkedMediaId && followersCapturedDate" class="mt-1 text-xs" style="color: var(--ink-faint)">
                            From {{ followersCapturedDate }} snapshot.
                        </p>
                        <p v-else-if="linkedMediaId" class="mt-1 text-xs" style="color: var(--ink-faint)">Auto-filled from Instagram.</p>
                        <p v-if="form.errors.followers" class="mt-1 text-sm" style="color: var(--status-parah-ink)">
                            {{ form.errors.followers }}
                        </p>
                    </div>
                    <div>
                        <label class="block text-sm font-medium" style="color: var(--ink-muted)">Total Views H+7</label>
                        <input
                            type="text"
                            inputmode="numeric"
                            :value="formatThousands(form.total_views_h7)"
                            :readonly="!!linkedMediaId"
                            :class="inputStyle"
                            :style="inputColors"
                            @input="onThousandsInput('total_views_h7', $event)"
                        />
                        <p v-if="linkedMediaId" class="mt-1 text-xs" style="color: var(--ink-faint)">Auto-filled from Instagram (current total, not a day-7 checkpoint).</p>
                        <p v-if="form.errors.total_views_h7" class="mt-1 text-sm" style="color: var(--status-parah-ink)">
                            {{ form.errors.total_views_h7 }}
                        </p>
                    </div>
                </div>

                <div>
                    <label class="block text-sm font-medium" style="color: var(--ink-muted)">Upload Proof (max 700KB)</label>

                    <div v-if="isEdit && performance.proof_path && !form.proof && !form.remove_proof" class="mt-1.5">
                        <div class="relative inline-block">
                            <img
                                :src="proofUrl(performance.proof_path)"
                                alt="Current upload proof"
                                class="max-h-40 rounded-md border"
                                style="border-color: var(--border)"
                            />
                            <button
                                type="button"
                                class="absolute -right-2 -top-2 flex h-6 w-6 items-center justify-center rounded-full shadow"
                                style="background-color: var(--status-parah-ink); color: white"
                                aria-label="Delete current proof"
                                @click="removeCurrentProof"
                            >
                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" class="h-3.5 w-3.5">
                                    <path d="M18 6 6 18M6 6l12 12" />
                                </svg>
                            </button>
                        </div>
                        <p class="mt-1 text-xs" style="color: var(--ink-faint)">
                            Current proof. Drop or choose a new file below to replace it, or delete it.
                        </p>
                    </div>

                    <div v-if="newProofPreviewUrl" class="mt-1.5">
                        <div class="relative inline-block">
                            <img
                                :src="newProofPreviewUrl"
                                alt="New upload proof preview"
                                class="max-h-40 rounded-md border"
                                style="border-color: var(--border)"
                            />
                            <button
                                type="button"
                                class="absolute -right-2 -top-2 flex h-6 w-6 items-center justify-center rounded-full shadow"
                                style="background-color: var(--status-parah-ink); color: white"
                                aria-label="Remove selected file"
                                @click="removeNewProof"
                            >
                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" class="h-3.5 w-3.5">
                                    <path d="M18 6 6 18M6 6l12 12" />
                                </svg>
                            </button>
                        </div>
                    </div>

                    <p v-if="form.remove_proof && !form.proof" class="mt-1.5 text-xs" style="color: var(--status-parah-ink)">
                        Current proof will be removed when saved.
                    </p>

                    <div
                        class="mt-1.5 flex cursor-pointer flex-col items-center justify-center gap-1 rounded-md border-2 border-dashed px-3 py-6 text-center transition-colors"
                        :style="{
                            borderColor: isDraggingProof ? 'var(--accent)' : 'var(--border)',
                            backgroundColor: isDraggingProof ? 'var(--accent-soft)' : 'var(--bg)',
                        }"
                        @click="proofFileInput?.click()"
                        @dragover.prevent="isDraggingProof = true"
                        @dragleave.prevent="isDraggingProof = false"
                        @drop.prevent="onProofDrop"
                    >
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-6 w-6" style="color: var(--ink-faint)">
                            <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4M7 10l5 5 5-5M12 15V3" />
                        </svg>
                        <p class="text-sm" style="color: var(--ink-muted)">
                            <span style="color: var(--accent)">Click to upload</span> or drag and drop
                        </p>
                        <p class="text-xs" style="color: var(--ink-faint)">PNG, JPG, or WEBP — max 700KB</p>
                        <input
                            ref="proofFileInput"
                            type="file"
                            accept="image/png,image/jpeg,image/webp"
                            class="hidden"
                            @change="onFileChange"
                            @click.stop
                        />
                    </div>

                    <p v-if="fileSizeError" class="mt-1 text-sm" style="color: var(--status-parah-ink)">
                        {{ fileSizeError }}
                    </p>
                    <p v-if="form.errors.proof" class="mt-1 text-sm" style="color: var(--status-parah-ink)">
                        {{ form.errors.proof }}
                    </p>
                </div>

                <div class="flex justify-end gap-3 pt-2">
                    <button
                        type="button"
                        class="rounded-md border px-4 py-2 text-sm font-medium transition-colors hover:opacity-70"
                        style="border-color: var(--border); color: var(--ink-muted)"
                        @click="emit('close')"
                    >
                        Cancel
                    </button>
                    <button
                        type="submit"
                        :disabled="form.processing"
                        class="rounded-md px-4 py-2 text-sm font-semibold transition-opacity hover:opacity-90 disabled:opacity-50"
                        style="background-color: var(--accent); color: var(--accent-ink)"
                    >
                        {{ isEdit ? 'Save Changes' : 'Add Performance' }}
                    </button>
                </div>
            </form>
        </div>
    </div>
</template>
