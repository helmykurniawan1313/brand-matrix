<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class InstagramDailySnapshot extends Model
{
    protected $fillable = [
        'account_id',
        'captured_date',
        'followers_count',
        'media_count',
        'reach',
        'views',
        'accounts_engaged',
        'total_interactions',
        'captured_at',
    ];

    protected $casts = [
        'captured_date' => 'date',
        'captured_at' => 'datetime',
    ];

    public function account(): BelongsTo
    {
        return $this->belongsTo(Account::class);
    }
}
