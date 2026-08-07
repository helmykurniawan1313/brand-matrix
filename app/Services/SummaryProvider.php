<?php

namespace App\Services;

use App\Models\Cycle;
use App\Models\Performance;
use Illuminate\Support\Collection;

interface SummaryProvider
{
    public function summarize(Cycle $cycle, array $scores, ?string $customPrompt = null): string;

    public function summarizeFiltered(Collection $cycles, array $filterDescription, ?string $customPrompt = null): string;

    public function summarizePerformance(Performance $performance, ?string $customPrompt = null): string;

    public function summarizeFilteredPerformances(Collection $performances, array $filterDescription, ?string $customPrompt = null): string;
}
