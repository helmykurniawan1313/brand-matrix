<?php

namespace App\Models;

use App\Services\AccountTierResolver;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Cycle extends Model
{
    use HasFactory;

    protected static function booted(): void
    {
        // Resolved on every create/update rather than left to the caller, so
        // every path that saves a Cycle (controller, factory, future admin
        // tooling) gets a consistent tier/needs_check without having to
        // remember to call AccountTierResolver itself.
        static::saving(function (Cycle $cycle) {
            $cycle->tier = (new AccountTierResolver())->resolve((float) $cycle->start_follower);

            $cycle->needs_check = (float) $cycle->start_follower === 0.0
                || abs($cycle->growthRateForNeedsCheck()) > 100.0;
        });
    }

    /**
     * Growth rate computed independently of MetricCalculator — needs_check is
     * a data-quality flag resolved at save time, before scores exist, so it
     * can't depend on the scoring pipeline itself.
     */
    private function growthRateForNeedsCheck(): float
    {
        $start = (float) $this->start_follower;

        if ($start === 0.0) {
            return 0.0;
        }

        return (((float) $this->end_follower - $start) / $start) * 100;
    }

    protected $fillable = [
        'account_id',
        'platform',
        'tier',
        'needs_check',
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
        'needs_check' => 'boolean',
        'formula_changed_at' => 'datetime',
    ];

    public function account(): BelongsTo
    {
        return $this->belongsTo(Account::class);
    }

    public function projectManager(): BelongsTo
    {
        return $this->belongsTo(Employee::class, 'project_manager_id');
    }

    public function performances(): HasMany
    {
        return $this->hasMany(Performance::class);
    }
}
