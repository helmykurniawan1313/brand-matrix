<script>
// True module scope (a plain <script>, not <script setup>) — a `const` inside
// <script setup> is re-declared fresh every time the component is instantiated,
// which defeats the point of caching across "closed and reopened" modal
// instances. This has to live outside setup() entirely so it survives for the
// life of the page/tab, not just one mount.
const liveLoadedUrls = new Set();
</script>

<script setup>
import { computed, nextTick, onMounted, ref } from 'vue';
import { router } from '@inertiajs/vue3';
import StatusBadge from './StatusBadge.vue';
import { useAuth } from '../composables/useAuth';

const { canEdit } = useAuth();

const props = defineProps({
    performance: {
        type: Object,
        required: true,
    },
    viewsBuckets: {
        type: Array,
        default: () => [],
    },
    followerBuckets: {
        type: Array,
        default: () => [],
    },
    defaultAiProvider: {
        type: String,
        default: 'groq',
    },
});

const emit = defineEmits(['close', 'edit']);

const pdfUrl = computed(() => `/performances/${props.performance.id}/pdf`);

const platformLabels = { instagram: 'Instagram', tiktok: 'TikTok' };

const providers = [
    { value: 'groq', label: 'Groq' },
    { value: 'gemini', label: 'Gemini' },
];

const summarizing = ref(false);
const summarizeError = ref(null);
const aiSummary = ref(props.performance.ai_summary ?? null);
const aiSummaryGeneratedAt = ref(props.performance.ai_summary_generated_at ?? null);
const customPrompt = ref('');
const selectedProvider = ref(props.defaultAiProvider);

const summarize = async () => {
    summarizing.value = true;
    summarizeError.value = null;

    try {
        const response = await fetch(`/performances/${props.performance.id}/summarize`, {
            method: 'POST',
            headers: {
                Accept: 'application/json',
                'Content-Type': 'application/json',
                'X-Requested-With': 'XMLHttpRequest',
                'X-XSRF-TOKEN': decodeURIComponent(
                    document.cookie.match(/XSRF-TOKEN=([^;]+)/)?.[1] ?? '',
                ),
            },
            body: JSON.stringify({
                prompt: customPrompt.value || undefined,
                provider: selectedProvider.value || undefined,
            }),
        });

        const data = await response.json();

        if (!response.ok) {
            throw new Error(data.message ?? 'Failed to generate summary.');
        }

        aiSummary.value = data.ai_summary;
        aiSummaryGeneratedAt.value = data.ai_summary_generated_at;
        router.reload({ only: ['performances'], preserveScroll: true });
    } catch (error) {
        summarizeError.value = error.message;
    } finally {
        summarizing.value = false;
    }
};

const tooltipMetric = ref(null);
const tooltipStyle = ref({});

const bucketsFor = (metric) => (metric === 'views' ? props.viewsBuckets : props.followerBuckets);

const openTooltip = (metric, event) => {
    const rect = event.currentTarget.getBoundingClientRect();
    tooltipStyle.value = {
        bottom: `${window.innerHeight - rect.top + 4}px`,
        left: `${Math.max(8, rect.right - 176)}px`,
    };
    tooltipMetric.value = metric;
};

const closeTooltip = () => {
    tooltipMetric.value = null;
};

const formatDate = (value) => {
    if (!value) return '—';
    return new Date(value).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
};

const formatDateTime = (value) => {
    if (!value) return '—';
    return new Date(value).toLocaleString('en-US', { month: 'short', day: 'numeric', hour: 'numeric', minute: '2-digit' });
};

const formatNumber = (value) => (value === null || value === undefined ? '—' : Number(value).toLocaleString('en-US'));

const igSnapshotFields = [
    { key: 'reach', label: 'Reach' },
    { key: 'likes', label: 'Likes' },
    { key: 'comments', label: 'Comments' },
    { key: 'shares', label: 'Shares' },
    { key: 'saved', label: 'Saved' },
    { key: 'total_interactions', label: 'Total Interactions' },
    { key: 'views', label: 'Views' },
    { key: 'ig_reels_avg_watch_time', label: 'Avg Watch Time' },
    { key: 'ig_reels_video_view_total_time', label: 'Total Watch Time' },
];

