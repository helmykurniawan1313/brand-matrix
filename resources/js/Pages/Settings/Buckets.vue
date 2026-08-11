<script setup>
import { computed, reactive, ref } from 'vue';
import { router, useForm } from '@inertiajs/vue3';
import AppLayout from '../../Layouts/AppLayout.vue';

import ConfirmDialog from '../../Components/ConfirmDialog.vue';
import { useToast } from '../../composables/useToast';
import { useAuth } from '../../composables/useAuth';

defineOptions({ layout: AppLayout });

const toast = useToast();
const { canEdit } = useAuth();

const props = defineProps({
    scoreBuckets: {
        type: Array,
        required: true,
    },
    labelBuckets: {
        type: Array,
        required: true,
    },
    scoreMetrics: {
        type: Array,
        required: true,
    },
    labelMetrics: {
        type: Array,
        required: true,
    },
    formulaWeights: {
        type: Array,
        required: true,
    },
    formulaComponents: {
        type: Object,
        required: true,
    },
});

const metricTitles = {
    growth: 'Growth Rate',
    reach: 'Reach Rate',
    view: 'View Rate',
    er_reach: 'Engagement Rate (of Reach)',
    er_follower: 'Engagement Rate (of Followers)',
    visibility: 'Visibility',
    engagement: 'Engagement',
    health: 'Health',
    views: 'Views (H+7) Status',
    followers: 'Follower Category',
};

const metricHints = {
    growth: '(end − start) / start × 100',
    reach: 'reach / end followers × 100',
    view: 'views / end followers × 100',
    er_reach: 'engagement / reach × 100',
    er_follower: 'engagement / end followers × 100',
    visibility: 'weighted average of reach score + view score',
    engagement: 'weighted average of ER-reach score + ER-follower score',
    health: 'weighted average of growth + visibility + engagement',
    views: 'raw Views H+7 count, from Performance records',
    followers: 'raw follower count, from Performance records',
};

const componentLabels = {
    reach_score: 'Reach Score',
    view_score: 'View Score',
    er_reach_score: 'ER-Reach Score',
    er_follower_score: 'ER-Follower Score',
    growth_score: 'Growth Score',
    visibility_rate: 'Visibility Rate',
    engagement_score: 'Engagement Score',
};

const inputStyle =
    'rounded-md border px-2.5 py-1.5 text-sm tabular-nums transition-colors focus:outline-none';
const inputSurface = 'border-color: var(--border); background-color: var(--surface); color: var(--ink)';

const scoreBucketsByMetric = computed(() => {
    const grouped = {};
    for (const metric of props.scoreMetrics) {
        grouped[metric] = props.scoreBuckets
            .filter((b) => b.metric === metric)
            .sort((a, b) => (b.min_rate ?? -Infinity) - (a.min_rate ?? -Infinity));
    }
    return grouped;
});

const labelBucketsByMetric = computed(() => {
    const grouped = {};
    for (const metric of props.labelMetrics) {
        grouped[metric] = props.labelBuckets
            .filter((b) => b.metric === metric)
            .sort((a, b) => (b.min_score ?? -Infinity) - (a.min_score ?? -Infinity));
    }
    return grouped;
});

// --- Score bucket editing ---

const scoreForms = reactive({});
const initScoreForm = (bucket) => {
    scoreForms[bucket.id] = useForm({
        min_rate: bucket.min_rate,
        score: bucket.score,
    });
};
props.scoreBuckets.forEach(initScoreForm);

const saveScoreBucket = (bucket) => {
    scoreForms[bucket.id].put(`/score-buckets/${bucket.id}`, {
        preserveScroll: true,
        onSuccess: () => toast.success('Tier saved.'),
        onError: () => toast.error('Failed to save tier.'),
    });
};

const deleteScoreBucket = (bucket) => {
    deletingBucket.value = { kind: 'score', bucket };
};

const newScoreForms = reactive({});
props.scoreMetrics.forEach((metric) => {
    newScoreForms[metric] = useForm({ metric, min_rate: null, score: 0 });
});

const addScoreBucket = (metric) => {
    newScoreForms[metric].post('/score-buckets', {
        preserveScroll: true,
        onSuccess: () => {
            newScoreForms[metric].reset();
            toast.success('Tier added.');
        },
        onError: () => toast.error('Failed to add tier.'),
    });
};

