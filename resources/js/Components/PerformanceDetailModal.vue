<script>
// True module scope (a plain <script>, not <script setup>) — a `const` inside
// <script setup> is re-declared fresh every time the component is instantiated,
// which defeats the point of caching across "closed and reopened" modal
// instances. This has to live outside setup() entirely so it survives for the
// life of the page/tab, not just one mount.
//
// Only the very first post opened in this tab, all session, auto-embeds live —
// not "first time per post". Auto-embedding every never-before-seen post adds
// up fast across a normal browsing session and was enough automated-looking
// traffic to Instagram's embed CDN to risk rate limits. Every post after that
// first one always shows a static preview card with an explicit "View live
// post" button, regardless of whether it's been opened before.
let hasAutoLoadedThisSession = false;
</script>

<script setup>
import { computed, nextTick, onMounted, ref } from 'vue';
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
});

const emit = defineEmits(['close', 'edit']);

const pdfUrl = computed(() => `/performances/${props.performance.id}/pdf`);

const platformLabels = { instagram: 'Instagram', tiktok: 'TikTok' };

// Same icon paths/brand colors used in the app nav (AppLayout.vue) — reused
// here so a video link reads as its platform's logo instead of plain text.
const platformIcons = {
    instagram: { path: 'M17 2H7a5 5 0 0 0-5 5v10a5 5 0 0 0 5 5h10a5 5 0 0 0 5-5V7a5 5 0 0 0-5-5zM12 8a4 4 0 1 0 0 8 4 4 0 0 0 0-8zM17.5 6.5h.01', color: '#e1306c' },
    tiktok: { path: 'M9 12a4 4 0 1 0 4 4V4a5 5 0 0 0 5 5', color: '#010101' },
};

const showProofLightbox = ref(false);

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

// An embedded post's <iframe src="..."> re-fetches from Instagram/TikTok's
// servers every single time it's inserted into the page — that's true even if
// the surrounding HTML came from a cache, since the browser always navigates
// an iframe when its src is (re-)mounted. hasAutoLoadedThisSession (declared
// in the plain <script> block above — true module scope, survives this modal
// being closed/reopened) gates auto-loading to the first post opened all
// session; every other post's embed only loads on an explicit "View live
// post" click. Opening a performance record's detail modal is a normal,
// repeated thing to do while reviewing data — without this, auto-embedding
// every never-before-seen post was generating enough automated-looking
// traffic to the platform's embed CDN to risk the account/IP being flagged.
const liveLoadedInThisOpen = ref(new Set());

const igContainerRefs = {};
const setIgContainerRef = (linkId, el) => {
    if (el) igContainerRefs[linkId] = el;
};

const loadLiveEmbed = async (link) => {
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

    // Auto-load only the very first link of the very first post opened this
    // session. Every other link/post stays on its static preview card — the
    // raw blockquote/iframe markup still exists in embed_html, but nothing
    // calls embed.js on it here, so it never fetches. The user's explicit
    // "View live post" click is the only other path into loadLiveEmbed().
    if (hasAutoLoadedThisSession) return;

    const firstLink = links.find((link) => link.embed_html);
    if (firstLink) {
        hasAutoLoadedThisSession = true;
        await loadLiveEmbed(firstLink);
    }
};

onMounted(processEmbeds);
</script>

