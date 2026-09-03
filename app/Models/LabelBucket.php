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

    public const METRIC_FOLLOWERS = 'followers';

    // Separate from METRIC_GROWTH (used by Cycles/Dashboard) — this one drives
    // only the Accounts table's/Growth modal's Growth Rate badge, so its own
    // thresholds/labels can be tuned without touching the cycle-level scheme.
    public const METRIC_ACCOUNT_GROWTH = 'account_growth';

    public const METRICS = [
        self::METRIC_GROWTH,
        self::METRIC_VISIBILITY,
        self::METRIC_ENGAGEMENT,
        self::METRIC_HEALTH,
        self::METRIC_VIEWS,
        self::METRIC_FOLLOWERS,
        self::METRIC_ACCOUNT_GROWTH,
    ];

    protected $fillable = [
        'metric',
        'min_score',
        'label',
    ];

    protected $casts = [
        'min_score' => 'decimal:2',
    ];
}