// Media insight metrics differ by content type (Feed vs. Reels) — a field
// that's null just wasn't returned for this post, so hide it rather than show "—".
const visibleIgSnapshotFields = computed(() => {
    if (!props.performance.ig_snapshot) return [];
    return igSnapshotFields.filter((field) => props.performance.ig_snapshot[field.key] !== null);
});

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

// liveLoadedUrls (which URLs have already been live-embedded, ever, in this
// tab) is declared in the plain <script> block above — true module scope, so
// it survives this detail modal being closed and reopened for the same post.
// An embedded post's <iframe src="..."> re-fetches from Instagram/TikTok's
// servers every single time it's inserted into the page — that's true even if
// the surrounding HTML came from a cache, since the browser always navigates
// an iframe when its src is (re-)mounted. So the only way to actually stop
// repeat requests to the platform is to not re-insert a live iframe at all on
// a later open: the first time a given post is opened in this tab, embed it
// live as usual; every later open of that same post shows a static preview
// card instead, with an explicit "View live post" button that loads the real
// embed only if the user actually asks for it again. Opening a performance
// record's detail modal is a normal, repeated thing to do while reviewing
// data — without this, that alone was generating enough automated-looking
// traffic to the platform's embed CDN to risk the account/IP being flagged.
const liveLoadedInThisOpen = ref(new Set());

const igContainerRefs = {};
const setIgContainerRef = (linkId, el) => {
    if (el) igContainerRefs[linkId] = el;
};

const loadLiveEmbed = async (link) => {
    liveLoadedUrls.add(link.url);
    liveLoadedInThisOpen.value = new Set([...liveLoadedInThisOpen.value, link.url]);
    await nextTick();

    if (link.platform === 'instagram') {
        await loadScript('https://www.instagram.com/embed.js');
        await waitFor(() => window.instgrm?.Embeds?.process);
        window.instgrm?.Embeds?.process();
    } else if (link.platform === 'tiktok') {
        await loadScript('https://www.tiktok.com/embed.js');
    }
};

const isLiveLoaded = (link) => liveLoadedInThisOpen.value.has(link.url);

