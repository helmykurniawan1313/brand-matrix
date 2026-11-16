<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class LabelBucket extends Model
{
    public const METRIC_GROWTH = 'growth';

    public const METRIC_VISIBILITY = 'visibility';

    public const METRIC_ENGAGEMENT = 'engagement';

    public const METRIC_HEALTH = 'health';

    public const METRIC_VIEWS = 'views';

    // Deliberately unused as of the account-tier/follower-category unification
    // — Performance's follower-category badge now reads METRIC_ACCOUNT_TIER
    // directly instead of this separate bucket set, so there's one tier
    // config instead of two that could drift apart (and did: this one had no
    // floor tier, so accounts under 1,000 followers showed "No data"). Left
    // defined (not removed) only in case any pre-unification row still
    // references it in the database; not in METRICS below, so it no longer
    // shows as an editable section in Settings.
    public const METRIC_FOLLOWERS = 'followers';

    // Separate from METRIC_GROWTH (used by Cycles/Dashboard) — this one drives
    // only the Accounts table's/Growth modal's Growth Rate badge, so its own
    // thresholds/labels can be tuned without touching the cycle-level scheme.
    public const METRIC_ACCOUNT_GROWTH = 'account_growth';

    // Period-over-period % CHANGE labels for the Growth Analysis panel (Account
    // Growth modal) — distinct from METRIC_VIEWS/METRIC_ENGAGEMENT above, which
    // label an absolute count/score, not a change between two picked points.
    public const METRIC_VIEWS_CHANGE = 'views_change';

    public const METRIC_REACH_CHANGE = 'reach_change';

    public const METRIC_ENGAGEMENT_CHANGE = 'engagement_change';

    // Account-size tier (Rintisan/Kecil/Menengah/Besar) resolved from a cycle's
    // start_follower, used to pick which ScoreBucket threshold set scores that
    // cycle (see MetricCalculator). Also now the single source of truth for
    // Performance's follower-category badge (PerformanceController reads this
    // metric directly) — see the METRIC_FOLLOWERS note above for why the two
    // were unified.
    public const METRIC_ACCOUNT_TIER = 'account_tier';

    public const METRICS = [
        self::METRIC_GROWTH,
        self::METRIC_VISIBILITY,
        self::METRIC_ENGAGEMENT,
        self::METRIC_HEALTH,
        self::METRIC_VIEWS,
        self::METRIC_ACCOUNT_GROWTH,
        self::METRIC_VIEWS_CHANGE,
        self::METRIC_REACH_CHANGE,
        self::METRIC_ENGAGEMENT_CHANGE,
        self::METRIC_ACCOUNT_TIER,
    ];

    protected $fillable = [
        'metric',
        'min_score',
        'label',
        'color',
        'custom_color_bg',
        'custom_color_ink',
    ];

    protected $casts = [
        'min_score' => 'decimal:2',
    ];
}
