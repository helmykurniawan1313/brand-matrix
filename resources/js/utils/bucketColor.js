// Shared color-resolution helper for score/label bucket tiers.
//
// A tier's `color` is either one of the app's existing status-tone tokens
// ('sip'|'bagus'|'cukup'|'kurang'|'parah' — see resources/css/app.css) or
// 'custom', in which case `custom_color_bg`/`custom_color_ink` hold the
// literal hex values. Used by Settings/Buckets.vue (editable tier rows,
// range bars) and StatusBadge.vue (rendering a label's resolved color
// anywhere in the app), so both read a tier's color the same way.

export const STATUS_TONES = ['sip', 'bagus', 'cukup', 'kurang', 'parah'];

// Fallback rotation by rank, used only when a tier has no stored color yet
// (pre-migration data, or a brand-new tier) — matches the old hardcoded
// tierTones order so nothing jumps visually for unmigrated rows.
export const toneByRank = (rank) => STATUS_TONES[Math.min(rank, STATUS_TONES.length - 1)];

/**
 * Resolves a tier/bucket's color to a { bg, ink } pair of CSS var()/hex values.
 * @param {{ color?: string|null, custom_color_bg?: string|null, custom_color_ink?: string|null }|null} bucket
 * @param {number} fallbackRank - rank to fall back to when bucket has no color set
 */
export function resolveBucketColor(bucket, fallbackRank = 0) {
    const color = bucket?.color;

    if (color === 'custom' && bucket.custom_color_bg && bucket.custom_color_ink) {
        return { bg: bucket.custom_color_bg, ink: bucket.custom_color_ink };
    }

    const token = STATUS_TONES.includes(color) ? color : toneByRank(fallbackRank);
    return { bg: `var(--status-${token}-bg)`, ink: `var(--status-${token}-ink)` };
}