const processEmbeds = async () => {
    const links = props.performance.video_links ?? [];

    // Only auto-load a link the very first time it's ever been opened in this
    // tab. A link seen before stays on its static preview card (isLiveLoaded
    // stays false for it on this mount) — the raw blockquote/iframe markup
    // still exists in embed_html, but nothing calls embed.js on it again here,
    // so it never gets processed and never fetches. The user's explicit "View
    // live post" click is the only other path into loadLiveEmbed().
    for (const link of links) {
        if (link.embed_html && !liveLoadedUrls.has(link.url)) {
            await loadLiveEmbed(link);
        }
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
                        <span v-if="performance.platform"> &middot; {{ platformLabels[performance.platform] ?? performance.platform }}</span>
                    </p>
                </div>
                <div class="flex shrink-0 items-center gap-1">
                    <button
                        v-if="canEdit"
                        type="button"
                        class="flex h-8 w-8 items-center justify-center rounded-md transition-colors hover:opacity-70"
                        style="color: var(--ink-muted)"
                        aria-label="Edit"
                        @click="emit('edit', performance)"
                    >
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-5 w-5">
                            <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7" />
                            <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5Z" />
                        </svg>
                    </button>
                    <a
                        :href="pdfUrl"
                        class="flex h-8 w-8 items-center justify-center rounded-md transition-colors hover:opacity-70"
                        style="color: var(--ink-muted)"
                        aria-label="Download PDF"
                    >
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-5 w-5">
                            <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4M7 10l5 5 5-5M12 15V3" />
                        </svg>
                    </a>
                    <button
                        type="button"
                        class="flex h-8 w-8 items-center justify-center rounded-md transition-colors hover:opacity-70"
                        style="color: var(--ink-muted)"
                        aria-label="Close"
                        @click="emit('close')"
                    >
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-5 w-5">
                            <path d="M18 6 6 18M6 6l12 12" />
                        </svg>
                    </button>
                </div>
            </div>

            <div class="mt-5 grid grid-cols-2 gap-3 sm:grid-cols-3">
                <div class="rounded-md border px-3 py-2" style="border-color: var(--border); background-color: var(--bg)">
                    <p class="text-[11px] font-medium uppercase tracking-wide" style="color: var(--ink-faint)">Preview Date</p>
                    <p class="mt-0.5 text-sm font-semibold" style="color: var(--ink)">{{ formatDate(performance.preview_date) }}</p>
                </div>
                <div class="rounded-md border px-3 py-2" style="border-color: var(--border); background-color: var(--bg)">
                    <p class="text-[11px] font-medium uppercase tracking-wide" style="color: var(--ink-faint)">Cycle</p>
                    <p v-if="performance.cycle" class="mt-0.5 text-sm font-semibold" style="color: var(--ink)">
                        {{ formatDate(performance.cycle.cycle_start_date) }} – {{ formatDate(performance.cycle.cycle_end_date) }}
                    </p>
                    <p v-else class="mt-0.5 text-sm" style="color: var(--ink-faint)">No cycle</p>
                </div>
                <div class="rounded-md border px-3 py-2" style="border-color: var(--border); background-color: var(--bg)">
                    <p class="text-[11px] font-medium uppercase tracking-wide" style="color: var(--ink-faint)">Ads</p>
                    <p class="mt-0.5 text-sm font-semibold" style="color: var(--ink)">{{ performance.ads === null ? '-' : performance.ads ? 'Yes' : 'No' }}</p>
                </div>
                <div v-if="performance.notes?.length" class="rounded-md border px-3 py-2" style="border-color: var(--border); background-color: var(--bg)">
                    <p class="text-[11px] font-medium uppercase tracking-wide" style="color: var(--ink-faint)">Note</p>
                    <div class="mt-1 flex flex-wrap gap-1">
                        <span
                            v-for="note in performance.notes"
                            :key="note"
                            class="inline-flex items-center rounded px-1.5 py-0.5 text-[11px] font-medium"
                            style="background-color: var(--accent-soft); color: var(--accent)"
                        >
                            {{ note }}
                        </span>
                    </div>
                </div>
                <div class="rounded-md border px-3 py-2" style="border-color: var(--border); background-color: var(--bg)">
                    <p class="text-[11px] font-medium uppercase tracking-wide" style="color: var(--ink-faint)">Followers</p>
                    <p class="mt-0.5 text-sm font-semibold tabular-nums" style="color: var(--ink)">{{ formatNumber(performance.followers) }}</p>
                    <p v-if="performance.followers_captured_date" class="mt-0.5 text-[10px]" style="color: var(--ink-faint)">
                        From {{ formatDate(performance.followers_captured_date) }}
                    </p>
                </div>
                <div
                    class="cursor-default rounded-md border px-3 py-2"
                    style="border-color: var(--border); background-color: var(--bg)"
                    @mouseenter="openTooltip('followers', $event)"
                    @mouseleave="closeTooltip"
                >
                    <p class="text-[11px] font-medium uppercase tracking-wide" style="color: var(--ink-faint)">Account Category</p>
                    <p class="mt-1"><StatusBadge :status="performance.follower_category" /></p>
                </div>
                <div class="rounded-md border px-3 py-2" style="border-color: var(--border); background-color: var(--bg)">
                    <p class="text-[11px] font-medium uppercase tracking-wide" style="color: var(--ink-faint)">Views H+7</p>
                    <p class="mt-0.5 text-sm font-semibold tabular-nums" style="color: var(--ink)">{{ formatNumber(performance.total_views_h7) }}</p>
                </div>
                <div
                    class="cursor-default rounded-md border px-3 py-2"
                    style="border-color: var(--border); background-color: var(--bg)"
                    @mouseenter="openTooltip('views', $event)"
                    @mouseleave="closeTooltip"
                >
                    <p class="text-[11px] font-medium uppercase tracking-wide" style="color: var(--ink-faint)">Status</p>
                    <p class="mt-1"><StatusBadge :status="performance.views_status" /></p>
                </div>
            </div>

            <Teleport to="body">
                <div
                    v-if="tooltipMetric"
                    class="pointer-events-none fixed z-50 w-44 rounded-md border p-2.5 text-left shadow-lg"
                    :style="{ ...tooltipStyle, backgroundColor: 'var(--surface-raised)', borderColor: 'var(--border)' }"
                >
                    <p class="text-[11px] font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">
                        {{ tooltipMetric === 'followers' ? 'Follower Category' : 'Views H+7 Status' }}
                    </p>
                    <ul class="mt-1.5 space-y-1.5">
                        <li
                            v-for="bucket in bucketsFor(tooltipMetric)"
                            :key="bucket.id"
                            class="flex items-center justify-between gap-1.5 text-xs"
                        >
                            <span style="color: var(--ink-muted)">≥ {{ Number(bucket.min_score).toLocaleString() }}</span>
                            <span class="ml-auto"><StatusBadge :status="bucket.label" /></span>
                        </li>
                        <li v-if="bucketsFor(tooltipMetric).length === 0" class="text-xs" style="color: var(--ink-faint)">
                            No buckets configured.
                        </li>
                    </ul>
                </div>
            </Teleport>

            <div v-if="visibleIgSnapshotFields.length" class="mt-6">
                <h3 class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">
                    Instagram Insights
                    <span class="normal-case" style="color: var(--ink-faint)">— as of {{ formatDateTime(performance.ig_snapshot.fetched_at) }}</span>
                </h3>
                <div class="mt-2 grid grid-cols-2 gap-2 sm:grid-cols-3">
                    <div v-for="field in visibleIgSnapshotFields" :key="field.key" class="rounded-md border px-3 py-2" style="border-color: var(--border); background-color: var(--bg)">
                        <p class="text-[11px] font-medium uppercase tracking-wide" style="color: var(--ink-faint)">{{ field.label }}</p>
                        <p class="mt-0.5 text-sm font-semibold tabular-nums" style="color: var(--ink)">
                            {{ formatNumber(performance.ig_snapshot[field.key]) }}
                        </p>
                    </div>
                </div>
            </div>

            <div class="mt-6">
                <h3 class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Crew</h3>
                <div class="mt-2 grid grid-cols-1 gap-2 sm:grid-cols-2">
                    <div class="rounded-md border p-3" style="border-color: var(--border); background-color: var(--bg)">
                        <p class="text-[11px] font-medium uppercase tracking-wide" style="color: var(--ink-faint)">Project Manager</p>
                        <p class="mt-0.5 text-sm font-semibold" style="color: var(--ink)">{{ performance.project_manager?.name ?? '—' }}</p>
                    </div>
                    <div class="rounded-md border p-3" style="border-color: var(--border); background-color: var(--bg)">
                        <p class="text-[11px] font-medium uppercase tracking-wide" style="color: var(--ink-faint)">Conceptor</p>
                        <p class="mt-0.5 text-sm font-semibold" style="color: var(--ink)">{{ performance.conceptor?.name ?? '—' }}</p>
                    </div>
                </div>
            </div>

            <div class="mt-6">
                <h3 class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Video Links</h3>
                <div v-if="performance.video_links?.length" class="mt-2 space-y-4">
                    <div v-for="link in performance.video_links" :key="link.id">
                        <!-- Live embed: only rendered the first time this post is opened in
                             this tab (or after an explicit "View live post" click) — this is
                             what actually makes a network request to Instagram/TikTok. -->
                        <div
                            v-if="link.embed_html && link.platform === 'instagram' && isLiveLoaded(link)"
                            :ref="(el) => setIgContainerRef(link.id, el)"
                            v-html="link.embed_html"
                        />
                        <div v-else-if="link.embed_html && isLiveLoaded(link)" v-html="link.embed_html" />

                        <!-- Static preview: shown once this post has already been live-loaded
                             before in this tab, so reopening its detail modal doesn't silently
                             re-fetch from the platform every time. -->
                        <div
                            v-else-if="link.embed_html"
                            class="flex items-center gap-3 rounded-md border p-3"
                            style="border-color: var(--border); background-color: var(--bg)"
                        >
                            <div
                                class="flex h-12 w-12 shrink-0 items-center justify-center rounded-md text-[10px] font-semibold uppercase"
                                style="background-color: var(--surface); border: 1px solid var(--border); color: var(--ink-faint)"
                            >
                                {{ link.platform }}
                            </div>
                            <div class="min-w-0 flex-1">
                                <p class="truncate text-sm" style="color: var(--ink-muted)">{{ link.url }}</p>
                                <p class="mt-0.5 text-xs" style="color: var(--ink-faint)">Already viewed this session — click to reload the live post.</p>
                            </div>
                            <button
                                type="button"
                                class="shrink-0 rounded-md border px-3 py-1.5 text-xs font-medium transition-colors hover:opacity-70"
                                style="border-color: var(--border); color: var(--accent)"
                                @click="loadLiveEmbed(link)"
                            >
                                View live post
                            </button>
                        </div>

                        <a
                            v-if="!link.embed_html"
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
                        <a
                            v-else-if="isLiveLoaded(link)"
                            :href="link.url"
                            target="_blank"
                            rel="noopener noreferrer"
                            class="mt-1.5 block truncate text-xs transition-colors hover:opacity-80"
                            style="color: var(--accent)"
                        >
                            {{ link.url }}
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

            <!-- AI summary -->
            <div class="mt-6">
                <div class="flex items-center justify-between">
                    <h3 class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">
                        AI Summary
                    </h3>
                    <div class="flex items-center gap-1.5">
                        <span class="text-[11px]" style="color: var(--ink-faint)">Provider</span>
                        <select
                            v-model="selectedProvider"
                            class="rounded-md border py-1 pl-2 pr-6 text-xs transition-colors focus:outline-none"
                            style="border-color: var(--border); background-color: var(--surface); color: var(--ink)"
                        >
                            <option v-for="option in providers" :key="option.value" :value="option.value">
                                {{ option.label }}
                            </option>
                        </select>
                    </div>
                </div>

                <div class="mt-2 flex items-start gap-2">
                    <input
                        v-model="customPrompt"
                        type="text"
                        placeholder="Optional: add custom instructions (e.g. focus on engagement, write for a client email)…"
                        maxlength="500"
                        class="flex-1 rounded-md border px-3 py-2 text-sm transition-colors focus:outline-none"
                        style="border-color: var(--border); background-color: var(--surface); color: var(--ink)"
                        @keydown.enter="summarize"
                    />
                    <button
                        type="button"
                        class="inline-flex shrink-0 items-center gap-1.5 rounded-md px-3 py-2 text-xs font-semibold transition-opacity hover:opacity-90 disabled:opacity-50"
                        style="background-color: var(--accent); color: var(--accent-ink)"
                        :disabled="summarizing"
                        @click="summarize"
                    >
                        <svg
                            v-if="summarizing"
                            class="h-3.5 w-3.5 animate-spin"
                            xmlns="http://www.w3.org/2000/svg"
                            viewBox="0 0 24 24"
                            fill="none"
                        >
                            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" />
                            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v4a4 4 0 00-4 4H4z" />
                        </svg>
                        <svg v-else xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-3.5 w-3.5">
                            <path d="M12 3v3M12 18v3M3 12h3M18 12h3M5.6 5.6l2.1 2.1M16.3 16.3l2.1 2.1M5.6 18.4l2.1-2.1M16.3 7.7l2.1-2.1" />
                        </svg>
                        {{ summarizing ? 'Summarizing…' : aiSummary ? 'Regenerate' : 'Summarize by AI' }}
                    </button>
                </div>

                <p v-if="summarizeError" class="mt-2 text-sm" style="color: var(--status-parah-ink)">
                    {{ summarizeError }}
                </p>

                <div
                    v-if="aiSummary"
                    class="mt-2 rounded-md border p-3"
                    style="border-color: var(--border); background-color: var(--bg)"
                >
                    <p class="text-sm leading-relaxed" style="color: var(--ink)">{{ aiSummary }}</p>
                    <p v-if="aiSummaryGeneratedAt" class="mt-2 text-[11px]" style="color: var(--ink-faint)">
                        Generated {{ formatDateTime(aiSummaryGeneratedAt) }}
                    </p>
                </div>
                <p v-else-if="!summarizeError" class="mt-2 text-sm" style="color: var(--ink-faint)">
                    No summary yet. Click "Summarize by AI" to generate one.
                </p>
            </div>
        </div>
    </div>
</template>
