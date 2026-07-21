<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PerformanceVideoLink extends Model
{
    protected $fillable = [
        'performance_id',
        'url',
        'platform',
        'thumbnail_url',
        'embed_html',
        'order',
    ];

    public function performance(): BelongsTo
    {
        return $this->belongsTo(Performance::class);
    }
}