<template>
    <div class="fixed inset-0 z-10 flex items-center justify-center bg-black/50 px-4 py-6 backdrop-blur-sm">
        <div
            class="flex max-h-[90vh] w-full max-w-6xl flex-col overflow-hidden rounded-lg border shadow-2xl"
            style="background-color: var(--surface-raised); border-color: var(--border)"
        >
            <!-- Sticky header -->
            <div class="flex shrink-0 items-start justify-between gap-4 border-b px-6 py-5" style="border-color: var(--border)">
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

            <!-- Three-column body: Details (facts/crew), Video Links, Upload Proof
                 side by side — stacks to one column on narrow screens. -->
            <div class="min-h-0 flex-1 overflow-y-auto px-6 py-5">
                <div class="grid grid-cols-1 gap-6 lg:grid-cols-3">
                    <!-- Details column -->
                    <div class="space-y-5">
                        <div>
                            <h3 class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Details</h3>
                            <div class="mt-2 grid grid-cols-2 gap-2">
                                <div class="rounded-md border px-3 py-2" style="border-color: var(--border); background-color: var(--bg)">
                                    <p class="text-[11px] font-medium uppercase tracking-wide" style="color: var(--ink-faint)">Preview Date</p>
                                    <p class="mt-0.5 text-sm font-semibold" style="color: var(--ink)">{{ formatDate(performance.preview_date) }}</p>
                                </div>
                                <div class="rounded-md border px-3 py-2" style="border-color: var(--border); background-color: var(--bg)">
                                    <p class="text-[11px] font-medium uppercase tracking-wide" style="color: var(--ink-faint)">Ads</p>
                                    <p class="mt-0.5 text-sm font-semibold" style="color: var(--ink)">{{ performance.ads === null ? '-' : performance.ads ? 'Yes' : 'No' }}</p>
                                </div>
                                <div class="col-span-2 rounded-md border px-3 py-2" style="border-color: var(--border); background-color: var(--bg)">
                                    <p class="text-[11px] font-medium uppercase tracking-wide" style="color: var(--ink-faint)">Cycle</p>
                                    <p v-if="performance.cycle" class="mt-0.5 text-sm font-semibold" style="color: var(--ink)">
                                        {{ formatDate(performance.cycle.cycle_start_date) }} – {{ formatDate(performance.cycle.cycle_end_date) }}
                                    </p>
                                    <p v-else class="mt-0.5 text-sm" style="color: var(--ink-faint)">No cycle</p>
                                </div>
                                <div v-if="performance.notes?.length" class="col-span-2 rounded-md border px-3 py-2" style="border-color: var(--border); background-color: var(--bg)">
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
                            </div>
                        </div>

                        <div>
                            <h3 class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Performance</h3>
                            <div class="mt-2 grid grid-cols-2 gap-2">
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
                        </div>

                        <div v-if="visibleIgSnapshotFields.length">
                            <h3 class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">
                                Instagram Insights
                                <span class="normal-case" style="color: var(--ink-faint)">— as of {{ formatDateTime(performance.ig_snapshot.fetched_at) }}</span>
                            </h3>
                            <div class="mt-2 grid grid-cols-2 gap-2">
                                <div v-for="field in visibleIgSnapshotFields" :key="field.key" class="rounded-md border px-3 py-2" style="border-color: var(--border); background-color: var(--bg)">
                                    <p class="text-[11px] font-medium uppercase tracking-wide" style="color: var(--ink-faint)">{{ field.label }}</p>
                                    <p class="mt-0.5 text-sm font-semibold tabular-nums" style="color: var(--ink)">
                                        {{ formatNumber(performance.ig_snapshot[field.key]) }}
                                    </p>
                                </div>
                            </div>
                        </div>

                        <div>
                            <h3 class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Crew</h3>
                            <div class="mt-2 grid grid-cols-1 gap-2">
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
                    </div>

                    <!-- Video Links column -->
                    <div>
                        <div>
                            <h3 class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Video Links</h3>
                            <!-- Instagram/TikTok embeds render at their own fixed intrinsic width
                                 (~328px) regardless of the container — a grid or flex-1 wrapper just
                                 stretches empty space around them, not the embed itself, which read as
                                 a lopsided/huge-feeling layout. Capping each card to the column width
                                 keeps the embed's real size in control of the layout. -->
                            <div v-if="performance.video_links?.length" class="mt-2 flex flex-col flex-wrap gap-4">
                                <div v-for="link in performance.video_links" :key="link.id" class="w-full max-w-[340px] overflow-hidden rounded-md" style="border-color: var(--border)">
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
                                            class="flex h-12 w-12 shrink-0 items-center justify-center rounded-md"
                                            style="background-color: var(--surface); border: 1px solid var(--border)"
                                        >
                                            <svg
                                                v-if="platformIcons[link.platform]"
                                                xmlns="http://www.w3.org/2000/svg"
                                                viewBox="0 0 24 24"
                                                fill="none"
                                                :stroke="platformIcons[link.platform].color"
                                                stroke-width="2"
                                                class="h-6 w-6"
                                            >
                                                <path :d="platformIcons[link.platform].path" />
                                            </svg>
                                            <span v-else class="text-[10px] font-semibold uppercase" style="color: var(--ink-faint)">{{ link.platform }}</span>
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
                                            class="flex h-12 w-12 shrink-0 items-center justify-center rounded-md"
                                            style="background-color: var(--surface); border: 1px solid var(--border)"
                                        >
                                            <svg
                                                v-if="platformIcons[link.platform]"
                                                xmlns="http://www.w3.org/2000/svg"
                                                viewBox="0 0 24 24"
                                                fill="none"
                                                :stroke="platformIcons[link.platform].color"
                                                stroke-width="2"
                                                class="h-6 w-6"
                                            >
                                                <path :d="platformIcons[link.platform].path" />
                                            </svg>
                                            <span v-else class="text-[10px] uppercase" style="color: var(--ink-faint)">{{ link.platform ?? '—' }}</span>
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
                    </div>

                    <!-- Upload Proof column -->
                    <div>
                        <h3 class="text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Upload Proof</h3>
                        <button
                            v-if="performance.proof_path"
                            type="button"
                            class="mt-2 block cursor-zoom-in"
                            aria-label="View larger image"
                            @click="showProofLightbox = true"
                        >
                            <img
                                :src="proofUrl(performance.proof_path)"
                                alt="Upload proof"
                                class="max-h-[420px] w-full max-w-[420px] rounded-md border object-contain transition-opacity hover:opacity-90"
                                style="border-color: var(--border)"
                            />
                        </button>
                        <p v-else class="mt-2 text-sm" style="color: var(--ink-faint)">No proof uploaded.</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Proof lightbox — click the thumbnail to see the full-size image -->
        <div
            v-if="showProofLightbox"
            class="fixed inset-0 z-20 flex items-center justify-center bg-black/80 p-6"
            @click="showProofLightbox = false"
        >
            <button
                type="button"
                class="absolute right-4 top-4 flex h-9 w-9 items-center justify-center rounded-md bg-black/40 text-white transition-colors hover:bg-black/60"
                aria-label="Close"
                @click="showProofLightbox = false"
            >
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-5 w-5">
                    <path d="M18 6 6 18M6 6l12 12" />
                </svg>
            </button>
            <img
                :src="proofUrl(performance.proof_path)"
                alt="Upload proof (full size)"
                class="max-h-full max-w-full rounded-md object-contain"
                @click.stop
            />
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
    </div>
</template>
