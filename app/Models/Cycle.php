<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Cycle extends Model
{
    use HasFactory;

    protected $fillable = [
        'account_id',
        'cycle_start_date',
        'cycle_end_date',
        'start_follower',
        'end_follower',
        'reach',
        'views',
        'engagement',
        'story_performance',
    ];

    protected $casts = [
        'cycle_start_date' => 'date',
        'cycle_end_date' => 'date',
        'ai_summary_generated_at' => 'datetime',
    ];

    public function account(): BelongsTo
    {
        return $this->belongsTo(Account::class);
    }
}
