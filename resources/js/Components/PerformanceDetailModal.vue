<script setup>
import { nextTick, onMounted } from 'vue';

const props = defineProps({
    performance: {
        type: Object,
        required: true,
    },
});

const emit = defineEmits(['close']);

const formatDate = (value) => {
    if (!value) return '—';
    return new Date(value).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
};

const proofUrl = (path) => (path ? `/storage/${path}` : null);

const scriptPromises = {};

const loadScript = (src) => {
    if (scriptPromises[src]) {
        return scriptPromises[src];
    }

    scriptPromises[src] = new Promise((resolve) => {
        const script = document.createElement('script');
        script.src = src;
        script.async = true;
        script.onload = resolve;
        script.onerror = resolve;
        document.body.appendChild(script);
    });

    return scriptPromises[src];
};

const waitFor = async (check, attempts = 20, delayMs = 100) => {
    for (let i = 0; i < attempts; i++) {
        if (check()) return true;
        await new Promise((r) => setTimeout(r, delayMs));
    }
    return false;
};

const processEmbeds = async () => {
    const hasInstagram = props.performance.video_links?.some((link) => link.platform === 'instagram');
    const hasTiktok = props.performance.video_links?.some((link) => link.platform === 'tiktok');

    await nextTick();

    if (hasInstagram) {
        await loadScript('https://www.instagram.com/embed.js');
        await waitFor(() => window.instgrm?.Embeds?.process);
        window.instgrm?.Embeds?.process();
    }

    if (hasTiktok) {
        await loadScript('https://www.tiktok.com/embed.js');
    }
};

onMounted(processEmbeds);
</script>

<template>
    <div class="fixed inset-0 z-10 flex items-center justify-center bg-black/50 px-4 backdrop-blur-sm">
        <div
            class="max-h-[85vh] w-full max-w-2xl overflow-y-auto rounded-lg border p-6 shadow-2xl"
            style="background-color: var(--surface-raised); border-color: var(--border)"
        >
            <div class="flex items-start justify-between gap-4">
                <div>
                    <h2 class="font-display text-lg font-bold" style="color: var(--ink)">
                        {{ performance.account?.name ?? '—' }}
                    </h2>
                    <p class="mt-0.5 text-sm" style="color: var(--ink-muted)">
                        Posted {{ formatDate(performance.post_date) }}
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

            <div class="mt-5 grid grid-cols-2 gap-3 sm:grid-cols-4">
                <div class="rounded-md border px-3 py-2" style="border-color: var(--border); background-color: var(--bg)">
                    <p class="text-[11px] font-medium uppercase tracking-wide" style="color: var(--ink-faint)">Preview Date</p>
                    <p class="mt-0.5 text-sm font-semibold" style="color: var(--ink)">{{ formatDate(performance.preview_date) }}</p>
                </div>
                <div class="rounded-md border px-3 py-2" style="border-color: var(--border); background-color: var(--bg)">
                    <p class="text-[11px] font-medium uppercase tracking-wide" style="color: var(--ink-faint)">Ads</p>
                    <p class="mt-0.5 text-sm font-semibold" style="color: var(--ink)">{{ performance.ads ? 'Yes' : 'No' }}</p>
                </div>
                <div class="rounded-md border px-3 py-2" style="border-color: var(--border); background-color: var(--bg)">
                    <p class="text-[11px] font-medium uppercase tracking-wide" style="color: var(--ink-faint)">Followers</p>
                    <p class="mt-0.5 text-sm font-semibold tabular-nums" style="color: var(--ink)">{{ performance.followers ?? '—' }}</p>
                </div>
                <div class="rounded-md border px-3 py-2" style="border-color: var(--border); background-color: var(--bg)">
                    <p class="text-[11px] font-medium uppercase tracking-wide" style="color: var(--ink-faint)">Views H+7</p>
                    <p class="mt-0.5 text-sm font-semibold tabular-nums" style="color: var(--ink)">{{ performance.total_views_h7 ?? '—' }}</p>
                </div>
            </div>

            <div class="mt-6">
                <h3 class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Crew</h3>
                <div class="mt-2 grid grid-cols-1 gap-2 sm:grid-cols-3">
                    <div class="rounded-md border p-3" style="border-color: var(--border); background-color: var(--bg)">
                        <p class="text-[11px] font-medium uppercase tracking-wide" style="color: var(--ink-faint)">Project Manager</p>
                        <p class="mt-0.5 text-sm font-semibold" style="color: var(--ink)">{{ performance.project_manager?.name ?? '—' }}</p>
                    </div>
                    <div class="rounded-md border p-3" style="border-color: var(--border); background-color: var(--bg)">
                        <p class="text-[11px] font-medium uppercase tracking-wide" style="color: var(--ink-faint)">Conceptor</p>
                        <p class="mt-0.5 text-sm font-semibold" style="color: var(--ink)">{{ performance.conceptor?.name ?? '—' }}</p>
                    </div>
                    <div class="rounded-md border p-3" style="border-color: var(--border); background-color: var(--bg)">
                        <p class="text-[11px] font-medium uppercase tracking-wide" style="color: var(--ink-faint)">Editor</p>
                        <p class="mt-0.5 text-sm font-semibold" style="color: var(--ink)">{{ performance.editor?.name ?? '—' }}</p>
                    </div>
                </div>
            </div>

            <div class="mt-6">
                <h3 class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Video Links</h3>
                <div v-if="performance.video_links?.length" class="mt-2 space-y-4">
                    <div v-for="link in performance.video_links" :key="link.id">
                        <div v-if="link.embed_html" v-html="link.embed_html" />
                        <a
                            v-else
                            :href="link.url"
                            target="_blank"
                            rel="noopener noreferrer"
                            class="flex items-center gap-3 rounded-md border p-2 transition-colors hover:opacity-80"
                            style="border-color: var(--border); background-color: var(--bg)"
                        >
                            <div
                                class="flex h-12 w-12 shrink-0 items-center justify-center rounded-md text-[10px] uppercase"
                                style="background-color: var(--surface); border: 1px solid var(--border); color: var(--ink-faint)"
                            >
                                {{ link.platform ?? '—' }}
                            </div>
                            <span class="truncate text-sm" style="color: var(--accent)">{{ link.url }}</span>
                        </a>
                    </div>
                </div>
                <p v-else class="mt-2 text-sm" style="color: var(--ink-faint)">No video links recorded.</p>
            </div>

            <div class="mt-6">
                <h3 class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Upload Proof</h3>
                <img
                    v-if="performance.proof_path"
                    :src="proofUrl(performance.proof_path)"
                    alt="Upload proof"
                    class="mt-2 max-h-64 rounded-md border"
                    style="border-color: var(--border)"
                />
                <p v-else class="mt-2 text-sm" style="color: var(--ink-faint)">No proof uploaded.</p>
            </div>
        </div>
    </div>
</template>
