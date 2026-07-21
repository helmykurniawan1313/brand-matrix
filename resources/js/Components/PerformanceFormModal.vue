<script setup>
import { ref } from 'vue';
import { useForm } from '@inertiajs/vue3';
import SearchableSelect from './SearchableSelect.vue';

const props = defineProps({
    performance: {
        type: Object,
        default: null,
    },
    clients: {
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
});

const emit = defineEmits(['close', 'saved']);

const isEdit = !!props.performance;

const form = useForm({
    client_id: props.performance?.client_id ?? '',
    post_date: props.performance?.post_date?.slice(0, 10) ?? '',
    preview_date: props.performance?.preview_date?.slice(0, 10) ?? '',
    video_links: props.performance?.video_links?.length
        ? props.performance.video_links.map((link) => link.url)
        : [''],
    ads: props.performance?.ads ?? false,
    project_manager_id: props.performance?.project_manager_id ?? '',
    conceptor_id: props.performance?.conceptor_id ?? '',
    editor_id: props.performance?.editor_id ?? '',
    followers: props.performance?.followers ?? '',
    total_views_h7: props.performance?.total_views_h7 ?? '',
    proof: null,
});

const fileSizeError = ref('');

const onFileChange = (event) => {
    const file = event.target.files[0] ?? null;
    fileSizeError.value = '';

    if (file && file.size > 700 * 1024) {
        fileSizeError.value = 'File exceeds 700KB — please choose a smaller image.';
        event.target.value = '';
        form.proof = null;
        return;
    }

    form.proof = file;
};

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
                <div>
                    <label class="block text-sm font-medium" style="color: var(--ink-muted)">Client</label>
                    <SearchableSelect
                        v-model="form.client_id"
                        :options="clients"
                        placeholder="Select a client"
                        class="mt-1"
                    />
                    <p v-if="form.errors.client_id" class="mt-1 text-sm" style="color: var(--status-parah-ink)">
                        {{ form.errors.client_id }}
                    </p>
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
                    </div>
                    <p v-if="form.errors.ads" class="mt-1 text-sm" style="color: var(--status-parah-ink)">
                        {{ form.errors.ads }}
                    </p>
                </div>

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

                <div>
                    <label class="block text-sm font-medium" style="color: var(--ink-muted)">Editor</label>
                    <SearchableSelect
                        v-model="form.editor_id"
                        :options="employees"
                        placeholder="Select an editor"
                        class="mt-1"
                    />
                    <p v-if="form.errors.editor_id" class="mt-1 text-sm" style="color: var(--status-parah-ink)">
                        {{ form.errors.editor_id }}
                    </p>
                </div>

                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label class="block text-sm font-medium" style="color: var(--ink-muted)">Followers</label>
                        <input v-model.number="form.followers" type="number" min="0" :class="inputStyle" :style="inputColors" />
                        <p v-if="form.errors.followers" class="mt-1 text-sm" style="color: var(--status-parah-ink)">
                            {{ form.errors.followers }}
                        </p>
                    </div>
                    <div>
                        <label class="block text-sm font-medium" style="color: var(--ink-muted)">Total Views H+7</label>
                        <input v-model.number="form.total_views_h7" type="number" min="0" :class="inputStyle" :style="inputColors" />
                        <p v-if="form.errors.total_views_h7" class="mt-1 text-sm" style="color: var(--status-parah-ink)">
                            {{ form.errors.total_views_h7 }}
                        </p>
                    </div>
                </div>

                <div>
                    <label class="block text-sm font-medium" style="color: var(--ink-muted)">Upload Proof (max 700KB)</label>
                    <input
                        type="file"
                        accept="image/png,image/jpeg,image/webp"
                        class="mt-1.5 block w-full text-sm"
                        style="color: var(--ink)"
                        @change="onFileChange"
                    />
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