// --- Label bucket editing ---

const labelForms = reactive({});
const initLabelForm = (bucket) => {
    labelForms[bucket.id] = useForm({
        min_score: bucket.min_score,
        label: bucket.label,
    });
};
props.labelBuckets.forEach(initLabelForm);

const saveLabelBucket = (bucket) => {
    labelForms[bucket.id].put(`/label-buckets/${bucket.id}`, {
        preserveScroll: true,
        onSuccess: () => toast.success('Tier saved.'),
        onError: () => toast.error('Failed to save tier.'),
    });
};

const deleteLabelBucket = (bucket) => {
    deletingBucket.value = { kind: 'label', bucket };
};

// Shared delete confirmation for both score and label bucket tiers

const deletingBucket = ref(null);
const deletingBucketProcessing = ref(false);

const cancelDeleteBucket = () => {
    deletingBucket.value = null;
};

const confirmDeleteBucket = () => {
    if (!deletingBucket.value) return;
    const { kind, bucket } = deletingBucket.value;
    const url = kind === 'score' ? `/score-buckets/${bucket.id}` : `/label-buckets/${bucket.id}`;
    deletingBucketProcessing.value = true;

    router.delete(url, {
        preserveScroll: true,
        onSuccess: () => {
            toast.success('Tier deleted.');
            deletingBucket.value = null;
        },
        onError: () => toast.error('Failed to delete tier.'),
        onFinish: () => {
            deletingBucketProcessing.value = false;
        },
    });
};

const newLabelForms = reactive({});
props.labelMetrics.forEach((metric) => {
    newLabelForms[metric] = useForm({ metric, min_score: null, label: '' });
});

const addLabelBucket = (metric) => {
    newLabelForms[metric].post('/label-buckets', {
        preserveScroll: true,
        onSuccess: () => {
            newLabelForms[metric].reset();
            toast.success('Tier added.');
        },
        onError: () => toast.error('Failed to add tier.'),
    });
};

// --- Formula weight editing ---

const weightForms = reactive({});
Object.entries(props.formulaComponents).forEach(([aggregate, components]) => {
    const initial = {};
    components.forEach((component) => {
        const existing = props.formulaWeights.find(
            (w) => w.aggregate === aggregate && w.component === component,
        );
        initial[component] = existing ? Number(existing.weight) : Number((1 / components.length).toFixed(4));
    });

    weightForms[aggregate] = useForm({ weights: initial });
});

const weightSum = (aggregate) => {
    return Object.values(weightForms[aggregate].weights).reduce((sum, w) => sum + (Number(w) || 0), 0);
};

const normalizedPercent = (aggregate, component) => {
    const sum = weightSum(aggregate);
    const value = Number(weightForms[aggregate].weights[component]) || 0;
    if (sum <= 0) return '0';
    return Math.round((value / sum) * 1000) / 10;
};

const saveWeights = (aggregate) => {
    weightForms[aggregate].put(`/formula-weights/${aggregate}`, {
        preserveScroll: true,
        onSuccess: () => toast.success('Weights saved.'),
        onError: () => toast.error('Failed to save weights.'),
    });
};
</script>

