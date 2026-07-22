<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class LabelBucket extends Model
{
    public const METRIC_GROWTH = 'growth';

    public const METRIC_VISIBILITY = 'visibility';

    public const METRIC_ENGAGEMENT = 'engagement';

    public const METRIC_HEALTH = 'health';

    public const METRICS = [
        self::METRIC_GROWTH,
        self::METRIC_VISIBILITY,
        self::METRIC_ENGAGEMENT,
        self::METRIC_HEALTH,
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
