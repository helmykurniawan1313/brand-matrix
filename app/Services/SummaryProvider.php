<?php

namespace App\Services;

use App\Models\Cycle;
use Illuminate\Support\Collection;

interface SummaryProvider
{
    public function summarize(Cycle $cycle, array $scores, ?string $customPrompt = null): string;

    public function summarizeFiltered(Collection $cycles, array $filterDescription, ?string $customPrompt = null): string;
}
