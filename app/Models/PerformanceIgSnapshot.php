<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PerformanceIgSnapshot extends Model
{
    protected $fillable = [
        'performance_id',
        'reach',
        'likes',
        'comments',
        'shares',
        'saved',
        'total_interactions',
        'views',
        'ig_reels_avg_watch_time',
        'ig_reels_video_view_total_time',
        'fetched_at',
    ];

    protected $casts = [
        'fetched_at' => 'datetime',
    ];

    public function performance(): BelongsTo
    {
        return $this->belongsTo(Performance::class);
    }
}
