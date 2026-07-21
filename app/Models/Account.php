<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Account extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
    ];

    protected $casts = [
        'ai_summary_generated_at' => 'datetime',
    ];

    public function cycles(): HasMany
    {
        return $this->hasMany(Cycle::class);
    }
}