<template>
        <h1 class="font-display text-2xl font-bold tracking-tight" style="color: var(--ink)">Scoring Buckets</h1>
        <p class="mt-1 max-w-2xl text-sm" style="color: var(--ink-muted)">
            Each tier fires when a metric's rate is at or above its minimum — the highest matching tier wins. Leave
            the minimum blank to set the floor tier. Edits apply to every cycle's score the next time a dashboard
            page loads.
        </p>

        <h2 class="mt-10 font-display text-lg font-bold" style="color: var(--ink)">Formula Weights</h2>
        <p class="mt-1 max-w-2xl text-sm" style="color: var(--ink-muted)">
            Adjust how much each component contributes to Visibility, Engagement, and Health. Weights don't need to
            sum to 1 — they're automatically normalized, so entering 2 and 1 is the same as entering 0.67 and 0.33.
        </p>

        <div class="mt-4 grid gap-6 lg:grid-cols-3">
            <section
                v-for="aggregate in Object.keys(formulaComponents)"
                :key="aggregate"
                class="rounded-lg border p-5"
                style="border-color: var(--border); background-color: var(--surface)"
            >
                <h3 class="font-display text-sm font-bold" style="color: var(--ink)">{{ metricTitles[aggregate] }}</h3>
                <p class="mt-0.5 font-mono text-xs" style="color: var(--ink-faint)">{{ metricHints[aggregate] }}</p>

                <div class="mt-4 space-y-2">
                    <div
                        v-for="component in formulaComponents[aggregate]"
                        :key="component"
                        class="flex items-center gap-2 rounded-md border px-3 py-2"
                        style="border-color: var(--border); background-color: var(--bg)"
                    >
                        <span class="flex-1 text-sm" style="color: var(--ink)">{{ componentLabels[component] }}</span>
                        <input
                            v-model.number="weightForms[aggregate].weights[component]"
                            type="number"
                            step="0.01"
                            min="0"
                            :disabled="!canEdit"
                            :class="inputStyle"
                            :style="inputSurface"
                            class="w-20 disabled:opacity-60"
                        />
                        <span class="w-12 shrink-0 text-right text-xs tabular-nums" style="color: var(--ink-faint)">
                            {{ normalizedPercent(aggregate, component) }}%
                        </span>
                    </div>
                </div>

                <p v-if="weightForms[aggregate].errors.weights" class="mt-2 text-xs" style="color: var(--status-parah-ink)">
                    {{ weightForms[aggregate].errors.weights }}
                </p>

                <button
                    v-if="canEdit"
                    class="mt-3 text-xs font-semibold transition-colors hover:opacity-70"
                    style="color: var(--accent)"
                    :disabled="weightForms[aggregate].processing"
                    @click="saveWeights(aggregate)"
                >
                    Save weights
                </button>
            </section>
        </div>

        <div class="mt-10 grid gap-6 lg:grid-cols-2">
            <section
                v-for="metric in scoreMetrics"
                :key="metric"
                class="rounded-lg border p-5"
                style="border-color: var(--border); background-color: var(--surface)"
            >
                <h2 class="font-display text-sm font-bold" style="color: var(--ink)">{{ metricTitles[metric] }}</h2>
                <p class="mt-0.5 font-mono text-xs" style="color: var(--ink-faint)">{{ metricHints[metric] }}</p>

                <div class="mt-4 space-y-2">
                    <div
                        v-for="bucket in scoreBucketsByMetric[metric]"
                        :key="bucket.id"
                        class="flex items-center gap-2 rounded-md border px-3 py-2"
                        style="border-color: var(--border); background-color: var(--bg)"
                    >
                        <span class="text-xs" style="color: var(--ink-faint)">≥</span>
                        <input
                            v-model.number="scoreForms[bucket.id].min_rate"
                            type="number"
                            step="0.01"
                            placeholder="floor"
                            :disabled="!canEdit"
                            :class="inputStyle"
                            :style="inputSurface"
                            class="w-20 disabled:opacity-60"
                        />
                        <span class="text-xs" style="color: var(--ink-faint)">→ score</span>
                        <input
                            v-model.number="scoreForms[bucket.id].score"
                            type="number"
                            step="0.01"
                            :disabled="!canEdit"
                            :class="inputStyle"
                            :style="inputSurface"
                            class="w-20 disabled:opacity-60"
                        />
                        <div v-if="canEdit" class="ml-auto flex items-center gap-2">
                            <button
                                class="text-xs font-medium transition-colors hover:opacity-70"
                                style="color: var(--accent)"
                                :disabled="scoreForms[bucket.id].processing"
                                @click="saveScoreBucket(bucket)"
                            >
                                Save
                            </button>
                            <button
                                class="text-xs font-medium transition-colors hover:opacity-70"
                                style="color: var(--status-parah-ink)"
                                @click="deleteScoreBucket(bucket)"
                            >
                                ✕
                            </button>
                        </div>
                    </div>

                    <div
                        v-if="canEdit"
                        class="flex items-center gap-2 rounded-md border border-dashed px-3 py-2"
                        style="border-color: var(--border-strong)"
                    >
                        <span class="text-xs" style="color: var(--ink-faint)">≥</span>
                        <input
                            v-model.number="newScoreForms[metric].min_rate"
                            type="number"
                            step="0.01"
                            placeholder="floor"
                            :class="inputStyle"
                            :style="inputSurface"
                            class="w-20"
                        />
                        <span class="text-xs" style="color: var(--ink-faint)">→ score</span>
                        <input
                            v-model.number="newScoreForms[metric].score"
                            type="number"
                            step="0.01"
                            :class="inputStyle"
                            :style="inputSurface"
                            class="w-20"
                        />
                        <button
                            class="ml-auto text-xs font-semibold transition-colors hover:opacity-70"
                            style="color: var(--accent)"
                            :disabled="newScoreForms[metric].processing"
                            @click="addScoreBucket(metric)"
                        >
                            + Add tier
                        </button>
                    </div>
                </div>
            </section>
        </div>

        <div class="mt-10 grid gap-6 lg:grid-cols-3">
            <section
                v-for="metric in labelMetrics"
                :key="metric"
                class="rounded-lg border p-5"
                style="border-color: var(--border); background-color: var(--surface)"
            >
                <h2 class="font-display text-sm font-bold" style="color: var(--ink)">{{ metricTitles[metric] }}</h2>
                <p class="mt-0.5 font-mono text-xs" style="color: var(--ink-faint)">{{ metricHints[metric] }}</p>

                <div class="mt-4 space-y-2">
                    <div
                        v-for="bucket in labelBucketsByMetric[metric]"
                        :key="bucket.id"
                        class="flex items-center gap-2 rounded-md border px-3 py-2"
                        style="border-color: var(--border); background-color: var(--bg)"
                    >
                        <span class="text-xs" style="color: var(--ink-faint)">≥</span>
                        <input
                            v-model.number="labelForms[bucket.id].min_score"
                            type="number"
                            step="0.01"
                            placeholder="floor"
                            :disabled="!canEdit"
                            :class="inputStyle"
                            :style="inputSurface"
                            class="w-16 disabled:opacity-60"
                        />
                        <input
                            v-model="labelForms[bucket.id].label"
                            type="text"
                            :disabled="!canEdit"
                            :class="inputStyle"
                            :style="inputSurface"
                            class="w-24 disabled:opacity-60"
                        />
                        <div v-if="canEdit" class="ml-auto flex items-center gap-2">
                            <button
                                class="text-xs font-medium transition-colors hover:opacity-70"
                                style="color: var(--accent)"
                                :disabled="labelForms[bucket.id].processing"
                                @click="saveLabelBucket(bucket)"
                            >
                                Save
                            </button>
                            <button
                                class="text-xs font-medium transition-colors hover:opacity-70"
                                style="color: var(--status-parah-ink)"
                                @click="deleteLabelBucket(bucket)"
                            >
                                ✕
                            </button>
                        </div>
                    </div>

                    <div
                        v-if="canEdit"
                        class="flex items-center gap-2 rounded-md border border-dashed px-3 py-2"
                        style="border-color: var(--border-strong)"
                    >
                        <span class="text-xs" style="color: var(--ink-faint)">≥</span>
                        <input
                            v-model.number="newLabelForms[metric].min_score"
                            type="number"
                            step="0.01"
                            placeholder="floor"
                            :class="inputStyle"
                            :style="inputSurface"
                            class="w-16"
                        />
                        <input
                            v-model="newLabelForms[metric].label"
                            type="text"
                            placeholder="Label"
                            :class="inputStyle"
                            :style="inputSurface"
                            class="w-24"
                        />
                        <button
                            class="ml-auto text-xs font-semibold transition-colors hover:opacity-70"
                            style="color: var(--accent)"
                            :disabled="newLabelForms[metric].processing"
                            @click="addLabelBucket(metric)"
                        >
                            + Add tier
                        </button>
                    </div>
                </div>
            </section>
        </div>

        <ConfirmDialog
            :open="!!deletingBucket"
            title="Delete this tier?"
            message="This will permanently remove this scoring tier. This cannot be undone."
            :processing="deletingBucketProcessing"
            @confirm="confirmDeleteBucket"
            @cancel="cancelDeleteBucket"
        />
</template>
