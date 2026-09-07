<script setup>
// Renders one status field (health/growth/reach/views/engagement) for an
// account row — when the account has cycles on more than one platform, shows
// one small platform-tagged line per platform instead of a single blended
// badge (mixing platforms would silently compare one platform's numbers
// against another's, which used to be a real bug here). Falls back to a
// single flat badge for the common single-platform case, so nothing changes
// visually for most accounts.
import StatusBadge from './StatusBadge.vue';

const props = defineProps({
    account: { type: Object, required: true },
    field: { type: String, required: true },
    tone: { type: Function, default: null }, // (value) => inline style string; omit to use StatusBadge
    size: { type: String, default: 'md' }, // 'md' (table) | 'sm' (cards)
});

const platformMeta = {
    instagram: { label: 'IG' },
    tiktok: { label: 'TT' },
};

const rows = () => {
    const platforms = Object.keys(props.account.by_platform ?? {});
    if (platforms.length === 0) {
        return [{ platform: null, value: props.account[props.field] ?? null }];
    }
    return platforms.map((platform) => ({ platform, value: props.account.by_platform[platform]?.[props.field] ?? null }));
};

const hasAnyData = () => props.account[props.field] || Object.keys(props.account.by_platform ?? {}).length > 0;
const showPlatformTag = () => Object.keys(props.account.by_platform ?? {}).length > 1;
</script>

<template>
    <div v-if="hasAnyData()" class="flex flex-col gap-1">
        <div v-for="row in rows()" :key="`${field}-${row.platform}`" class="flex items-center gap-1">
            <span
                v-if="row.platform && showPlatformTag()"
                class="shrink-0 text-[9px] font-bold uppercase"
                style="color: var(--ink-faint)"
            >
                {{ platformMeta[row.platform]?.label ?? row.platform }}
            </span>
            <StatusBadge v-if="!tone && row.value" :status="row.value" />
            <span
                v-else-if="tone && row.value"
                class="inline-block whitespace-nowrap rounded-full font-semibold"
                :class="size === 'sm' ? 'px-2 py-0.5 text-xs' : 'px-2.5 py-1 text-xs'"
                :style="tone(row.value)"
            >
                {{ row.value }}
            </span>
            <span v-else style="color: var(--ink-faint)">—</span>
        </div>
    </div>
    <span v-else style="color: var(--ink-faint)">No data</span>
</template>
