<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Account extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'project_manager_id',
    ];

    protected $casts = [
        'ai_summary_generated_at' => 'datetime',
        'ig_access_token' => 'encrypted',
        'ig_token_expires_at' => 'datetime',
        'ig_connected_at' => 'datetime',
    ];

    protected $hidden = [
        'ig_access_token',
    ];

    public function cycles(): HasMany
    {
        return $this->hasMany(Cycle::class);
    }

    public function projectManager(): BelongsTo
    {
        return $this->belongsTo(Employee::class, 'project_manager_id');
    }

    public function instagramDailySnapshots(): HasMany
    {
        return $this->hasMany(InstagramDailySnapshot::class);
    }
}
