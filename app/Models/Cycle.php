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
        'project_manager_id',
        'cycle_start_date',
        'cycle_end_date',
        'start_follower',
        'end_follower',
        'reach',
        'views',
        'engagement',
        'story_performance',
        'ads_currency',
        'reach_views_ads_used',
        'reach_views_ads_spend',
        'engagement_ads_used',
        'engagement_ads_spend',
    ];

    protected $casts = [
        'cycle_start_date' => 'date',
        'cycle_end_date' => 'date',
        'ai_summary_generated_at' => 'datetime',
        'reach_views_ads_used' => 'boolean',
        'engagement_ads_used' => 'boolean',
    ];

    public function account(): BelongsTo
    {
        return $this->belongsTo(Account::class);
    }

    public function projectManager(): BelongsTo
    {
        return $this->belongsTo(Employee::class, 'project_manager_id');
    }
}
