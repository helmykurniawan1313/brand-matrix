<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class FilterSummary extends Model
{
    protected $fillable = [
        'filters',
        'provider',
        'custom_prompt',
        'summary',
        'cycle_count',
    ];

    protected $casts = [
        'filters' => 'array',
    ];
}
