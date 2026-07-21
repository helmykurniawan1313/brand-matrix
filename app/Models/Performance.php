<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Performance extends Model
{
    use HasFactory;

    protected $fillable = [
        'client_id',
        'post_date',
        'preview_date',
        'ads',
        'project_manager_id',
        'conceptor_id',
        'editor_id',
        'followers',
        'total_views_h7',
        'proof_path',
    ];

    protected $casts = [
        'post_date' => 'date',
        'preview_date' => 'date',
        'ads' => 'boolean',
    ];

    public function client(): BelongsTo
    {
        return $this->belongsTo(Account::class, 'client_id');
    }

    public function projectManager(): BelongsTo
    {
        return $this->belongsTo(Employee::class, 'project_manager_id');
    }

    public function conceptor(): BelongsTo
    {
        return $this->belongsTo(Employee::class, 'conceptor_id');
    }

    public function editor(): BelongsTo
    {
        return $this->belongsTo(Employee::class, 'editor_id');
    }

    public function videoLinks(): HasMany
    {
        return $this->hasMany(PerformanceVideoLink::class)->orderBy('order');
    }
}
